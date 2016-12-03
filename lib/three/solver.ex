defmodule Three.Solver do
  import Utils.Parsing 

  def part1, do: solve(&parse1/1)
  def part2, do: solve(&parse2/1)

  def solve(parser) do
    load
    |> parser.()
    |> Enum.filter(&valid?/1)
    |> Enum.count
  end

  def load(file \\ "data/three/input.txt") do
    file
    |> readfile
  end

  def parse1(binary) do
    binary    
    |> split_and_map("\n", &parse_triangle/1)
  end

  def parse2(binary), do: binary |> parse1 |> find_vertical_tris

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

  def valid?([a,b,c]) 
    when (a + b) > c and
         (a + c) > b and
         (b + c) > a, 
    do: true
  def valid?([_,_,_]), do: false
end
