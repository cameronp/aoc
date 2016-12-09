defmodule NineTest do
  use ExUnit.Case
  doctest Nine

  test "part1" do
    assert Nine.part1 == 99145
  end
  
  test "part1 examples" do
    assert Nine.Compression.decompress("ADVENT") == "ADVENT"
    assert Nine.Compression.decompress("A(1x5)BC") == "ABBBBBC"
    assert Nine.Compression.decompress("(3x3)XYZ") == "XYZXYZXYZ"
    assert Nine.Compression.decompress("A(2x2)BCD(2x2)EFG") == "ABCBCDEFEFG"
    assert Nine.Compression.decompress("(6x1)(1x3)A") == "(1x3)A"
    assert Nine.Compression.decompress("X(8x2)(3x3)ABCY") == "X(3x3)ABC(3x3)ABCY"
  end


  test "part2" do
    assert Nine.part2 == 10943094568
  end

end
