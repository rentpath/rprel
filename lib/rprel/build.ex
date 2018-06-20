defmodule Rprel.Build do
  @moduledoc """
  Handles gzipping directories or files that can be used as release artifacts.
  """

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
      {false, _args} ->
        error_message(opts)
      {:error, message} ->
        {:error, message}
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
    if File.exists?(Path.join([path, 'script', 'build'])) do
      IO.puts("running script/build")
      case Porcelain.shell("./script/build", dir: Path.expand(path)) do
        %Porcelain.Result{status: 0} -> {:ok, 0}
        %Porcelain.Result{out: message} ->
          {:error, build_script_message(message)}
      end
    else
      IO.puts("script/build not found, skipping build step")
      {:ok, 0}
    end
  end

  defp build_script_message(""), do: "build returned an error"
  defp build_script_message(message), do: message

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
    if File.exists?(Path.join([path, 'script', 'archive'])) do
      IO.puts("running script/archive")

      output = Porcelain.shell("./script/archive", dir: Path.expand(path))

      if output.status != 0 do
        IO.puts("script/archive returned an error")
      end

      IO.puts(String.strip(output.out))

      if output.status != 0 do
        {:error, ""}
      else
        {:ok, nil}
      end

    else
      write_archive(path, version)
    end
  end

  defp write_archive(path, version) do
    archive_path = Path.join(System.tmp_dir(), "#{version}.tar.gz")
    System.cmd("tar", ["--dereference", "-czf", archive_path, to_string(path)])
    System.cmd("mv", [archive_path, to_string(path)])
    IO.puts("created #{version}.tar.gz")
    {:ok, nil}
  end

  defp valid?(opts) do
    opts =
      case opts[:path] do
        nil -> opts ++ [path: '.']
        _ -> opts
      end

    opts =
      with nil <- opts[:commit],
           dir <- Path.expand(opts[:path]),
           command <- Porcelain.shell("git rev-parse --verify HEAD", dir: dir),
           0 <- command.status
      do
        Keyword.put(opts, :commit, String.strip(command.out))
      else
        _ -> opts
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
    DateTime.utc_now |> Timex.local |> Timex.format!("%Y%m%d", :strftime)
  end

  defp error_message(opts) do
    cond do
      is_nil(opts[:build_number]) -> {:error, @missing_build_number}
      is_nil(opts[:commit]) -> {:error, @missing_commit_sha}
      !valid_path?(opts[:path]) -> {:error, @invalid_path}
    end
  end

  defp version_string(build_number, sha) do
    "#{today()}-#{build_number}-#{String.slice(sha, 0..6)}"
  end
end
