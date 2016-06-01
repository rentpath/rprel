defmodule Rprel.ReleaseCreatorTest do
  use ExUnit.Case

  test "it creates a GitHub release" do
    release = %Rprel.GithubRelease{name: "rentpath/ag", version: "v1.0.0", commitish: "1a2b3c4"}
    created_release = Rprel.ReleaseCreator.create(release)
    assert created_release.id != nil
    assert created_release.upload_url != nil
  end
end
