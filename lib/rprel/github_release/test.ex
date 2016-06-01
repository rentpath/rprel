defmodule Rprel.GithubRelease.Test do
  @behaviour Rprel.GithubRelease
  def create(release) do
    %{release | id: "1", upload_url: "https://uploads.github.com/repos/octocat/Hello-World/releases/1/assets{?name,label}"}
  end
end
