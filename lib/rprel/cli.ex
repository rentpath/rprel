defmodule Rprel.CLI do
  @invalid_repo_name_msg "You must provide a full repo name."
  def invalid_repo_name_msg, do: @invalid_repo_name_msg

  @invalid_commit_msg "You must provide a commit sha."
  def invalid_commit_msg, do: @invalid_commit_msg

  @invalid_version_msg "You must provide a version number."
  def invalid_version_msg, do: @invalid_version_msg

  @invalid_files_msg "You must provide at least one valid file."
  def invalid_files_msg, do: @invalid_files_msg

  @invalid_token_msg "You must provide a valid GitHub authentication token."
  def invalid_token_msg, do: @invalid_token_msg

  @release_already_exists_msg "A release for that version already exists. Please use a different version."
  def release_already_exists_msg, do: @release_already_exists_msg

  @unspecified_error_msg "An unknown error has occurred."
  def unspecified_error_msg, do: @unspecified_error_msg

  def main(argv) do
    {_result, msg} = do_main(argv)
    IO.puts(msg)
  end

  def do_main(argv) do
    {opts, args, _invalid_opts} = OptionParser.parse_head(argv, strict: [help: :boolean, version: :boolean], aliases: [h: :help, v: :version])
    case args do
      ["help" | cmd] -> help(cmd)
      ["build" | build_argv] -> build(build_argv)
      ["release" | release_argv] -> release(release_argv)
      _ -> handle_other_commands(opts)
     end
  end

  def help(cmd) do
    case cmd do
      ["build"] -> {:ok, build_help_text}
      ["release"] -> {:ok, release_help_text}
      _ -> {:error, "No help topic for '#{cmd}'"}
    end
  end

  def build(build_argv) do
    {build_opts, build_args, _invalid_opts} = OptionParser.parse(build_argv, strict: [help: :boolean, command: :string, archive_command: :string, build_number: :string, commit: :string], aliases: [h: :help, c: :command, a: :archive_command])
    cond do
      build_opts[:help] -> {:ok, build_help_text}
      true -> do_build(build_opts, build_args)
    end
  end

  def release(release_argv) do
    {release_opts, release_args, _invalid_opts} = OptionParser.parse(release_argv, strict: [help: :boolean, token: :string, commit: :string, repo: :string, version: :string], aliases: [h: :help, t: :token, c: :commit, r: :repo, v: :version])
    cond do
      release_opts[:help] -> {:ok, release_help_text}
      true -> release_opts |> update_with_release_env_vars |> do_release(release_args)
    end
  end

  def handle_other_commands(opts) do
    cond do
      opts[:help] -> {:ok, help_text}
      opts[:version] -> {:ok, Rprel.version}
      true -> {:ok, help_text}
    end
  end

  def do_build(opts, args) do
    IO.inspect(opts)
    IO.inspect(args)
    Rprel.Build.create(opts, args, "")
  end

  defp do_release(opts, args) do
    release = %Rprel.GithubRelease{name: opts[:repo], version: opts[:version], commit: opts[:commit]}
    case Rprel.ReleaseCreator.create(release, args, [token: opts[:token]]) do
      {:error, :invalid_auth_token} -> {:error, @invalid_token_msg}
      {:error, :invalid_repo_name} -> {:error, @invalid_repo_name_msg}
      {:error, :missing_commit} -> {:error, @invalid_commit_msg}
      {:error, :missing_version} -> {:error, @invalid_version_msg}
      {:error, :missing_files} -> {:error, @invalid_files_msg}
      {:error, :release_already_exists} -> {:error, @release_already_exists_msg}
      {:error, :unspecified_error} -> {:error, @unspecified_error_msg}
      {:ok, _} -> {:ok, ""}
    end
  end

  defp update_with_release_env_vars(opts) do
    opts
    |> Keyword.put_new(:token, System.get_env("GITHUB_AUTH_TOKEN"))
    |> Keyword.put_new(:commit, System.get_env("RELEASE_COMMIT"))
    |> Keyword.put_new(:repo, System.get_env("RELEASE_REPO"))
    |> Keyword.put_new(:version, System.get_env("RELEASE_VERSION"))
  end

  def help_text do
    ~s"""
    NAME:
       rprel - Build and create releases
    USAGE:
       rprel [global options] command [command options] [arguments...]
    VERSION:
      #{Rprel.version}
    AUTHOR(S):
      Tyler Long
      Colin Rymer
    COMMANDS:
      build
      help
      release
    GLOBAL OPTIONS:
      --help, -h           show help
      --version, -v        print the version
    COPYRIGHT:
      2016
    """
  end

  def build_help_text do
    ~s"""
    NAME:
       rprel build - Builds a release artifact

    USAGE:
       rprel build [command options] [arguments...]

    OPTIONS:
       --command CMD, -c CMD
           The CMD to run during the building of the artifact. If no command is
           provided and a Makefile is present, rprel will run `make build` if `build`
           is a valid Make target, otherwise falling back to just `make`. If no `CMD`
           is provided and there is no Makefile, nothing will be done during the
           build phase.
       --archive-command ARCHIVE_CMD, -a ARCHIVE_CMD
           The ARCHIVE_CMD to run during the artifact packaging phase. If no command
           is provided and a Makefile exists with an `archive` target, `make archive`
           will be run, otherwise, the source provided will be packaged into a
           gzipped tarball.
       --build-number NUMBER
           The NUMBER used by the CI service to identify the build` [$BUILD_NUMBER]
       --commit SHA
           The SHA of the build (default: `git rev-parse --verify HEAD`) [$GIT_COMMIT]
    """
  end

  def release_help_text do
    ~s"""
    NAME:
       rprel release - Creates GitHub release and upload artifacts

    USAGE:
       rprel release [command options] [arguments...]

    OPTIONS:
       --token TOKEN, -t TOKEN
           The GitHub authentication TOKEN [$GITHUB_AUTH_TOKEN]
       --commit SHA, -c SHA
           The commit SHA that will be used to create the release [$RELEASE_COMMIT]
       --repo OWNER/REPO, -r OWNER/REPO
           The full repo name, OWNER/REPO, where the release will be created [$RELEASE_REPO]
       --version VERSION, -v VERSION
           The release VERSION [$RELEASE_VERSION]
    """
  end
end
