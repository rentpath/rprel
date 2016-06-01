defmodule Rprel.ReleaseCreator do
  @github_api Application.get_env(:rprel, :github_api)
  def create(release) do
    @github_api.create(release)
    %{release | id: 1, upload_url: "i'm a url"}
  end
end
