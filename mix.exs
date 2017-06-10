defmodule Geo.Mixfile do
  use Mix.Project

  def project do
    [ app: :geo,
      version: "1.5.0",
      elixir: "~> 1.0",
      deps: deps(),
      description: description(),
      package: package(),
      name: "Geo",
      elixirc_paths: elixirc_paths(Mix.env),
      source_url: "https://github.com/bryanjos/geo"]
  end

  # Configuration for the OTP application
  def application do
    [
      applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp description do
    """
    PostGIS extension for Postgrex. Includes PostGIS types for Ecto.
    Also encodes and decodes WKB, WKT, and GeoJSON formats.
    """
  end

  defp deps do
    [
      {:ecto, "~> 2.1", optional: true },
      {:postgrex, "~> 0.13", optional: true },
      {:poison, "~> 1.5 or ~> 2.0 or ~> 3.0", optional: true},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end

  defp package do
    [ # These are the default files included in the package
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md"],
      maintainers: ["Bryan Joseph"],
      licenses: ["MIT"],
      links: %{ "GitHub" => "https://github.com/bryanjos/geo" }
    ]
  end
end
