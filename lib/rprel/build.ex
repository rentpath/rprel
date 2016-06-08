defmodule Rprel.Build do
  @missing_build_number "You must provide a build number with --build-number"
  @missing_commit_sha "You must provide a commit sha with --commit"
  @invalid_path "You must supply a valid path"

  def create(opts) do
    case valid?(opts) do
      {true, opts} ->
        date = Timex.format(Timex.Date.today, "%Y%m%d", :strftime) |> elem(1)
        sha = opts[:commit]
        short_sha = String.slice(sha, 0..6)
        build_number = opts[:build_number]
        path = opts[:path]
        version_string =  "#{date}-#{build_number}-#{short_sha}"

        create_build_info(path, build_number, sha, version_string)
        archive(path, version_string)
      {false, _args} ->
        cond do
          is_nil(opts[:build_number]) -> {:error, @missing_build_number}
          is_nil(opts[:commit]) -> {:error, @missing_commit_sha}
          !valid_path?(opts[:path]) -> {:error, @invalid_path}
        end
    end
  end

  defp create_build_info(path, build_number, sha, version_string) do
    build_info_template = ~s"""
    ---
    version: #{version_string}
    build_number: #{build_number}
    git_commit: #{sha}
    """

    if valid_path?(path) do
      File.write!(Path.join(path, "BUILD-INFO"), build_info_template)
    else
      {:error, @invalid_path}
    end
  end

  defp archive(path, version_string) do
    archive_path = Path.join(System.tmp_dir(), "#{version_string}.tgz")
    System.cmd("tar", ["--dereference", "-czf", archive_path, path])
    System.cmd("mv", [archive_path, path])
  end

  defp valid?(opts) do
    unless opts[:path] do
      opts = opts ++ [path: '.']
    end

    {!!(valid_path?(opts[:path]) && opts[:build_number] && opts[:commit]),
     opts}
  end

  def valid_path?(path) do
    case File.stat(path) do
      {:ok, permission} -> permission.access == :read_write
      {:error, _message} -> false
    end
  end
end
