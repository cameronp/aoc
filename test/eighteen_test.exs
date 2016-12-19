defmodule EighteenTest do
  use ExUnit.Case
  doctest Eighteen

  import Eighteen

  test "parse" do
    assert parse_line("..^^.") == [:s, :s, :t, :t, :s]
  end

  test "next" do
    start = "..^^." |> parse_line
    step1 = start |> next
    step2 = step1 |> next
    
    assert step1 == parse_line(".^^^^")
    assert step2 == parse_line("^^..^")
  end


  test "part1" do
    assert Eighteen.part1 == 2035
  end

  @tag skip: "slow"
  test "part2" do
    assert Eighteen.part2 == 20000577
  end
end
