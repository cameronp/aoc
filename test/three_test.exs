defmodule ThreeTest do
  use ExUnit.Case
  doctest Three

  test "part1" do
    assert Three.part1 == 862 
  end

  test "part2" do
    assert Three.part2 == 1577
  end
end
