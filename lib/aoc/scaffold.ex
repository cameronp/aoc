defmodule Aoc.Scaffold do
  defmacro __using__(options) do
    quote do
      import unquote(__MODULE__)
      
      def test do
        unquote(options) |> IO.inspect
      end

      def day, do: unquote(options) |> Keyword.fetch!(:day)

      def module, do: unquote(options) |> Keyword.fetch!(:module)

      def title, do: unquote(options) |> Keyword.fetch!(:title)

      def run do
        IO.puts ""
        IO.puts("Day #{day}: #{title}")
        IO.puts(String.duplicate("-", 40))
        IO.puts("Part 1 result: #{part1}")
        IO.puts("Part 2 result: #{part2}")
        IO.puts ""
      end

      def part1, do: module |> apply(:part1, [])
      def part2, do: module |> apply(:part2, [])

      defoverridable [part1: 0, part2: 0]
    end
  end
end
