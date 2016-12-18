defmodule Eleven.Madness do
  alias Eleven.Bits
  alias Eleven.Bits.Cache

  def initial_state do
    state = 
      [
        [:sg, :sm, :pg, :pm],
        [:tg, :rg, :rm, :cg, :cm],
        [:tm],
        []
      ]
      |> Bits.to_state_int

    {state, 0}
  end

  def end_state do
    state = 
      [
        [],
        [],
        [],
        [:sg, :sm, :pg, :pm, :tg, :tm, :rg, :rm, :cg, :cm]
      ]
      |> Bits.to_state_int
    {state, 3}
  end

  def solve, do: Cache.setup |> solve
  def solve(cache) do
    states_map = cache |> Cache.states
    find_path(initial_state, end_state, states_map, init_depth_agent)
  end

  def find_path(from, to, states_map, depth_agent), 
    do: find_path({from, []}, to, 0, :queue.new, %{}, states_map, depth_agent)

  def find_path({from, moves}, from, _counter, _queue, _visited, _states_map, _depth_agent), do: moves 

  def find_path({_, moves} = current, to, counter, queue, visited, states_map, depth_agent)
    when rem(counter,10000) == 0 do
      check_depth(moves, depth_agent) 
      find_path(current, to, counter + 1, queue, visited, states_map, depth_agent)
  end
  
  def find_path({from, moves}, to, counter, queue, visited, states_map, depth_agent) do
    new_visited = visited |> visit(from)
    moves_and_states = 
      Bits.legal_moves(from, states_map)
      |> Enum.map(fn {to_floor, m} -> {{to_floor, m}, {Bits.move(from |> elem(0), m, to_floor), to_floor}} end)
      |> Enum.filter(fn {_move, {state, _floor}} -> visited[state] == nil end)
    
    to_queue = 
      moves_and_states
      |> Enum.map(fn {move, state} -> {state, [move | moves]} end)
     
    {next, new_queue} = queue |> enqueue(to_queue) |> next_unvisited(visited)
      
    find_path(next, to, counter + 1, new_queue, new_visited, states_map, depth_agent)
  end

  def visit(visited, from), do: visited |> Map.put(from, true)

  def next_unvisited(queue, visited) do
    {{next, floor}, new_queue} = queue |> dequeue
    case visited[next] do
      nil -> {{next, floor}, new_queue}
      _ -> next_unvisited(new_queue, visited)
    end
  end

  
  def enqueue(q, list) when is_list(list) do
    list
    |> Enum.reduce(q, fn i, queue -> enqueue(queue, i) end)
  end
  def enqueue(q, i), do: :queue.in(i, q)
  def dequeue(q) do
    {{:value, value}, new_q} = :queue.out(q)
    {value, new_q}
  end
  def empty?(q), do: q |> :queue.is_empty
  
  
  def init_depth_agent do
    {:ok, pid} = Agent.start(fn -> %{depth: %{}, visited: %{}} end)
    pid
  end

  def check_depth(moves, pid_agent) do
    depth = moves |> Enum.count 
    case Agent.get(pid_agent, fn s -> s.depth[depth] end) do
      nil -> new_depth(pid_agent, depth)
      _ -> :ok
    end
  end

  def new_depth(pid_agent, depth) do
    IO.puts("\nDepth: #{depth}")
    Agent.update(pid_agent, 
     fn s -> %{s | depth: Map.put(s.depth, depth, true)} end)
  end

end
