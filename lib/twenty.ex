defmodule Twenty do
  import Utils.Parsing

  @input_file "data/twenty/input.txt"
  @test_file "data/twenty/test1.txt"

  def test  do
    solve(@test_file, 12)
  end

  def part2, do: solve(0xffffffff)

  def solve(file \\ @input_file, max) do
    file
    |> load
    |> parse
    |> process(max)
  end

  def process(ranges, max) do
    ranges
    |> validate(max)
    |> Enum.sort_by(fn {f, _} ->f end)
    |> range_chop(0, [], max)
    |> Enum.map(&count_range/1)
    |> Enum.sum
  end

  def validate(ranges, max) when is_list(ranges) do
    ranges
    |> Enum.map(&validate(&1, max))

    ranges
  end

  def validate(range, max) do
    range
    |> is_ordered
    |> is_positive
    |> is_less_than_max(max)
  end

  def is_ordered({from, to}) when from <= to, do: {from, to}

  def is_positive({from, to}) when from >= 0 and to >= 0, 
    do: {from, to}

  def is_less_than_max({from, to}, max) 
    when from <= max and to <= max,
    do: {from, to}

  def min_chop([{from, to} | t], cur) 
    when cur >= from and to >= cur,
    do: min_chop(t, to + 1)
  
  def min_chop([{from, to} | t], cur) 
    when cur >= from and cur > to,
    do: min_chop(t, cur)
 
  def min_chop([{from, _to} | _t], cur) 
    when cur < from, do: cur

  def range_chop(list, cur, ranges, max) do
    #IO.inspect {list, cur, ranges, max}
    _range_chop(list, cur, ranges, max)
  end

  def _range_chop([], cur, ranges, max), 
    do: [{cur, max} | ranges]

  def _range_chop([{from, to} | t], cur, ranges, max)
    when cur >= from and cur <= to, 
    do: range_chop(t, to + 1, ranges, max)

  def _range_chop([{from, to} | t], cur, ranges, max)
    when cur >= from and cur > to, 
    do: range_chop(t, cur, ranges, max)

  def _range_chop([{from, to} | t], cur, ranges, max)
    when cur < from,
    do: range_chop(t, to + 1, [{cur, (from-1)} | ranges], max)

  def count_range({from, to}), do: to - from + 1



  def load(filename) do
    filename
    |> readfile
  end

  def parse(data) do
    data
    |> split_and_map("\n", &parse_line/1)
  end

  def parse_line(line) do
    r = ~r/(\d+)-(\d+)/
    [_, from, to] = Regex.run(r, line) 
    {to_int(from), to_int(to)}
  end

end
