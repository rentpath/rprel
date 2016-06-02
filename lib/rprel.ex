defmodule Rprel do
  def version do
    {:ok, vsn} = :application.get_key(:rprel, :vsn)
    List.to_string(vsn)
  end
end
