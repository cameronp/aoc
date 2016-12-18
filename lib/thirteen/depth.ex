defmodule Thirteen.Depth do
  require Integer
@moduledoc """
Find x*x + 3*x + 2*x*y + y + y*y.
Add the office designer's favorite number (your puzzle input).
Find the binary representation of that sum; count the number of bits that are 1.
If the number of bits that are 1 is even, it's an open space.
If the number of bits that are 1 is odd, it's a wall.
"""

  def is_open?({x,y}, secret)  do
    (x*x + 3*x + 2*x*y + y + y*y + secret)
    |> Integer.digits(2)
    |> Enum.count(fn bit -> bit == 1 end)
    |> Integer.is_even
  end

  def is_wall?(point, secret), do: !is_open?(point, secret)
  
  def possible_moves({x,y}), 
    do: [{x-1, y}, {x+1,y}, {x, y-1}, {x, y+1}]

  def on_the_board?({x,y}) when x >= 0 and y >= 0, do: true
  def on_the_board?({_, _}), do: false

  def only_open(list, secret) do
    list
    |> Enum.filter(fn point -> is_open?(point, secret) end)
  end

  def legal_moves(point, secret) do
    point
    |> possible_moves
    |> Enum.filter(&on_the_board?/1)
    |> only_open(secret)
  end

  def solve(depth), do: count({1,1}, depth, 1362)

  def count(from, max_depth, secret), 
    do: count(from, max_depth, secret, 0, %{}) |> Map.keys |> Enum.count
  def count(_from, max_depth, _secret, max_depth, visited), 
    do: visited 

  def count(from, max_depth, secret, depth, visited) do
    new_visited = 
      visited
      |> Map.put(from, true)

    reducer = count_reducer(max_depth, depth, secret)
    
    from
    |> legal_moves(secret)
    |> Enum.reduce(new_visited, reducer)
  end


  def count_reducer(max_depth, depth, secret) do
    fn next, visited -> 
      case visited[next] do
        true -> visited 
        nil -> count(next, max_depth, secret, depth + 1, visited) 
      end
    end
  end
end

