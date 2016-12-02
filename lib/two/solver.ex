defmodule Two.Solver do
  import Utils.Parsing 

   @keymap %{1 => %{:d => 3}, 
            2 => %{:r => 3, :d => 6}, 
            3 => %{:u => 1, :l => 2, :r => 4, :d => 7},          
            4 => %{:l => 3, :d => 8},
            5 => %{:r => 6},
            6 => %{:u => 2, :l => 5, :r => 7, :d => 0xA},
            7 => %{:l => 6, :u => 3, :r => 8, :d => 0xB},
            8 => %{:l => 7, :u => 4, :r => 9, :d => 0xC},
            9 => %{:l => 8},
            0xA => %{:u => 6, :r => 0xB},
            0xB => %{:l => 0xA, :u => 7, :d => 0xD, :r => 0xC},
            0xC => %{:u => 8, :l => 0xB},
            0xD => %{:u => 0xB}}
  

  defmodule State do
    defstruct position: 5, code: []    
    def new, do: %State{}
  end

  def part1 do
    result_state = 
      load
      |> Enum.reduce(State.new, fn row, state -> handle_row(state, row) end)
    result_state.code
    |> Enum.reverse

  end

  def handle_row(%State{} = s, []), do: %State{s | code: [s.position | s.code]}
  def handle_row(%State{} = s, [h | t]) do
    s
    |> move(h)
    |> handle_row(t)
  end

  def part2 do
    
  end


  def lookup(position), do: @keypad[position]

  def load(file \\ "data/two/input.txt") do
    file
    |> readfile
    |> parse
  end

  def parse(binary) do
    binary    
    |> split_and_map("\n", &parse_line/1) 
  end

  def parse_line(s) do
    s
    |> split_and_map("", &to_atom/1)
  end

  def to_atom("L"), do: :l
  def to_atom("R"), do: :r
  def to_atom("U"), do: :u
  def to_atom("D"), do: :d

  def move(%State{} = s, direction) do
    case @keymap[s.position][direction] do
      nil -> s
      new_pos -> %State{s | position: new_pos}
    end
  end
end
