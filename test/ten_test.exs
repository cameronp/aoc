defmodule TenTest do
  use ExUnit.Case
  doctest Ten

  alias Ten.{Robot, Bin}

  test "create robot" do
    dir = Robot.create_directory!
    r = Robot.start!(22, dir)
    assert Robot.lookup(dir, 22) == r
  end

  test "deliver" do
    dir = Robot.create_directory!
    Robot.deliver(dir, 75, 100)
    assert Robot.lookup(dir, 75) != nil
  end

  test "create bin" do
    dir = Robot.create_directory!
    r = Robot.start!(1, dir)
    b = Bin.start!(1, dir)
    assert Robot.lookup(dir, 1) == r
    assert Bin.lookup(dir, 1) == b
  end

  test "send to bin" do
    dir = Robot.create_directory!
    Bin.deliver(dir, 75, 100)
    assert Bin.lookup(dir, 75)
  end
  
  @tag skip: "nyi"
  test "part1" do
    assert Ten.part1 == 301 
  end

  @tag skip: "nyi"
  test "part2" do
    assert Ten.part2 == 130 
  end
end
