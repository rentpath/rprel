defmodule Rprel.GithubRelease.HTTP do
  @moduledoc """
  API interface to Github Releases

  """
  require Logger

  @full_commit_sha_length 40

  @behaviour Rprel.GithubRelease

  @timeout Application.get_env(:rprel, :file_upload_timeout)

  @spec create_release(release :: %Rprel.GithubRelease{}, files :: list | String.t, creds :: [token: String.t]) :: {:ok, id :: String.t} | {:error, msg :: String.t}
  def create_release(release = %Rprel.GithubRelease{}, files, [token: token]) do
    with {:ok, full_sha} <- create_tag(release, token),
         {:ok, %{id: id, upload_url: upload_url}} <- make_release_call(release, token, full_sha),
         :ok <- do_upload_files(files, upload_url, token),
      do: {:ok, id}
  end

  def valid_token?(token) do
    header =
      api_url()
      |> HTTPoison.get!(auth_header(token))
      |> Map.fetch!(:headers)
      |> List.keyfind("X-OAuth-Scopes", 0)

    case header do
      {_, scopes} -> required_scopes?(scopes)
      _ -> false
    end
  end

  def create_tag(release, token) do
    tag_body = formatted_tag_body(release, token)
    full_sha = decode_json(tag_body) |> Map.get("object")

    resp =
      "#{api_url()}/repos/#{release.name}/git/tags"
      |> authenticated_post(tag_body, token)

    case resp.status_code do
      201 ->
        with tag_info <- decode_json(resp.body),
             tag_sha <- Map.get(tag_info, "sha"),
         do: {create_tag_ref(release, token, tag_sha), full_sha}
      422 -> {:error, response_message(resp, :tag_already_exists)}
      404 -> {:error, response_message(resp, :repository_not_found)}
        _ -> {:error, response_message(resp, :unspecified_error)}
    end
  end

  defp create_tag_ref(release, token, tag_sha) do
    tag_body = formatted_tag_ref_body(release, tag_sha)
    resp =
      "#{api_url()}/repos/#{release.name}/git/refs"
      |> authenticated_post(tag_body, token)

    case resp.status_code do
      201 -> :ok
      422 -> {:error, response_message(resp, :tag_ref_already_associated)}
      404 -> {:error, response_message(resp, :repository_not_found)}
        _ -> {:error, response_message(resp, :unspecified_error)}
    end
  end

  defp make_release_call(release, token, full_sha) do
    resp =
      "#{api_url()}/repos/#{release.name}/releases"
      |> authenticated_post(formatted_release_body(release, full_sha), token)

    case resp.status_code do
      201 ->
        release_info = decode_json(resp.body)
        {:ok, %{id: Map.get(release_info, "id"), upload_url: Map.get(release_info, "upload_url")}}
      422 -> {:error, response_message(resp, :release_already_exists)}
      404 -> {:error, response_message(resp, :repository_not_found)}
        _ -> {:error, response_message(resp, :unspecified_error)}
    end
  end

  defp do_upload_files(files, url_template, token) do
    [files]
    |> List.flatten
    |> Enum.each(fn (file) ->
      url = url_template
            |> UriTemplate.expand(name: Path.basename(file))
            |> String.replace_trailing("&label=", "")
      authenticated_post(url, {:file, file}, token)
    end)
    :ok
  end

  defp api_url, do: Application.get_env(:rprel, :github_api_endpoint)

  defp auth_header(token), do: %{"Authorization" => "token #{token}"}

  defp authenticated_post(url, body, token) do
    HTTPoison.post!(url, body, auth_header(token),
      [connect_timeout: @timeout, recv_timeout: @timeout, timeout: @timeout])
  end

  defp required_scopes?(scopes) do
    String.contains?(scopes, "repo") && !String.contains?(scopes, "public_repo")
  end

  defp formatted_release_body(release, full_sha) do
    Poison.encode!(%{tag_name: release.version, target_commitish: full_sha, name: release.version,
                     prerelease: true, body: "branch: #{release.branch}"})
  end

  defp formatted_tag_body(release, token) do
    date = DateTime.utc_now |> Timex.local |> Timex.format!("%Y-%m-%dT%H:%M:%S%:z", :strftime)
    Poison.encode!(%{tag: release.version, message: release.version,
                     object: full_commit_sha(release, token), type: "commit",
                     tagger: %{name: "rentpath-rpre", email: "idg@primedia.com", date: date}})
  end

  defp formatted_tag_ref_body(release, tag_sha) do
    Poison.encode!(%{ref: "refs/tags/#{release.version}", sha: tag_sha})
  end

  def response_message(response, default_message) do
    Map.get(decode_json(response.body), "message") || default_message
  end

  defp full_commit_sha(release, token) do
    if String.length(release.commit) < @full_commit_sha_length do
      fetch_commit(release, token)
    else
      release.commit
    end
  end

  defp fetch_commit(release, token) do
    "#{api_url()}/repos/#{release.name}/git/trees/#{release.commit}"
    |> get_data(release.name, token, %{"sha" => release.commit})
    |> Map.get("sha")
  end

  defp get_data(url, git_repo, token, default) do
    case HTTPoison.get(url, auth_header(token)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decode_json(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.warn("Github repo named #{git_repo} does not exist. Not found.")
        default
      {:error, %HTTPoison.Error{reason: message}} ->
        Logger.warn("Could not get #{url}: #{inspect message}")
        default
    end
  end

  defp decode_json(json) do
    case Poison.decode(json) do
      {:ok, data} -> data
      {:error, _error} -> nil
    end
  end
end
