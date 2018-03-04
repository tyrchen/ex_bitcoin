defmodule ExBitcoinUtils do
  def load_json(filename) do
    filename
    |> File.read!
    |> Poison.decode!
  end

  def gen_spec(args) do
    Enum.map(args, fn _ -> String.to_atom("Elixir.String.t") end)
  end

  def gen_args(args, ctx \\ nil) do
    Enum.map(args, fn %{"name" => name} -> Macro.var(String.to_atom(name), ctx) end)
  end

end