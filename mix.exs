defmodule Geo.Mixfile do
  use Mix.Project

  @source_url "https://github.com/felt/geo"
  @version "3.6.0"

  def project do
    [
      app: :geo,
      version: @version,
      elixir: "~> 1.10",
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
      {:jason, "~> 1.4", optional: true},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:stream_data, "~> 0.5 or ~> 1.0", only: :test, runtime: false},
      {:benchee, "~> 1.1", only: :dev, runtime: false}
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      files: ["lib", "mix.exs", "README.md", "CHANGELOG.md"],
      maintainers: ["Tyler Young", "Bryan Joseph"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/felt/geo"}
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
