defmodule SixTest do
  use ExUnit.Case
  doctest Six
    
  test "part1" do
    assert Six.part1 == "qzedlxso" 
  end

  test "part2" do
    assert Six.part2 == "ucmifjae"
  end
end
