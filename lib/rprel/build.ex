defmodule Rprel.Build do
  @moduledoc """
  Handles gzipping directories or files that can be used as release artifacts.
  """
  alias Timex.Date, as: Date

  @missing_build_number "You must provide a build number with --build-number"
  @missing_commit_sha "You must provide a commit sha with --commit"
  @invalid_path "You must supply a valid path"

  def create(opts) do
    {valid, opts} = valid?(opts)

    result =
      with {true, opts} <- {valid, opts},
           {:ok, 0} <- build(opts[:path], opts[:build_number], opts[:commit]),
           do: archive(opts[:path], version_string(opts[:build_number], opts[:commit]))

    case result do
      {false, _args} -> error_message(opts)
      {:error, message} -> IO.puts(message)
      _ -> {:ok, nil}
    end
  end

  defp build(path, build_number, sha) do
    case create_build_info(path, build_number, sha) do
      :ok -> run_build_script(path)
      {:error, msg} -> {:error, msg}
    end
  end

  defp run_build_script(path) do
    if File.exists?(Path.join([path, 'bin', 'build'])) do
      case Porcelain.shell("./bin/build", dir: path) do
        %Porcelain.Result{status: 0} -> {:ok, 0}
        %Porcelain.Result{out: message} ->
          message = if String.length(message) == 0, do: "build returned an error"
              {:error, message}
      end
    else
      IO.puts("build not found, skipping build step")
      {:ok, 0}
    end
  end

  defp create_build_info(path, build_number, sha) do
    build_info_template = ~s"""
    ---
    version: #{version_string(build_number, sha)}
    build_number: #{build_number}
    git_commit: #{sha}
    """

    if valid_path?(path) do
      File.write(Path.join(path, "BUILD-INFO"), build_info_template)
    else
      {:error, @invalid_path}
    end
  end

  defp archive(path, version) do
    if File.exists?(Path.join([path, 'bin', 'archive'])) do
      IO.puts("running archive")
      output = Porcelain.shell("./bin/archive", dir: path)
      if output.status != 0 do
        IO.puts("archive returned an error")
      end
      output.status
    else
      write_archive(path, version)
    end
  end

  defp write_archive(path, version) do
    archive_path = Path.join(System.tmp_dir(), "#{version}.tgz")
    System.cmd("tar", ["--dereference", "-czf", archive_path, path])
    System.cmd("mv", [archive_path, path])
    IO.puts("created #{version}.tgz")
    {:ok, nil}
  end

  defp valid?(opts) do
    unless opts[:path] do
      opts = opts ++ [path: '.']
    end

    unless opts[:commit] do
      dir = Path.expand(opts[:path])
      command =
        Porcelain.shell("git rev-parse --verify HEAD", dir: dir)
      if command.status == 0 do
        opts = Keyword.put(opts, :commit, String.strip(command.out))
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
    Date.today |> Timex.format("%Y%m%d", :strftime) |> elem(1)
  end

  defp error_message(opts) do
    cond do
      is_nil(opts[:build_number]) -> {:error, @missing_build_number}
      is_nil(opts[:commit]) -> {:error, @missing_commit_sha}
      !valid_path?(opts[:path]) -> {:error, @invalid_path}
    end
  end

  defp version_string(build_number, sha) do
    "#{today}-#{build_number}-#{String.slice(sha, 0..6)}"
  end
end
