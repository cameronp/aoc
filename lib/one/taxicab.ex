defmodule One.Taxicab do
  import Utils.Parsing

  defmodule State do
    defstruct location: {0, 0}, direction: :n, visited: %{} 

    @doc """
Creates a new `State`, at the origin, pointing north.
    """
    def new, do: %State{}


    @doc """
Turns the state in the specified direction (:l or :r)
    """
    def turn(%State{} = s, direction) do
      s
      |> Map.put(:direction, _turn(s.direction, direction))
    end

    @doc """
Walks forward the specified distance, calling the passed in abort_fun after 
every step to determine if it's time to bail.
    """
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
    
    @doc """
Take one step forward.
    """
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

  @doc """
Run part one
  """
  def part1 do
    load
    |> run(State.new, &no_abort/1)
    |> distance
  end

  @doc """
Run part two.
  """
  def part2 do
    load
    |> run(State.new, &visited?/1)
    |> distance
  end


  @doc """
Determines if the current location has been visited before.  Returns true if it has
nil otherwise.  Must be called prior to calling `visit`

This is used as the abort function in part two.
  """
  def visited?(%State{location: l, visited: v}), do: v[l]

  @doc """
An abort function that never aborts.  Used for part one.
  """
  def no_abort(_s), do: false

  @doc """
  Load and parse the given file, or 'one/input.txt' if no filename is provided.
  """
  def load(file \\ "data/one/input.txt") do
    file
    |> readfile
    |> parse 
  end

  @doc """
parse the input file, which consists of a single line of comma separated commands.
  """
  def parse(s) do
    s
    |> split_and_map(", ", &parse_command/1)
  end

  @doc """
parse an individual command.
  """
  def parse_command("L" <> tail), do: %{turn: :l, distance: to_int(tail)}
  def parse_command("R" <> tail), do: %{turn: :r, distance: to_int(tail)}

  @doc """
compute the distance from the origin to the location using taxicab geometry.
https://en.wikipedia.org/wiki/Taxicab_geometry
  """
  def distance({x, y}), do: abs(x) + abs(y)

  @doc """
Given a state and a list of commands, runs the commands reducing the state until either
there are no further commands, or the given abort_fun returns true.
  """
  def run([], %State{location: location}, _abort_fun), do: location 
  def run([command | tail], %State{} = s, abort_fun) do
    case execute(s, command, abort_fun) do
      %State{} = s -> run(tail, s, abort_fun)
      {:found, location} -> location
    end
  end


  @doc """
Execute a single command.
  """
  def execute(%State{} = s, command, abort_fun) do
    s
    |> State.turn(command.turn)
    |> State.careful_walk(command.distance, abort_fun)
  end
 
end
