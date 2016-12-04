defmodule Four.Solver do
  import Utils.Parsing
  alias Four.Room
 
  def part1, do: solve(&sum_ids/1)
  def part2, do: solve(&find_storeroom/1)

  def sum_ids(rooms) do
    rooms 
    |> Enum.reduce(0, fn r, sum -> sum + r.sector_id end)
  end

  def find_storeroom(rooms) do
    rooms    
    |> Enum.find(fn r -> r.name =~ "northpole" end)
    |> Map.get(:sector_id)
  end

  def validate(rooms), do: rooms |> Enum.filter(&Room.valid?/1)

  def decode(rooms), do: rooms |> Enum.map(&Room.decrypt/1)

  def solve(solver) do
    load
    |> parse
    |> validate
    |> decode
    |> solver.()
  end

  def load(file \\ "data/four/input.txt"), do: file |> readfile

  def parse(s), do: s |> split_and_map("\n", &Room.new/1)
end
