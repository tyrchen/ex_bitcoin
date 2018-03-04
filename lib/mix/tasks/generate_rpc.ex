defmodule Mix.Tasks.ExBitcoin.GenerateRpc do
  @moduledoc """
  This CLI utilize the functionality of bitcoin-cli. If you want to generate your own elixir RPC with this CLI, please install bitcoin firstly.
  """
  use Mix.Task
  require Logger
  alias ExBitcoin.GenerateRpc.{ListCmd, SingleCmd}

  @list_cmd "bitcoin-cli help"

  def run(_) do
    IO.puts "Scraping #{@list_cmd}"
    data =
      @list_cmd
      |> run_bitcoin_cli
      |> ListCmd.format_response
      |> Enum.map(fn {k, data} ->
        items =
          data
          |> Map.get("items", [])
          |> process_commands
        content = Map.put(data, "items", items)
        write_file("#{String.downcase(k)}.json", content)
      end)
  end

  defp run_bitcoin_cli(cmd) do
    cmd
    |> to_charlist
    |> :os.cmd()
    |> to_string
  end

  defp process_commands(commands) do
    Enum.map(commands, fn cmd_name ->
      cli = @list_cmd <> " #{cmd_name}"

      IO.puts "Scraping #{cli}"

      cli
      |> run_bitcoin_cli
      |> SingleCmd.format_response
      |> IO.inspect
    end)
  end

  defp write_file(filename, content) do
    path =
      :ex_bitcoin
      |> Application.app_dir
      |> Path.join("priv/rpc/#{filename}")

    case Poison.encode_to_iodata(content, pretty: true) do
      {:ok, data} -> File.write!(path, data)
      err           ->
        IO.inspect(content)
        throw(err)
    end
  end
end
