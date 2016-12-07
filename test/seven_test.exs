defmodule SevenTest do
  use ExUnit.Case
  doctest Seven
    
  test "sample 1" do
    assert Seven.TLS.supported?("abba[mnop]qrst")
  end


  test "sample 2" do
    refute Seven.TLS.supported?("abcd[bddb]xyyx")
  end

  test "sample 3" do
    refute Seven.TLS.supported?("aaaa[qwer]tyui")
  end

  test "sample 4" do
    assert Seven.TLS.supported?("ioxxoj[asdfgh]zxcvbn")
  end


  test "sample 5" do
    assert Seven.SSL.supported?("aba[bab]xyz")
  end

  test "sample 6" do
    refute Seven.SSL.supported?("xyx[xyx]xyx")
  end

  test "sample 7" do
    assert Seven.SSL.supported?("aaa[kek]eke")
  end

  test "sample 8" do
    assert Seven.SSL.supported?("zazbz[bzb]cdb")
  end

  test "part1" do
    assert Seven.part1 == 115
  end

  test "part2" do
    assert Seven.part2 == 231
  end
end
