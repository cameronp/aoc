defmodule Two.Bathroom do
  import Utils.Parsing


  defmodule State do
    defstruct position: {0,0}, code: [], pad: %{}

    def pad1 do
      %{
        {0,0} => "1", {0,1} => "2", {0,2} => "3",
        {1,0} => "4", {1,1} => "5", {1,2} => "6",
        {2,0} => "7", {2,1} => "8", {2,2} => "9"
      }
    end

    def pad2 do
      %{
        {0,2} => "1", {1,1} => "2", {1,2} => "3",
        {1,3} => "4", {2,0} => "5", {2,1} => "6",
        {2,2} => "7", {2,3} => "8", {2,4} => "9",
        {3,1} => "A", {3,2} => "B", {3,3} => "C",
        {4,2} => "D"
      }
    end

    def new_part1 do
      %State{position: {1,1}, code: [], pad: pad1}
    end

    def new_part2 do
      %State{position: {2,0}, code: [], pad: pad2}
    end
    
    def record_code(%State{} = s), 
      do: %{s | code: [s.pad[s.position] | s.code]}

    def move(%State{} = s, direction) do
      possible = try_move(s.position, direction)
      case s.pad[possible] do
        nil -> s
        _value -> %{s | position: possible}
      end
    end

    def try_move({r,c}, :u), do: {r-1, c}
    def try_move({r,c}, :r), do: {r, c+1}
    def try_move({r,c}, :d), do: {r+1, c}
    def try_move({r,c}, :l), do: {r, c-1}

  end

  def part1 do
    finished_state = 
      load
      |> run(State.new_part1)
    finished_state.code
    |> Enum.reverse
    |> Enum.join("")
  end

  def part2 do
    finished_state = 
      load
      |> run(State.new_part2)
    finished_state.code
    |> Enum.reverse
    |> Enum.join("")
  end

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
    |> split_and_map("", &to_downcased_atom/1)
  end

  def run(lines, %State{} = s) do
    lines
    |> Enum.reduce(s, fn l, acc -> execute_line(acc,l) end)
  end

  def execute_line(%State{} = s, []), do: s |> State.record_code
  def execute_line(%State{} = s, [cmd | tail]) do
    s
    |> State.move(cmd)
    |> execute_line(tail)
  end


   
end
