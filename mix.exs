defmodule KlifeProtocol.MixProject do
  use Mix.Project

  def project do
    [
      app: :klife_protocol,
      version: "0.7.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      # hex
      description: description(),
      package: package(),
      # docs
      name: "Klife Protocol",
      source_url: "https://github.com/oliveigah/klife_protocol",
      docs: [
        main: "readme",
        extras: ["README.md"],
        assets: "assets",
        api_reference: true,
        filter_modules: ~r"KlifeProtocol.Messages.*|KlifeProtocol.Header",
        nest_modules_by_prefix: [KlifeProtocol.Messages]
      ]
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

  defp description() do
    "An Elixir implementation of the Kafka protocol. It enables communication with Kafka brokers using standard Elixir data structures without the need for manual serialization."
  end

  defp package() do
    [
      # These are the default files included in the package
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/oliveigah/klife_protocol"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # CRC
      {:crc32cer, "~> 0.1.11"},
      # Compression
      {:snappyer, "~> 1.2.10"},
      # Code generation
      {:jason, "~> 1.4", only: :dev, runtime: false},
      # Benchmarks and tests
      {:benchee, "~> 1.0", only: :dev, runtime: false},
      # Docs
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
