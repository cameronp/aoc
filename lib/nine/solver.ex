defmodule Nine.Solver do
  import Utils.Parsing

  def part1(filename \\ "data/nine/input.txt"), do: solve(filename)

  def part2(filename \\ "data/nine/input.txt"), do: solve2(filename)

  def solve(filename) do
    filename
    |> load
    |> process
    |> compute
  end

  def solve2(filename) do
    filename
    |> load
    |> process2
    |> compute2
  end
  
  def load(file) do
    file
    |> readfile
    |> split_and_map("\n", &String.strip/1)
    |> Enum.join("")
  end

  def process(data), do: data |> Nine.Super.parse(:one)

  def compute(data), do: data |> Nine.Super.len 

  def process2(data), do: data |> Nine.Super.parse(:two)

  def compute2(elements), do: elements |> Nine.Super.len
end
