defmodule Mix.Tasks.ExBitcoin.Run do
  @moduledoc """
  This CLI utilize the functionality of bitcoin-cli. If you want to generate your own elixir RPC with this CLI, please install bitcoin firstly.
  """
  use Mix.Task
  require Logger
  alias ExBitcoinTask.GenerateRpc.SingleCmd

  @list_cmd "bitcoin-cli help"

  def run(name) do
    (@list_cmd <> " #{List.first(name)}")
    |> run_bitcoin_cli
    |> SingleCmd.format_response()
  end

  defp run_bitcoin_cli(cmd) do
    cmd
    |> to_charlist
    |> :os.cmd()
    |> to_string
  end
end
