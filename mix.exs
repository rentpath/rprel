defmodule Rprel.Mixfile do
  use Mix.Project

  def project do
    [app: :rprel,
     version: "1.1.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: Rprel.CLI],
     description: description(),
     package: package(),
     deps: deps]
  end

  defp description do
    """
    Rprel (arr-pee-rell) is a tool for creating GitHub releases from a build artifact.
    """
  end

  defp package do
    [
      maintainers: ["devadmin@rentpath.com"],
      links: %{"GitHub" => "https://github.com/rentpath/rprel"},
      licenses: ["The MIT License"]
    ]
  end

  def application do
    [applications: [:logger, :httpoison, :porcelain]]
  end

  defp deps do
    [{:bypass, "~> 0.1", only: :test},
     {:credo, "~> 0.4", only: [:dev, :test]},
     {:httpoison, "~> 0.8"},
     {:mix_test_watch, "~> 0.2", only: :dev},
     {:poison, "~>2.0"},
     {:porcelain, "~> 2.0.0"},
     {:timex, "~> 2.1.6"},
     {:uri_template, "~>1.0"}]
  end
end
