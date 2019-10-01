defmodule StreamStats.MixProject do
  use Mix.Project
  @version "0.1.1"
  @url "https://github.com/whossname/stream_stats"
  @maintainers ["Tyson Buzza"]

  def project do
    [
      app: :stream_stats,
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "StreamStats",
      description: "Concurrent calculation of count, mean and standard deviation",
      source_url: @url,
      homepage_url: @url,
      package: package(),
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def package do
    [
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{"GitHub" => @url},
      files: ~w(lib) ++ ~w(LICENSE.md mix.exs README.md)
    ]
  end

  def docs do
    [
      extras: ["README.md", "LICENSE.md"],
      source_ref: "v#{@version}",
      main: "readme"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:propcheck, "~> 1.1", only: [:test, :dev]}
    ]
  end
end
