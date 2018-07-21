defmodule ExBitcoin.MixProject do
  use Mix.Project

  @version File.cwd!() |> Path.join("version") |> File.read!() |> String.trim()
  @elixir_version File.cwd!() |> Path.join(".elixir_version") |> File.read!() |> String.trim()

  def project do
    [
      app: :ex_bitcoin,
      version: @version,
      elixir: @elixir_version,
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),

      # exdocs
      # Docs
      name: "ExBitcoin",
      source_url: "https://github.com/tyrchen/ex_bitcoin",
      homepage_url: "https://github.com/tyrchen/ex_bitcoin",
      docs: [
        main: "ExBitcoin",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:auto_error, "~> 0.1.0"},
      {:decimal, "~> 1.1"},
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.0"},

      # Dev & Test
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.18", only: [:dev, :test]},
      {:pre_commit_hook, "~> 1.2", only: [:dev]}
    ]
  end

  defp description do
    """
    Yet another bitcoin elixir RPC library. Completely generated against bitcoin cli.
    """
  end

  defp package do
    [
      files: ["lib", "priv", "mix.exs", "README*", "LICENSE*", "version", ".elixir_version"],
      licenses: ["MIT"],
      maintainers: ["tyr.chen@gmail.com"],
      links: %{
        "GitHub" => "https://github.com/tyrchen/ex_bitcoin",
        "Docs" => "https://hexdocs.pm/ex_bitcoin"
      }
    ]
  end
end
