defmodule Rprel.GithubRelease do
  @moduledoc """
  Struct used to create a Github Release from a build artifact
  """

  @callback create_release(release :: %__MODULE__{},
                           files :: list | String.t,
                           creds :: [token: String.t]) :: {:ok, id :: String.t} | {:error, msg :: String.t}
  @callback valid_token?(token :: String.t) :: boolean

  defstruct [:name, :version, :commit, :id, :upload_url, :branch]
end
