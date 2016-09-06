defmodule Rprel.CLITest do
  use ExUnit.Case, async: true

  alias Rprel.Messages
  import ExUnit.CaptureIO
  import Rprel.CLI

  @ok_resp {:ok, ""}

  @commit "abc1234"
  @repo "rentpath/test-bed"
  @token "iamatoken"
  @version "v1.1.2"
  @release_cmd ["release", "--repo", @repo, "--token", @token, "--commit", @commit, "--version", @version, __ENV__.file]

  test "it returns help text if called with no args" do
    message =
      capture_io(fn ->
        main([])
      end)
      |> String.trim

    assert message == String.trim(Messages.help_text)
  end

  test "it returns the help text if called with --help" do
    message =
      capture_io(fn ->
        main(["--help"])
      end)
      |> String.trim

    assert message == String.trim(Messages.help_text)
  end

  test "it returns the help text if called with -h" do
    message =
      capture_io(fn ->
        main(["-h"])
      end)
      |> String.trim

    assert message == String.trim(Messages.help_text)
  end

  test "it returns the version if called with --version" do
    message =
      capture_io(fn ->
        main(["--version"])
      end)
      |> String.trim

    assert message == String.trim(Rprel.version)
  end

  test "it returns the version if called with -v" do
    message =
      capture_io(fn ->
        main(["-v"])
      end)
      |> String.trim

    assert message == String.trim(Rprel.version)
  end

  test "it shows help for the build command" do
    capture_io(fn ->
      assert main(["help", "build"]) == {:ok, Messages.build_help_text}
      assert main(["build", "--help"]) == {:ok, Messages.build_help_text}
      assert main(["build", "-h"]) == {:ok, Messages.build_help_text}
    end)
  end

  test "it shows help for the release command" do
    capture_io(fn ->
      assert main(["help", "release"]) == {:ok, Messages.release_help_text}
      assert main(["release", "--help"]) == {:ok, Messages.release_help_text}
      assert main(["release", "-h"]) == {:ok, Messages.release_help_text}
    end)
  end

  test "a release is created when given the required args" do
    result = main(@release_cmd)
    assert result == @ok_resp
  end

  test "a repo name is required when releasing" do
    result =
      capture_io(fn ->
        main(@release_cmd |> List.delete("--repo") |> List.delete(@repo))
      end)
      |> String.trim

    assert result == Messages.invalid_repo_name
  end

  test "a version name is required when releasing" do
    result =
      capture_io(fn ->
        main(@release_cmd
                |> List.delete("--version")
                |> List.delete(@version))
      end)
      |> String.trim

    assert result == Messages.invalid_version
  end

  test "a commit name is required when releasing" do
    result =
      capture_io(fn ->
        main(@release_cmd |> List.delete("--commit") |> List.delete(@commit))
      end)
      |> String.trim

    assert result == Messages.invalid_commit
  end

  test "an auth token is required when releasing" do
    result =
      capture_io(fn ->
        main(@release_cmd |> List.delete("--token") |> List.delete(@token))
      end)
      |> String.trim

    assert result == Messages.invalid_auth_token
  end

  test "at least one file is required when releasing" do
    result =
      capture_io(fn ->
        main(@release_cmd |> List.delete(__ENV__.file))
      end)
      |> String.trim

    assert result == Messages.invalid_files
  end

  test "the repo can be specified through an env var" do
    System.put_env("RELEASE_REPO", @repo)
    result = main(@release_cmd |> List.delete("--repo") |> List.delete(@repo))
    assert result == @ok_resp
    System.delete_env("RELEASE_REPO")
  end

  test "the version can be specified through an env var" do
    System.put_env("RELEASE_VERSION", @version)
    result = main(@release_cmd |> List.delete("--version") |> List.delete(@version))
    assert result == @ok_resp
    System.delete_env("RELEASE_VERSION")
  end

  test "the commit can be specified through an env var" do
    System.put_env("RELEASE_COMMIT", @commit)
    result = main(@release_cmd |> List.delete("--commit") |> List.delete(@commit))
    assert result == @ok_resp
    System.delete_env("RELEASE_COMMIT")
  end

  test "the auth token can be specified through an env var" do
    System.put_env("GITHUB_AUTH_TOKEN", @token)
    result = main(@release_cmd |> List.delete("--token") |> List.delete(@token))
    assert result == @ok_resp
    System.delete_env("GITHUB_AUTH_TOKEN")
  end

  #TODO test case for already created release
end
