defmodule KlifeProtocol.MixProject do
  use Mix.Project

  def project do
    [
      app: :klife_protocol,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Code generation
      {:jason, "~> 1.4", only: :dev},
      # Benchmarks
      {:benchee, "~> 1.0", only: :dev},
      {:crc32cer, "~> 0.1.8", only: :dev},
      {:kafka_protocol, "~> 4.1", only: :dev},
      {:varint, "~>1.2.0", only: :dev},
      {:kayrock, "~> 0.1.15", only: :dev}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
