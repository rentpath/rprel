defmodule Rprel.System.Test do
  @moduledoc """
  Test module for ExUnit that prevents system exit, which would stop unit tests
  from running to completion
  """

  def halt(status) do
  end
end
