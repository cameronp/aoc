defmodule NineteenTest do
  use ExUnit.Case
  doctest Nineteen

  import Nineteen

  test "setup circle" do
    assert setup_circle(5) == [{1,1}, {2,1}, {3,1}, {4,1}, {5,1}]
  end

  @tag skip: "nyi"
  test "part1" do
    assert Nineteen.part1 == 2035
  end

  @tag skip: "nyi"
  test "part2" do
    assert Nineteen.part2 == 20000577
  end
end
