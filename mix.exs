defmodule Geo.Mixfile do
  use Mix.Project

  def project do
    [
      app: :geo,
      version: "2.1.0",
      elixir: "~> 1.4",
      deps: deps(),
      description: description(),
      package: package(),
      name: "Geo",
      source_url: "https://github.com/bryanjos/geo"
    ]
  end

  # Configuration for the OTP application
  def application do
    [
      applications: [:logger]
    ]
  end

  defp description do
    """
    Encodes and decodes WKB, WKT, and GeoJSON formats.
    """
  end

  defp deps do
    [
      {:ecto, "~> 2.1", optional: true},
      {:poison, "~> 3.0", optional: true},
      {:ex_doc, "~> 0.18", only: :dev}
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md"],
      maintainers: ["Bryan Joseph"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/bryanjos/geo"}
    ]
  end
end
