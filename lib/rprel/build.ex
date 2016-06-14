defmodule Rprel.Build do
  @moduledoc """
  Handles gzipping directories or files that can be used as release artifacts.
  """
  alias Timex.Date, as: Date

  @missing_build_number "You must provide a build number with --build-number"
  @missing_commit_sha "You must provide a commit sha with --commit"
  @invalid_path "You must supply a valid path"

  def create(opts) do
    case valid?(opts) do
      {true, opts} ->
        case build(opts) do
          0 -> archive(opts)
          {:error, msg} -> IO.puts(msg)
          status when status > 0 -> IO.puts("build returned an error")
          _ -> nil
        end
      {false, _args} ->
        error_message(opts)
    end
  end

  defp build([path: path, build_number: build_number, commit: sha]) do
    case create_build_info(path, build_number, sha) do
      :ok -> run_build_script(path)
      {:error, msg} -> {:error, msg}
    end
  end

  defp run_build_script(path) do
    if File.exists?(Path.join([path, 'bin', 'build'])) do
      Porcelain.shell("cd #{path} && ./bin/build").status
    else
      IO.puts("build not found, skipping build step")
      0
    end
  end

  defp create_build_info(path, build_number, sha) do
    short_sha = String.slice(sha, 0..6)
    version_string =  "#{today}-#{build_number}-#{short_sha}"

    build_info_template = ~s"""
    ---
    version: #{version_string}
    build_number: #{build_number}
    git_commit: #{sha}
    """

    if valid_path?(path) do
      File.write(Path.join(path, "BUILD-INFO"), build_info_template)
    else
      {:error, @invalid_path}
    end
  end

  defp archive([path: path, build_number: build_number, commit: sha]) do
    short_sha = String.slice(sha, 0..6)
    version_string =  "#{today}-#{build_number}-#{short_sha}"

    if File.exists?(Path.join([path, 'bin', 'archive'])) do
      IO.puts("running archive")
      output = Porcelain.shell("cd #{path} && ./bin/archive")
      if output.status != 0 do
        IO.puts("archive returned an error")
      end
      output.status
    else
      write_archive(path, version_string)
    end
  end

  defp write_archive(path, version_string) do
    archive_path = Path.join(System.tmp_dir(), "#{version_string}.tgz")
    System.cmd("tar", ["--dereference", "-czf", archive_path, path])
    System.cmd("mv", [archive_path, path])
    IO.puts("created #{version_string}.tgz")
    {:ok, nil}
  end

  defp valid?(opts) do
    unless opts[:path] do
      opts = opts ++ [path: '.']
    end

    unless opts[:commit] do
      command =
        Porcelain.shell("cd #{opts[:path]} && git rev-parse --verify HEAD")
      if command.status == 0 do
        opts = opts ++ [commit: String.strip(command.out)]
      end
    end

    {!!(valid_path?(opts[:path]) && valid_commit?(opts[:commit]) && opts[:build_number] && opts[:commit]),
     opts}
  end

  defp valid_path?(path) do
    case File.stat(path) do
      {:ok, permission} -> permission.access == :read_write
      {:error, _message} -> false
    end
  end

  defp valid_commit?(commit) do
    is_bitstring(commit)
  end

  defp today do
    Timex.format(Date.today, "%Y%m%d", :strftime) |> elem(1)
  end

  defp error_message(opts) do
    cond do
      is_nil(opts[:build_number]) -> {:error, @missing_build_number}
      is_nil(opts[:commit]) -> {:error, @missing_commit_sha}
      !valid_path?(opts[:path]) -> {:error, @invalid_path}
    end
  end
end
