defmodule TwoTest do
  use ExUnit.Case
  doctest Two

  test "part1" do
    assert Two.part1 == "19636" 
  end

  test "part2" do
    assert Two.part2 == "3CC43" 
  end
end
