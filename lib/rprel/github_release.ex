defmodule Rprel.GithubRelease do
  @moduledoc """
  Struct used to create a Github Release from a build artifact
  """
  @callback create_release(
    release :: %__MODULE__{},
    files :: list | binary,
    creds :: [token: binary]) :: {:ok, id :: binary} | {:error, msg :: binary}
  @callback valid_token?(token :: binary) :: boolean

  defstruct [:name, :version, :commit, :id, :upload_url]
end
