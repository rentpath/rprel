defmodule Rprel.CLI do
  @moduledoc """
  Cli args for rprel
  """

  alias Rprel.Build
  alias Rprel.ReleaseCreator
  alias Rprel.Messages

  @main_flags [help: :boolean, version: :boolean]
  @main_aliases [h: :help, v: :version]

  @build_flags [help: :boolean, build_number: :string, commit: :string, path: :string]
  @build_aliases [h: :help]

  @release_flags [help: :boolean, token: :string, commit: :string, repo: :string, version: :string]
  @release_aliases [h: :help, t: :token, c: :commit, r: :repo, v: :version]

  @system Application.get_env(:rprel, :system)

  def main(argv) do
    {opts, args, _invalid_opts} =
      OptionParser.parse_head(argv, strict: @main_flags, aliases: @main_aliases)

    result = case args do
      ["help" | cmd] -> help(cmd)
      ["build" | build_argv] -> build(build_argv)
      ["release" | release_argv] -> release(release_argv)
      _ -> handle_other_commands(opts)
    end

    case result do
      {:error, message} ->
        IO.puts(message)
        @system.halt(1)
      {:ok, message } ->
        if String.length(String.trim(message)) > 0, do: IO.puts(message)
        result
    end
  end

  def help(cmd) do
    case cmd do
      ["build"] -> {:ok, Messages.build_help_text}
      ["release"] -> {:ok, Messages.release_help_text}
      _ -> {:error, "No help topic for '#{cmd}'"}
    end
  end

  def build(build_argv) do
    {build_opts, _build_args, _invalid_opts} =
      parse_args(build_argv, @build_flags, @build_aliases)

    if build_opts[:help] do
      {:ok, Messages.build_help_text}
    else
      build_opts
      |> update_with_build_env_vars
      |> Build.create
    end
  end

  def release(release_argv) do
    {release_opts, release_args, _invalid_opts} =
      parse_args(release_argv, @release_flags, @release_aliases)

    if release_opts[:help] do
      {:ok, Messages.release_help_text}
    else
      release_opts
      |> update_with_release_env_vars
      |> ReleaseCreator.create(release_args)
    end
  end

  def handle_other_commands(opts) do
    cond do
      opts[:help] -> {:ok, Messages.help_text}
      opts[:version] -> {:ok, Rprel.version}
      true -> {:ok, Messages.help_text}
    end
  end

  defp parse_args(argv, flags, aliases) do
    OptionParser.parse(argv, strict: flags, aliases: aliases)
  end

  defp update_with_release_env_vars(opts) do
    opts
    |> Keyword.put_new(:token, System.get_env("GITHUB_AUTH_TOKEN"))
    |> Keyword.put_new(:commit, System.get_env("RELEASE_COMMIT"))
    |> Keyword.put_new(:repo, System.get_env("RELEASE_REPO"))
    |> Keyword.put_new(:version, System.get_env("RELEASE_VERSION"))
  end

  def update_with_build_env_vars(opts) do
    opts
    |> Keyword.put_new(:commit, System.get_env("GIT_COMMIT"))
    |> Keyword.put_new(:build_number, System.get_env("BUILD_NUMBER"))
  end
end
