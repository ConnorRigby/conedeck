defmodule ConedeckTest do
  use ExUnit.Case
  doctest Conedeck

  test "greets the world" do
    assert Conedeck.hello() == :world
  end
end
