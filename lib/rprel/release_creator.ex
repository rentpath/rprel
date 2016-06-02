defmodule Rprel.ReleaseCreator do
  @github_api Application.get_env(:rprel, :github_api)

  def create(release_info, files, opts) do
    with :ok <- validate_release(release_info),
         :ok <- validate_files(files),
         :ok <- validate_opts(opts),
         {:ok, id} <- @github_api.create_release(release_info, files, opts),
         do: {:ok, [id: id]}
  end

  defp validate_release(release) do
    with :ok <- validate_repo_name(release.name),
         :ok <- validate_version(release.version),
         :ok <- validate_commit(release.commit),
         do: :ok
  end

  defp validate_files(files) do
    cond do
      is_nil(files) || files == [] -> {:error, :missing_files}
      !readable?(files) -> {:error, :unreadable_files}
      true -> :ok
    end
  end

  defp validate_opts(opts) do
    cond do
      @github_api.valid_token?(opts[:token]) -> :ok
      true -> {:error, :invalid_auth_token}
    end
  end

  defp validate_repo_name(name) do
    if String.match?(to_string(name), ~r/[\w-]+\/[\w-]+/), do: :ok, else: {:error, :invalid_repo_name}
  end

  defp validate_version(version) do
    if version, do: :ok, else: {:error, :missing_version}
  end

  defp validate_commit(commit) do
    if commit, do: :ok, else: {:error, :missing_commit}
  end

  defp readable?(files) when is_list(files) do
    Enum.all?(files, &readable?/1)
  end

  defp readable?(file) when is_binary(file) do
    case File.stat(file) do
      {:ok, %File.Stat{access: :read}} -> true
      {:ok, %File.Stat{access: :read_write}} -> true
      _ -> false
    end
  end

  defp readable?(_), do: false
end
