defmodule Ten.Robot do
  use GenServer

  alias Ten.Bin

  defmodule State, 
    do: defstruct id: 0, armed: false, dir: nil, chips: [], low: nil, high: nil

  # Client
  
  def create_directory! do
    {:ok, pid} = Agent.start(fn -> %{} end)  
    pid
  end  
  
  def start!(id, dir) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{id: id, dir: dir})
    pid
  end

  def lookup(dir, id) do
    Agent.get(dir, fn s -> s[{:robot, id}] end)
  end

  def lookup_or_create(dir, id) do
    case lookup(dir,id)  do
      nil ->
        start!(id, dir)
      r -> r
    end
  end

  def get_target(dir, {:bot, id}), do: dir |> lookup_or_create(id)
  def get_target(dir, {:output, id}), do: dir |> Bin.lookup_or_create(id)

  def set_filter(pid, low, high) when is_pid(pid) and is_pid(low) and is_pid(high) do
    GenServer.call(pid, {:set_filter, low, high})
  end

  def set_filter(dir, id, low, high)  do
    robot = lookup_or_create(dir, id)
    low = get_target(dir, low)
    high = get_target(dir, high) 

    set_filter(robot, low, high)
  end

  def deliver(pid, chip_id) when is_pid(pid) do
    GenServer.call(pid, {:delivery, chip_id})  
  end

  def deliver(dir, id, chip_id) do
    robot = lookup_or_create(dir, id)
    deliver(robot, chip_id)
  end

  def tick(pid), do: GenServer.call(pid, :tick)

  # Server  
  
  def init(%{id: id, dir: dir})  do
    state = %State{id: id, dir: dir}
    #IO.puts "Starting: #{format(state)}"
    register(dir, id, self)
    {:ok, state}
  end

  def handle_call(:tick, _from, %State{chips: [_a,_b | _t] = chips} = s) do
    case process_chips(s, chips |> Enum.sort) do
      :halt -> {:reply, :halt, s} 
      new_state -> {:reply, :ok, new_state}
    end
  end

  def handle_call(:tick, _from, s) do
    #IO.write(".")
    {:reply, :ok, s}
  end

  def handle_call({:delivery, chip_id}, _from, state) do
    new_state = %{state | chips: [chip_id | state.chips]}
    #IO.puts "Receiving #{chip_id}: #{format(new_state)}"
    {:reply, :ok, new_state}
  end

  def handle_call({:set_filter, low, high}, _from, state) do
    new_state = %{state | low: low, high: high}
    IO.puts "Setting filter: #{format(new_state)}"
    {:reply, :ok, new_state}
  end
 
  #def process_chips(s, [17,61]) do
    ##IO.puts("RESULT: #{s.id} is filtering 17 and 61")
    #:halt
  #end

  def process_chips(s, chips) do
    #IO.write("*")
    low = Enum.min(chips)
    high = Enum.max(chips)
    deliver(s.low, low)
    deliver(s.high, high)
    %{s | chips: s.chips -- [low,high]}
  end

 
  # Helpers
  
  def format(%State{} = state) do
    "Robot ##{state.id}: pid: #{self |> inspect} | #{format(armed: state.armed)}, chips: #{format(chips: state.chips)}" 
    <> " low: #{format(low: state.low)} high: #{format(high: state.high)}"
  end

  def format(armed: true), do: "ARMED"
  def format(armed: false), do: "SAFE"

  def format(chips: chips) do
    chips
    |> Enum.map(&to_string/1)
    |> Enum.join(",")
  end

  def format(low: low), do: low |> inspect
  def format(high: high), do: high |> inspect

  def register(dir, id, pid) do
    Agent.update(dir, fn s -> Map.put(s, {:robot, id}, pid) end)
  end

  def target(dir, {:bot, id}), do: lookup(dir, id)
  def target(dir, {:output, id}), do: Bin.lookup(dir, id)

end
