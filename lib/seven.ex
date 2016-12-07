defmodule Seven do
  def run do
    IO.puts ""
    IO.puts("Day #{day}: #{title}")
    IO.puts(String.duplicate("-", 40))
    IO.puts("Part 1 result: #{part1}")
    IO.puts("Part 2 result: #{part2}")
    IO.puts ""
  end

  def day, do: 7

  def title, do: "Internet Protocol Version 7"

  def module, do: Seven.Solver

  def part1, do: module |> apply(:part1, [])
  def part2, do: module |> apply(:part2, [])

end
