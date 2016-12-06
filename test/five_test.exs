defmodule FiveTest do
  use ExUnit.Case
  doctest Five
  
  @moduletag timeout: 120_000

  @tag skip: "slow test"
  test "part1" do
    assert Five.part1 == "F97C354D" 
  end

  @tag skip: "slow test"
  test "part2" do
    assert Five.part2 == "863DDE27"
  end
end
