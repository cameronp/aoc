defmodule Eighteen do
  @input ".^..^....^....^^.^^.^.^^.^.....^.^..^...^^^^^^.^^^^.^.^^^^^^^.^^^^^..^.^^^.^^..^.^^.^....^.^...^^.^."

  def part1, do: solve(40)
  def part2, do: solve(400000)

  def solve(count) do
    @input
    |> parse_line
    |> generate(count-1)
    |> Enum.map(&count_safe/1)
    |> Enum.sum
  end

  def count_safe(list) do
    list
    |> Enum.count(fn i -> i == :s end)
  end

  def generate(start, count) do
    1..count
    |> Enum.reduce([start], 
        fn _, [last | _] = acc ->
          [next(last) | acc]
        end)
  end

  
  def parse_line(line) when is_binary(line), 
    do: line |> String.to_char_list |> parse_line

  def parse_line(list) when is_list(list) do
    list
    |> Enum.map(&parse_trap/1)
  end

  def parse_trap(?.), do: :s
  def parse_trap(?^), do: :t


  def next(list) when is_list(list) do
    expanded = [:s] ++ list ++ [:s]
    expanded
    |> Enum.chunk(3,1)
    |> Enum.map(&spot_trap/1)
  end


  def spot_trap([:t, :t, :s]), do: :t
  def spot_trap([:s, :t, :t]), do: :t
  def spot_trap([:t, :s, :s]), do: :t
  def spot_trap([:s, :s, :t]), do: :t
  def spot_trap([_, _, _]), do: :s

end
