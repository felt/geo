Code.ensure_loaded?(Hex) and Hex.start

defmodule Geo.Mixfile do
  use Mix.Project

  def project do
    [ app: :geo,
      version: "0.5.1",
      elixir: ">= 0.12.0",
      deps: deps,
      description: "A collection of GIS functions",
      package: package,
      source_url: "https://github.com/bryanjos/geo"    ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [{ :json,   github: "cblage/elixir-json"}]
  end

    defp package do
    [ # These are the default files included in the package
      files: ["lib", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      contributors: ["Bryan Joseph"],
      licenses: ["MIT"],
      links: [ { "GitHub", "https://github.com/bryanjos/geo" }] 
    ]
end
