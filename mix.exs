defmodule Rprel.Mixfile do
  use Mix.Project

  def project do
    [app: :rprel,
     version: "2.2.4",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: Rprel.CLI],
     description: description(),
     package: package(),
     deps: deps()]
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
    [extra_applications: [:logger]]
  end

  defp deps do
    [{:bypass, "~> 0.8.0", only: :test},
     {:credo, "~> 0.4", only: [:dev, :test]},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:httpoison, "~> 0.8"},
     {:mix_test_watch, "~> 0.2", only: :dev},
     {:poison, "~> 3.1"},
     {:porcelain, "~> 2.0.0"},
     {:timex, "~> 3.1.7"},
     # newer tzdata doesn't work from within an escript because it uses ETS
     {:tzdata, "~> 0.1.8", override: true},
     # examples don't even work on newer versions for uri_template
     {:uri_template, "~> 1.0.0"}]
  end
end
