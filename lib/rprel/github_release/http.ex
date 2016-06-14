defmodule Rprel.GithubRelease.HTTP do
  @moduledoc """
  API interface to Github Releases

  """

  @behaviour Rprel.GithubRelease

  def create_release(release = %Rprel.GithubRelease{}, files, [token: token]) do
    with {:ok, [id: id, upload_url: upload_url]} <-
         do_create_release(release, token),
           :ok <- do_upload_files(files, upload_url, token),
           do: {:ok, id}
  end

  def valid_token?(token) do
    header = HTTPoison.get!(api_url, auth_header(token))
      |> Map.fetch!(:headers)
      |> List.keyfind("X-OAuth-Scopes", 0)
    case header do
      {_, scopes} -> required_scopes?(scopes)
      _ -> false
    end
  end

  defp do_create_release(release, token) do
    resp =
      api_url <> "/repos/#{release.name}/releases"
      |> authenticated_post(formatted_release_body(release), token)

    case resp.status_code do
      201 ->
        release_info = resp |> Map.fetch!(:body) |> Poison.decode!
        {:ok, [id: release_info["id"], upload_url: release_info["upload_url"]]}
      422 -> {:error, :release_already_exists}
       _ -> {:error, :unspecified_error}
    end
  end

  defp do_upload_files(files, url_template, token) do
    [files]
    |> List.flatten
    |> Enum.each(fn (file) ->
      url = UriTemplate.expand(url_template, name: Path.basename(file))
            |> String.replace_trailing("&label=", "")
      authenticated_post(url, {:file, file}, token)
    end)
    :ok
  end

  defp api_url, do: Application.get_env(:rprel, :github_api_endpoint)

  defp auth_header(token), do: %{"Authorization" => "token #{token}"}

  defp authenticated_post(url, body, token), do: HTTPoison.post!(url, body, auth_header(token))

  defp required_scopes?(scopes) do
    String.contains?(scopes,"repo") && !String.contains?(scopes,"public_repo")
  end

  defp formatted_release_body(release) do
    Poison.encode!(%{tag_name: release.version, name: release.version,
                     commitish: release.commit, prerelease: true})
  end
end
