defmodule Rprel do
  @moduledoc """
  Top level module for building and releasing build artifacts
  """

  def version do
    {:ok, vsn} = :application.get_key(:rprel, :vsn)
    List.to_string(vsn)
  end
end
