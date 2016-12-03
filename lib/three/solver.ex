defmodule Three.Solver do
  import Utils.Parsing 

  def part1 do
    load
    |> parse
    |> Enum.filter(&valid?/1)
    |> Enum.count
  end

  def part2 do
    load
    |> parse2
    |> Enum.filter(&valid?/1)
    |> Enum.count
  end

  def load(file \\ "data/three/input.txt") do
    file
    |> readfile
  end

  def ed do
    load
    |> String.split
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index
    |> Enum.group_by(fn {side, index} -> rem(index, 3) end)
    #|> Map.values
    #|> Enum.map(&only_values/1)
    #|> List.flatten
    #|> Enum.chunk(3)
    #|> Enum.map(&List.to_tuple/1)
  end
  def parse(binary) do
    binary    
    |> split_and_map("\n", &parse_triangle/1)
    |> Enum.map(&Enum.sort/1)
  end

  def parse2(binary) do
    binary
    |> split_and_map("\n", &parse_triangle/1)
    |> find_vertical_tris
    |> Enum.map(&Enum.sort/1)
  end

  def find_vertical_tris([]), do: []
  def find_vertical_tris([[a1, b1, c1], [a2, b2, c2], [a3, b3, c3] | tail]) do
    [
      [a1,a2,a3], [b1,b2,b3], [c1,c2,c3] 
      | find_vertical_tris(tail)
    ]
  end
  def parse_triangle(s) do 
    s 
    |> split_and_map("  ", &to_int/1)
  end

  def valid?([a,b,c]) when (a + b) > c, do: true
  def valid?([_,_,_]), do: false
  
  
end
