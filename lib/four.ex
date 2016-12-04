defmodule Four do
  def run do
    IO.puts ""
    IO.puts("Day #{day}: #{title}")
    IO.puts(String.duplicate("-", 40))
    IO.puts("Part 1 result: #{part1}")
    IO.puts("Part 2 result: #{part2}")
    IO.puts ""
  end

  def day, do: 4

  def title, do: ""

  def module, do: Four.Solver

  def part1, do: module |> apply(:part1, [])
  def part2, do: module |> apply(:part2, [])

end
