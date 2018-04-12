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
      source_url: "https://github.com/bryanjos/geo",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
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
      {:poison, "~> 3.0", only: :test},
      {:ex_doc, "~> 0.18", only: :dev},
      {:excoveralls, "~> 0.8.1", only: :test}
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
