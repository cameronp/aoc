defmodule NineTest do
  use ExUnit.Case
  doctest Nine

  alias Nine.{Compression, Super}

  test "part1" do
    assert Nine.part1 == 99145
  end
  
  test "part1 examples" do
    assert Compression.decompress("ADVENT") == "ADVENT"
    assert Compression.decompress("A(1x5)BC") == "ABBBBBC"
    assert Compression.decompress("(3x3)XYZ") == "XYZXYZXYZ"
    assert Compression.decompress("A(2x2)BCD(2x2)EFG") == "ABCBCDEFEFG"
    assert Compression.decompress("(6x1)(1x3)A") == "(1x3)A"
    assert Compression.decompress("X(8x2)(3x3)ABCY") == "X(3x3)ABC(3x3)ABCY"
  end


  test "part2" do
    assert Nine.part2 == 10943094568
  end


  test "part2 examples" do
    assert Super.decompress("ADVENT") == "ADVENT"
    assert Super.decompress("(3x3)XYZ") == "XYZXYZXYZ"
    assert Super.decompress("X(8x2)(3x3)ABCY") == "XABCABCABCABCABCABCY"
    as = Super.decompress("(27x12)(20x12)(13x14)(7x10)(1x12)A") 
    assert String.length(as) == 241920
    as2 = Super.decompress("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN")
    assert String.length(as2) == 445
    assert Super.decompress("ADVENT") == "ADVENT"
  end
end
