defmodule FifteenTest do
  use ExUnit.Case
  doctest Fifteen

  test "part1" do
    assert Fifteen.part1 == 148737
  end

  test "part2" do
    assert Fifteen.part2 == 2353212
  end
end
