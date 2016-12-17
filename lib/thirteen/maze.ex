defmodule Thirteen.Maze do
  alias Thirteen.BFS

  def test do
    BFS.init(context: 10, avail_fn: &lazy_avail/2, move_fn: &move_fn/2)
    |> BFS.new_path({1,1},{7,4})
  end

  def solve do
    BFS.init(context: 1362, avail_fn: &lazy_avail/2, move_fn: &move_fn/2)
    |> BFS.new_path({1,1},{31,39})
  end

  def solve2 do
    1362
    |> BFS.new(&lazy_avail/2, &move_fn/2, 51)
    |> BFS.path({1,1},{31,39})
    |> Map.keys
    |> Enum.filter(&on_the_board/1)
  end

  def create(max_x, max_y, secret) do
    points(max_x, max_y)
    |> Enum.map(fn point -> {point, open_space?(point, secret)} end)
    |> Enum.into(%{})
  end

  def lazy_avail(secret, point) do
    point
    |> all_moves
    |> Enum.filter(fn {_m, dest} -> dest |> open_space?(secret) end)
    |> just_move_part
    |> with_from(point)
  end

  def with_from(moves, from) do
    moves
    |> Enum.map(fn m -> {from, m} end)
  end

  def move_fn(_secret, {from, move}) do
    from
    |> move(move)
  end

  def just_move_part(moves) do
    moves
    |> Enum.map(fn {m,_} -> m end)
  end

  def move({x,y}, :l), do: {x-1, y}
  def move({x,y}, :u), do: {x, y-1}
  def move({x,y}, :r), do: {x+1, y}
  def move({x,y}, :d), do: {x, y+1}


  def legal_moves(moves, maze) do
    moves
    |> Enum.filter(fn {_m, s} -> maze[s] == true end)
  end

  def all_moves({x,y}) do
    [l: {x-1,y}, u: {x, y-1}, r: {x+1, y}, d: {x, y+1}]
    |> Enum.filter(&on_the_board/1)
  end

  def on_the_board({x,y}) when x >= 0 and y >= 0, do: true
  def on_the_board(_), do: false

  def display(maze) do
    {max_x, max_y} = 
      maze
      |> dimensions
    (for y <- 0..max_y, do: row(maze, y, max_x))
    |> Enum.join("\n")
    |> IO.puts
  end

  def row(maze, y, max_x) do
    (for x <- 0..max_x, do: maze[{x,y}])
    |> Enum.map(fn true -> "."
                   false -> "#" end)
    |> Enum.join("")
  end

  def dimensions(maze) do
    maze
    |> Map.keys
    |> Enum.reduce([[],[]], fn {x,y}, [xs,ys] -> [[x | xs], [y | ys]] end)
    |> Enum.map(&Enum.max/1)
    |> List.to_tuple
  end
  
  def points(max_x, max_y) do
    for x <- 0..max_x, y <- 0..max_y, do: {x,y}
  end

  def open_space?(point, secret_number) do
    point
    |> base_formula
    |> add_secret_number(secret_number) 
    |> count_bits
    |> open_count?
  end

  def open_count?(c) when rem(c,2) == 0, do: true
  def open_count?(_), do: false

  def wall?(point, secret_number), do: !open_space?(point, secret_number)

  def base_formula({x,y}), do: x*x + 3*x + 2*x*y + y + y*y

  def add_secret_number(val, secret_number), do: val + secret_number

  def count_bits(val) do
    val
    |> Integer.digits(2)
    |> Enum.count(fn digit -> digit == 1 end)
  end
  
end
