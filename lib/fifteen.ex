defmodule Fifteen do
  import Utils.Parsing

  @input_file_part_1 "data/fifteen/input1.txt"
  @input_file_part_2 "data/fifteen/input2.txt"

  def part1, do: @input_file_part_1 |> solve
  def part2, do: @input_file_part_2 |> solve

  def solve(file) do
    file
    |> load
    |> parse
    |> process
  end

  def load(filename), do: filename |> readfile

  def parse(data) do
    data
    |> split_and_map("\n", &parse_line/1)
    |> Enum.sort_by(fn {id, _} -> id end)
    |> Enum.map(fn {_, disc} -> disc end)
  end

  def process(list) do
    test_funs = 
      list
      |> Enum.with_index
      |> Enum.map(fn {disc, i} -> open_fn(disc, i + 1) end)
    Stream.iterate(0, &(&1 + 1))
    |> Stream.filter(fn t -> all_open?(test_funs, t) end)
    |> Enum.take(1)
    |> hd
  end

  def all_open?(funs, time) do
    funs
    |> Enum.all?(fn f -> f.(time) end)
  end
  


  def parse_line(line) do
    r = ~r/Disc #(\d+) has (\d+) positions; at time=0, it is at position (\d+)/

    [_, id, num_pos, starting] = Regex.run(r, line)
    {to_int(id), {to_int(num_pos), to_int(starting)}}
  end

  def open_fn({count, start}, offset) do
    fn time ->
      ((time + offset + start) |> rem(count)) == 0
    end
  end

end
