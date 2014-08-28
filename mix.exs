Code.ensure_loaded?(Hex) and Hex.start

defmodule Geo.Mixfile do
  use Mix.Project

  def project do
    [ app: :geo,
      version: "0.6.1",
      elixir: "~> 0.15.1",
      deps: deps,
      description: "A collection of GIS functions",
      package: package,
      source_url: "https://github.com/bryanjos/geo"    ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  defp deps do
    [{:jsex, github: "talentdeficit/jsex"}]
  end

  defp package do
    [ # These are the default files included in the package
      files: ["lib", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      contributors: ["Bryan Joseph"],
      licenses: ["MIT"],
      links: [ { "GitHub", "https://github.com/bryanjos/geo" }]
    ]
  end
end
