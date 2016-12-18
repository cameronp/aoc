defmodule FifteenTest do
  use ExUnit.Case
  doctest Fifteen

  test "examples" do
    disc1 = {_count = 5, _start = 4} 
    disc2 = {_count = 2, _start = 1} 

    assert Fifteen.position_at(disc1, 1) == 0
    assert Fifteen.position_at(disc2, 2) == 1
    assert Fifteen.position_at(disc1, 6) == 0
    assert Fifteen.position_at(disc2, 7) == 0
  end

  test "sequence" do
    disc1 = {_count = 5, _start = 4} 
    disc2 = {_count = 2, _start = 1} 

    list = [disc1, disc2]
    assert Fifteen.sequence(list, 0) == [0,1]
    assert Fifteen.sequence(list, 5) == [0,0]
  end

  @tag skip: "nyi"
  test "part1" do
    assert Fifteen.part1 == 301 
  end

  @tag skip: "nyi"
  test "part2" do
    assert Fifteen.part2 == 130 
  end
end
