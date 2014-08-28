Code.ensure_loaded?(Hex) and Hex.start

defmodule Geo.Mixfile do
  use Mix.Project

  def project do
    [ app: :geo,
      version: "0.7.0",
      elixir: "~> 0.15.1",
      deps: deps,
      description: description,
      package: package,
      source_url: "https://github.com/bryanjos/geo"    ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  defp description do
    """
    A collection of functions to convert to and from WKT, WKB, and GeoJSON.
    Also includes an encoder, decoder, and formatter for using PostGIS data types with Postgrex.

    """
  end

  defp deps do
    [{:jsex, github: "talentdeficit/jsex"},
    { :postgrex, "~> 0.5" }]
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
