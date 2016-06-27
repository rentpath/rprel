defmodule Rprel.ReleaseCreatorTest do
  use ExUnit.Case, async: true
  import Rprel.ReleaseCreator

  @files [__ENV__.file, __ENV__.file]
  @token  [token: "token"]
  @name "rentpath/test-bed"
  @version "v1.0.0"
  @commit "1a2b3c4"

  @release %Rprel.GithubRelease{name: @name, version: @version, commit: @commit}

  test "it creates a GitHub release" do
    release = %Rprel.GithubRelease{name: @name, version: @version, commit: @commit}
    created_release = create(release, @files, @token)
    assert {:ok, [id: _]} = created_release
  end

  test "a repo name is required" do
    resp = create(struct(@release, name: nil), @files, @token)
    assert resp == {:error, :invalid_repo_name}
  end

  test "the repo name must have a owner and repo" do
    resp = create(struct(@release, name: "test-bed"), @files, @token)
    assert resp == {:error, :invalid_repo_name}
  end

  test "a version is required" do
    resp = create(struct(@release, version: nil), @files, @token)
    assert resp == {:error, :missing_version}
  end

  test "a commit sha is required" do
    resp = create(struct(@release, commit: nil), @files, @token)
    assert resp == {:error, :missing_commit}
  end

  test "at least one file must be provided" do
    resp = create(@release, nil, @token)
    assert resp == {:error, :missing_files}
  end

  test "the provided files must be readable" do
    resp = create(@release, ["filethatdoesnotexist.txt"], @token)
    assert resp == {:error, :unreadable_files}
  end

  test "an auth token must be provided" do
    resp = create(@release, @files, nil)
    assert resp == {:error, :invalid_auth_token}
  end

  test "the auth token cannot be an empty binary" do
    resp = create(@release, @files, token: "")
    assert resp == {:error, :invalid_auth_token}
  end
end
