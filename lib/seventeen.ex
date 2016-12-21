defmodule Seventeen do

  def longest do
    path({{0,0}, ""}, "vkjiggvb")
    |> Enum.map(&String.length/1)
    |> Enum.max
  end
  def bfs do
    bfs = Thirteen.BFS.init(context: "vkjiggvb", avail_fn: &avail_fn/2, move_fn: &move_fn/2,
                      visit_fn: &visit/2, visited_fn: &visited?/2, equal_fn: &equal_fn/2)

    Thirteen.BFS.new_path(bfs, {{0,0}, ""}, {{3,3}, ""})
    |> Enum.map(fn {{_, path}, last} -> path <> last end)
    |> hd

  end
  
  def avail_fn(code, position) do
    position
    |> available_directions(code)
    |> Enum.map(fn dir -> {position, dir} end)
  end

  def move_fn(_code, {from, dir}) do
    move(from, dir) 
  end

  def visit(code, _state), do: code

  def visited?(_code, _state), do: false

  def equal_fn({pos1, _}, {pos2, _}), do: pos1 == pos2

  def path({{3,3}, path}, _), do: [path]
  def path(state, code) do
    state
    |> available_directions(code)
    |> Enum.map(fn dir -> move(state, dir) end)
    |> recurse(code)
  end

  def recurse([], _code), do: []
  def recurse([state | t], code) do
    paths = path(state, code)
    recurse(t,code) ++ paths
  end

  def available_directions({pos, path}, code)  do
    pos
    |> all_directions
    |> open_doors(path, code)
    |> Enum.map(fn {dir, _, _} -> dir end)
  end

  def move({{x,y}, path}, "U"), do: {{x, y-1}, path <> "U"} 
  def move({{x,y}, path}, "D"), do: {{x, y+1}, path <> "D"} 
  def move({{x,y}, path}, "L"), do: {{x-1, y}, path <> "L"} 
  def move({{x,y}, path}, "R"), do: {{x+1, y}, path <> "R"} 
  
  def open_doors(doors, path, code) do
    opens = 
      hash(code <> path)
      |> parse_code(~w(U D L R))
    doors
    |> Enum.filter(fn {dir, _, _} -> dir in opens end)
  end

  def parse_code(_, []), do: []
  def parse_code(<<door::utf8, t::binary>>, [direction | directions])
    when door in [?b, ?c, ?d, ?e, ?f],
    do: [direction | parse_code(t, directions)]
  def parse_code(<<_::utf8, t::binary>>, [_ | directions]),
    do: parse_code(t, directions)

  def all_directions({x,y}) do
    [{"U", x, y-1}, {"D", x, y+1}, {"L", x-1, y}, {"R", x+1, y}]
    |> Enum.filter(&on_the_board?/1) 
  end

  def on_the_board?({_, x, y}) 
    when x >= 0 and y >= 0 and x <= 3 and y <= 3,
    do: true
  def on_the_board?({_,_,_}), do: false

  def hash(s), do: :crypto.hash(:md5, s) |> Base.encode16(case: :lower)
end
