defmodule Rprel.GithubRelease do
  @callback create(release :: %__MODULE__{}) :: %__MODULE__{}
  defstruct [:name, :version, :commitish, :id, :upload_url]
end
