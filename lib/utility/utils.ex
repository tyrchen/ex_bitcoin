defmodule ExBitcoinUtils do
  @moduledoc """
  Utility functions
  """
  def load_json(filename) do
    filename
    |> File.read!()
    |> Poison.decode!()
  end

  def gen_spec(args) do
    # TODO: this is fake now
    Enum.map(args, fn _ -> String.to_atom("String.t") end)
  end

  def gen_args(args, ctx \\ nil) do
    # TODO: generate default values
    Enum.map(args, fn %{"name" => name} -> Macro.var(String.to_atom(name), ctx) end)
  end
end
