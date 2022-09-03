defmodule KAFETest do
  use ExUnit.Case
  doctest KAFE

  test "greets the world" do
    assert KAFE.hello() == :world
  end
end
