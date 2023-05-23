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
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:crc32cer, "~> 0.1.8"},
      {:snappyer, "~> 1.2.7"},
      # Code generation
      {:jason, "~> 1.4", only: :dev},
      # Benchmarks and tests
      {:benchee, "~> 1.0", only: :dev}
    ]
  end
end
