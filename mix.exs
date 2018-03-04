defmodule ExBitcoin.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_bitcoin,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:auto_error, "~> 0.1.0"},
      {:decimal,   "~> 1.1"},
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.0"},
    ]
  end
end
