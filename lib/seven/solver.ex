defmodule Seven.Solver do
  import Utils.Parsing 
  def part1, do: solve(&Seven.TLS.supported?/1)
  def part2, do: solve(&Seven.SSL.supported?/1)

  def solve(filter, input \\ "data/seven/input.txt") do
    input
    |> load
    |> parse
    |> process(filter)
    |> compute
  end

  def load(filename) do
    filename
    |> readfile
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
  end

  def process(list, filter) do
    list
    |> Enum.filter(filter)
  end

  def compute(list) do
    list
    |> Enum.count
  end
end
