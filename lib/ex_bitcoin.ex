defmodule ExBitcoin do
  @moduledoc """
  Documentation for ExBitcoin.
  """

  require ExBitcoinUtils.Gen
  alias ExBitcoinUtils.Gen

  path =
    :ex_bitcoin
    |> Application.app_dir()
    |> Path.join("priv/rpc")

  path
  |> File.ls!()
  |> Enum.map(&Path.join(path, &1))
  |> Enum.map(&Gen.module/1)
end
