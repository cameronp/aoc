defmodule Six.Signal do
  import Utils.Parsing

  def part1, do: solve(&largest_list/1)

  def part2, do: solve(&smallest_list/1)

  defp solve(strategy) do
    load
    |> parse
    |> process(strategy)
    |> format
  end

  defp load(file \\ "data/six/input.txt") do
    file
    |> readfile
  end

  defp parse(data) do
    data
    |> String.split("\n", trim: true)
  end

  defp process(strings, strategy) do
    0..7
    |> Enum.map(fn i -> letters_at(i, strings) end )
    |> Enum.map(&Enum.sort/1)
    |> Enum.map(&chunk_pos/1)
    |> Enum.map(strategy)
    |> Enum.map(&hd/1)
  end

  defp format(l), do: l |> Enum.join("")

  defp letters_at(i, strings) when is_list(strings) do
    strings
    |> Enum.map(fn s -> String.at(s,i) end)
  end

  defp chunk_pos(l) do
    l
    |> Enum.chunk_by(&(&1))
  end

  defp largest_list(lists) do
    lists
    |> Enum.max_by(fn l -> Enum.count(l) end)
  end

  defp smallest_list(lists) do
    lists
    |> Enum.min_by(fn l -> Enum.count(l) end)
  end
end
