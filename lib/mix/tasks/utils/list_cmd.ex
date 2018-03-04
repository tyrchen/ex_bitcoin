defmodule ExBitcoinTask.GenerateRpc.ListCmd do
  @moduledoc """
  Process document for "bitcoin-cli help".
  """

  require Logger

  @regex ~r/==\s*(?<name>\w+)\s*==/
  @docs %{
    "Blockchain" => [ns: :Core, desc: "General blockchain RPC"],
    "Control" => [desc: "Control how bitcoin node works"],
    "Generating" => [desc: "Generating blocks and addresses"],
    "Mining" => [desc: "Mining RPC"],
    "Network" => [desc: "Network related RPC"],
    "Rawtransactions" => [ns: Tx, desc: "Raw transaction related RPC"],
    "Util" => [desc: "utility functions"],
    "Wallet" => [desc: "wallet related RPC"]
  }

  def format_response(data) do
    @regex
    |> Regex.split(data, include_captures: true)
    |> reject
    |> Enum.chunk_every(2)
    |> Enum.reduce(%{}, fn item, acc ->
      [name_str, values | _] = item
      name = format_name(name_str)
      doc = Map.get(@docs, name)
      ns = Keyword.get(doc, :ns, String.to_atom(name))
      desc = Keyword.get(doc, :desc, "")
      Map.put(acc, name, %{"ns" => ns, "desc" => desc, "items" => format_values(values)})
    end)
  end

  defp format_name(name) do
     %{"name" => name} = Regex.named_captures(@regex, name)
     name
  end

  defp format_values(values) do
    values
    |> String.trim
    |> String.split("\n")
    |> reject
    |> Enum.map(&get_first(&1, " "))
    |> reject(["help"])
  end

  defp get_first(str, sep), do: str |> String.split(sep) |> List.first

  defp reject(item, extra \\ []) do
    Enum.reject(item, fn name ->
      name= String.trim(name)
      name == "" || name in extra
    end)
  end
end
