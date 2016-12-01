defmodule One.Taxicab do
  import Utils.Parsing

  defmodule State do
    defstruct location: {0, 0}, direction: :n, visited: %{} 

    def new, do: %State{}

    def turn(%State{} = s, direction) do
      s
      |> Map.put(:direction, _turn(s.direction, direction))
    end

    def careful_walk(%State{} = s, 0, _abort_fun), do: s
    def careful_walk(%State{} = s, distance, abort_fun) do
      new_state = step(s)
      if abort_fun.(new_state) do
        {:found, new_state.location}
      else
        new_state
        |> visit
        |> careful_walk(distance - 1, abort_fun)
      end
    end
    
    def step(%State{location: {x,y}, direction: :n} = s) do
      s
      |> Map.put(:location, {x, y+1})
    end

    def step(%State{location: {x,y}, direction: :e} = s) do
      s
      |> Map.put(:location, {x+1, y})
    end

    def step(%State{location: {x,y}, direction: :s} = s) do
      s
      |> Map.put(:location, {x, y-1})
    end

    def step(%State{location: {x,y}, direction: :w} = s) do
      s
      |> Map.put(:location, {x-1, y})
    end

    defp visit(%State{location: l, visited: v} = s) do
      new_visited = 
        v
        |> Map.put(l, true)

      s
      |> Map.put(:visited, new_visited)
    end

    defp _turn(:n, :l), do: :w
    defp _turn(:n, :r), do: :e
    defp  _turn(:e, :l), do: :n
    defp  _turn(:e, :r), do: :s
    defp  _turn(:s, :l), do: :e
    defp  _turn(:s, :r), do: :w
    defp  _turn(:w, :l), do: :s
    defp  _turn(:w, :r), do: :n
   
  end

  alias One.Taxicab.State

  def part1 do
    load
    |> run(State.new, &no_abort/1)
    |> distance
  end

  def part2 do
    load
    |> run(State.new, &visited?/1)
    |> distance
  end


  def visited?(%State{location: l, visited: v}=s) do 
    v[l]
  end

  def no_abort(_s), do: false

  def load(file \\ "data/one/input.txt") do
    file
    |> readfile
    |> parse 
  end

  def parse(s) do
    s
    |> split_and_map(", ", &parse_command/1)
  end

  def parse_command("L" <> tail), do: %{turn: :l, distance: to_int(tail)}
  def parse_command("R" <> tail), do: %{turn: :r, distance: to_int(tail)}

  def distance({x, y}), do: abs(x) + abs(y)

  def run([], %State{location: location}, _abort_fun), do: location 
  def run([command | tail], %State{} = s, abort_fun) do
    case execute(s, command, abort_fun) do
      %State{} = s -> run(tail, s, abort_fun)
      {:found, location} -> location
    end
  end


  def execute(%State{} = s, command, abort_fun) do
    s
    |> State.turn(command.turn)
    |> State.careful_walk(command.distance, abort_fun)
  end
 
end
