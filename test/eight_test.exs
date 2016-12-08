defmodule EightTest do
  use ExUnit.Case
  doctest Eight
  alias Eight.Screen  

  test "set" do
    s = Screen.new(10,10) |> Screen.set({5,5})
    assert Screen.get(s, {5, 5})
    refute Screen.get(s, {4, 4})
  end

  test "clear" do
    s = Screen.new(10,10) |> Screen.set({5,5}) |> Screen.clear({5,5})
    refute Screen.get(s, {5, 5})
    refute Screen.get(s, {4, 4})
  end

  test "rect" do
    s = Screen.new(10,10) |> Screen.rect(3,2)
    for x <- 0..2, y <-0..1, 
      do: assert Screen.get(s, {x,y})
  end

  test "rotate row, wraps" do
    s = 
      Screen.new(5,5)
      |> Screen.set({4,1})
      |> Screen.rotate(:row, 1, 1)
    assert Screen.get(s,{0,1})
    refute Screen.get(s,{4,1})
  end

  test "rotate column, wraps" do
    s = 
      Screen.new(5,5)
      |> Screen.set({4,1})
      |> Screen.rotate(:column, 4, 4)
    assert Screen.get(s,{4,0})
    refute Screen.get(s,{4,4})
  end

  test "dump row" do
    s = 
      Screen.new(5,5)
      |> Screen.set({4,1})
    assert Screen.dump(s, :row, 1) == "....#"
  end

  test "dump column" do
    s = 
      Screen.new(5,5)
      |> Screen.set({4,1})
    assert Screen.dump(s, :column, 4) == ".#..."
  end


  test "part1" do
    assert Eight.part1 == 123
  end

  @tag skip: "nyi"
  test "part2" do
    assert Seven.part2 == 231
  end
end
