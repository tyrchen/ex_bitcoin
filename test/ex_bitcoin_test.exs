defmodule ExBitcoinTest do
  use ExUnit.Case
  doctest ExBitcoin

  test "greets the world" do
    assert ExBitcoin.hello() == :world
  end
end
