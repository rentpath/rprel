defmodule Rprel.CLITest do
  use ExUnit.Case, async: true

  alias Rprel.Messages

  @ok_resp {:ok, ""}

  @commit "abc1234"
  @repo "rentpath/test-bed"
  @token "iamatoken"
  @version "v1.0.0"
  @release_cmd ["release", "--repo", @repo, "--token", @token, "--commit", @commit, "--version", @version, __ENV__.file]

  test "it returns help text if called with no args" do
    assert Rprel.CLI.do_main([]) == {:ok, Messages.help_text}
  end

  test "it returns the help text if called with either --help or -h" do
    assert Rprel.CLI.do_main(["--help"]) == {:ok, Messages.help_text}
    assert Rprel.CLI.do_main(["-h"]) == {:ok, Messages.help_text}
  end

  test "it returns the version if called with either --version or -v" do
    assert Rprel.CLI.do_main(["-v"]) == {:ok, Rprel.version}
    assert Rprel.CLI.do_main(["--version"]) == {:ok, Rprel.version}
  end

  test "it shows help for the build command" do
    assert Rprel.CLI.do_main(["help", "build"]) == {:ok, Messages.build_help_text}
    assert Rprel.CLI.do_main(["build", "--help"]) == {:ok, Messages.build_help_text}
    assert Rprel.CLI.do_main(["build", "-h"]) == {:ok, Messages.build_help_text}
  end

  test "it shows help for the release command" do
    assert Rprel.CLI.do_main(["help", "release"]) == {:ok, Messages.release_help_text}
    assert Rprel.CLI.do_main(["release", "--help"]) == {:ok, Messages.release_help_text}
    assert Rprel.CLI.do_main(["release", "-h"]) == {:ok, Messages.release_help_text}
  end

  test "a release is created when given the required args" do
    result = Rprel.CLI.do_main(@release_cmd)
    assert result == @ok_resp
  end

  test "a repo name is required when releasing" do
    result = Rprel.CLI.do_main(@release_cmd |> List.delete("--repo") |> List.delete(@repo))
    assert result == {:error, Messages.invalid_repo_name_msg}
  end

  test "a version name is required when releasing" do
    result = Rprel.CLI.do_main(@release_cmd |> List.delete("--version") |> List.delete(@version))
    assert result == {:error, Messages.invalid_version_msg}
  end

  test "a commit name is required when releasing" do
    result = Rprel.CLI.do_main(@release_cmd |> List.delete("--commit") |> List.delete(@commit))
    assert result == {:error, Messages.invalid_commit_msg}
  end

  test "an auth token is required when releasing" do
    result = Rprel.CLI.do_main(@release_cmd |> List.delete("--token") |> List.delete(@token))
    assert result == {:error, Messages.invalid_token_msg}
  end

  test "at least one file is required when releasing" do
    result = Rprel.CLI.do_main(@release_cmd |> List.delete(__ENV__.file))
    assert result == {:error, Messages.invalid_files_msg}
  end

  test "the repo can be specified through an env var" do
    System.put_env("RELEASE_REPO", @repo)
    result = Rprel.CLI.do_main(@release_cmd |> List.delete("--repo") |> List.delete(@repo))
    assert result == @ok_resp
    System.delete_env("RELEASE_REPO")
  end

  test "the version can be specified through an env var" do
    System.put_env("RELEASE_VERSION", @version)
    result = Rprel.CLI.do_main(@release_cmd |> List.delete("--version") |> List.delete(@version))
    assert result == @ok_resp
    System.delete_env("RELEASE_VERSION")
  end

  test "the commit can be specified through an env var" do
    System.put_env("RELEASE_COMMIT", @commit)
    result = Rprel.CLI.do_main(@release_cmd |> List.delete("--commit") |> List.delete(@commit))
    assert result == @ok_resp
    System.delete_env("RELEASE_COMMIT")
  end

  test "the auth token can be specified through an env var" do
    System.put_env("GITHUB_AUTH_TOKEN", @token)
    result = Rprel.CLI.do_main(@release_cmd |> List.delete("--token") |> List.delete(@token))
    assert result == @ok_resp
    System.delete_env("GITHUB_AUTH_TOKEN")
  end

  #TODO test case for already created release
end
