defmodule OneTest do
  use ExUnit.Case
  doctest One

  test "part1" do
    assert One.part1 == 301 
  end

  test "part2" do
    assert One.part2 == 130 
  end
end
