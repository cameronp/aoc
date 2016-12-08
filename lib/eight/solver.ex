defmodule Eight.Solver do
  import Utils.Parsing
  alias Eight.Screen

  def part1(input \\ "data/eight/input.txt"),
    do: solve(input, &count_pixels/1)

  def part2(input \\ "data/eight/input.txt"),
    do: solve(input, &Screen.display/1)

  def solve(input, compute) do
    input
    |> load
    |> parse
    |> process
    |> compute.()
  end

  def load(filename), do: filename |> readfile

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def process(cmds) do
    Screen.new(50,6)
    |> process(cmds)
  end

  def count_pixels(screen) do
    screen.pixels
    |> Enum.count(fn {_, v} -> v end)
  end

  def process(s, []), do: s
  def process(s, [cmd | t]), do: s |> exec(cmd) |> process(t)

  def exec(s, {:rect, x, y}), do: s |> Screen.rect(x,y)
  def exec(s, {:rotate, parms}), 
    do: s |> Screen.rotate(parms.orientation, parms.location, parms.amt)

  def parse_line("rect " <> cmd) do
    [width, height] = 
      cmd
      |> split_and_map("x", &to_int/1)
    {:rect, width, height}     
  end

  def parse_line("rotate " <> cmd) do
    rotate_cmd = 
      ~r/(?<orientation>row|column)\s[x|y]=(?<location>\d+)\sby\s(?<amt>\d+)/
      |> Regex.named_captures(cmd)
      |> atomize_keys
      |> transform_vals([:amt, :location], &to_int/1)
      |> transform_vals([:orientation], &String.to_atom/1)
    {:rotate, rotate_cmd}
  end

  def transform_vals(map, keys, fun) do
    keys
    |> Enum.reduce(map, fn k, m -> Map.put(m, k, fun.(m[k])) end)
  end


  
  
end
