defmodule Rprel.Mixfile do
  use Mix.Project

  def project do
    [app: :rprel,
     version: "1.0.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: Rprel.CLI],
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [{:poison, "~>2.0"},
     {:httpoison, "~> 0.8"},
     {:uri_template, "~>1.0"},
     {:bypass, "~> 0.1", only: :test},
     {:mix_test_watch, "~> 0.2", only: :dev},
     {:timex, "~> 2.1.6"}]
  end
end
