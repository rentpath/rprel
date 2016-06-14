defmodule Rprel.GithubRelease.Test do
  @moduledoc """
  Stubbed Github backend for Unit Tests
  """

  @behaviour Rprel.GithubRelease

  def create_release(_ = %Rprel.GithubRelease{}, _, [token: _]) do
    {:ok, "1"}
  end

  def valid_token?(token) do
    is_binary(token) && String.length(token) != 0
  end
end
