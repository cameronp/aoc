defmodule Ten.Bin do
  use GenServer
  
  defmodule State, do: defstruct id: 0, chips: [], dir: nil

  def start!(id, dir) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{id: id, dir: dir})
    pid
  end

  def lookup(dir, id) do
    Agent.get(dir, fn s -> s[{:bin, id}] end)
  end
  
  def deliver(pid, chip_id) when is_pid(pid) do
    GenServer.call(pid, {:delivery, chip_id})  
  end

  def deliver(dir, id, chip_id) do
    dir
    |> lookup_or_create(id)
    |> deliver(chip_id)
  end

  def lookup_or_create(dir, id) do
    case lookup(dir,id) do
      nil -> start!(id,dir)
      b -> b
    end
    
  end
  # Server  
  
  def init(%{id: id, dir: dir})  do
    state = %State{id: id, dir: dir}
    #IO.puts "Starting: #{format(state)}"
    register(dir, id, self)
    {:ok, state}
  end

  def handle_call({:delivery, chip_id}, _from, state) do
    new_state = %{state | chips: [chip_id | state.chips]}
    #IO.puts "Receiving #{chip_id}: #{format(new_state)}"
    #IO.puts("Bin ##{state.id}: chips: #{format(chips: new_state.chips)}")
    {:reply, :ok, new_state}
  end

  def handle_call(:tick, _from, s) do
    #IO.write(".")
    {:reply, :ok, s}
  end

  # Helpers

  def format(%State{} = s) do
    "Bin ##{s.id} : pid: #{self |> inspect} chips: #{format(chips: s.chips)}" 
  end

  def format(chips: chips) do
    chips |> Enum.map(&to_string/1) |> Enum.join(",")
  end

  def register(dir, id, pid) do
    Agent.update(dir, fn s -> Map.put(s, {:bin, id}, pid) end)
  end

end
