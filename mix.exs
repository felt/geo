defmodule Geo.Mixfile do
  use Mix.Project

  @source_url "https://github.com/bryanjos/geo"
  @version "3.4.1"

  def project do
    [
      app: :geo,
      version: @version,
      elixir: "~> 1.6",
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "Geo"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Encodes and decodes WKB, WKT, and GeoJSON formats.
    """
  end

  defp deps do
    [
      {:jason, "~> 1.2", optional: true},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:stream_data, "~> 0.5", only: :test, runtime: false},
      {:benchee, "~> 1.0", only: :dev, runtime: false}
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

  defp docs do
    [
      extras: ["CHANGELOG.md", "README.md"],
      main: "readme",
      source_url: @source_url,
      formatters: ["html"]
    ]
  end
end
