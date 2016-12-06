defmodule FourTest do
  use ExUnit.Case
  doctest Four

  test "part1" do
    assert Four.part1 == 409147 
  end

  test "part2" do
    assert Four.part2 == 991
  end
end
