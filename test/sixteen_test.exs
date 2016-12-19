defmodule SixteenTest do
  use ExUnit.Case
  doctest Sixteen

  test "inverter" do
    assert Sixteen.invert("1001") == "0110"
  end

  test "expander" do
    assert Sixteen.expand("1") == "100"
    assert Sixteen.expand("0") == "001"
    assert Sixteen.expand("11111") == "11111000000"
    assert Sixteen.expand("111100001010") == "1111000010100101011110000"
  end

  test "all together now" do
    data = Sixteen.fill("10000", 20)
    assert Sixteen.checksum(data) == "01100"
  end

  test "checksum" do
    assert Sixteen.checksum("110010110100") == "100"
  end

  test "generator" do
    assert Sixteen.generate("10000", 20) == "10000011110010000111110"
  end

  test "filler" do
    assert Sixteen.fill("10000", 20) == "10000011110010000111"
  end

  @tag skip: "nyi"
  test "part1" do
    assert Sixteen.part1 == 301 
  end

  @tag skip: "nyi"
  test "part2" do
    assert Sixteen.part2 == 130 
  end
end
