defmodule TwelveTest do
  use ExUnit.Case
  doctest Twelve

  @tag skip: "nyi"
  test "part1" do
    assert Twelve.part1 == 301 
  end

  @tag skip: "nyi"
  test "part2" do
    assert Twelve.part2 == 130 
  end
end
