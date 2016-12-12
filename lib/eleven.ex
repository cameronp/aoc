defmodule Eleven do
  @moduledoc """
E
E TM
E    TG       RM RG CM CG
E       SM SG             PM PG

We will represent chips with odd numbers, and their corresponding generators
with the next highest even number.  TM is 1, TG is TM + 1, or 2.

So the initial state is:
%{1 => [3,4,9,10], 2=>[2,5,6,7,8], 3 => [1], 4 =>[], :e => 1}

  """
@floor_moves %{1 => [2], 2 => [1,3], 3 => [2,4], 4 => [3]}

  def init do
    %{ 1 => [3,4,9,10], 
      2=>[2,5,6,7,8], 
      3 => [1],
      4 =>[], 
      e: 3, 
      moves: []  
    }
  end

  def finished?(%{1 => [], 2 =>[], 3 => [], e: 4}), do: true
  def finished?(_), do: false

  def find(init_state) do 
    find(init_state, :queue.new, false, init_depth_agent, 0, true)
  end
  def find(s,q,false,da,count, _) when rem(count, 10000) == 0, 
    do: find(s,q,false,da,count+1, true)
  def find(state, queue, false, depth_agent, count, check) do
    moves = legal_moves(state)
    new_states = 
      (for m <- moves, do: state |> move(m)) 
      |> no_dupes(depth_agent)

    {next_state, new_queue} =  
      queue 
      |> enqueue(new_states)
      |> next_non_dupe(depth_agent)
    halt = finished?(next_state) 
    if check do
      IO.write(".")
      check_depth(next_state, depth_agent)
    end
    find(next_state, new_queue, halt, depth_agent, count + 1, false)
  end

  def next_non_dupe(queue, agent) do
    {next_state, new_queue} = queue |> dequeue
    case is_dupe?(next_state, agent) do
      true -> next_non_dupe(new_queue, agent)
      false -> {next_state, new_queue}
    end
  end
  
  def no_dupes(states, agent) do
    states
    |> Enum.filter(fn s -> !is_dupe?(s, agent) end)
  end

  def is_dupe?(state, agent) do
    no_moves = Map.delete(state, :moves)
    Agent.get(agent, fn s -> s.visited[no_moves] end) != nil
  end

  def visit(state, agent) do
    no_moves = Map.delete(state, :moves)
    Agent.update(agent, fn s -> %{s | visited: Map.put(s.visited, no_moves, true)} end)
  end

  def find(state, _, true, _), do: state

  def init_depth_agent do
    {:ok, pid} = Agent.start(fn -> %{depth: %{}, visited: %{}} end)
    pid
  end

  def check_depth(state, pid_agent) do
    depth = state.moves |> Enum.count 
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
  

  def move(s, {el, dest} = m) do
    dest_floor = s[dest]
    %{s |  s[:e] => s[s[:e]] -- el, 
           dest => s[dest] ++ el, 
           e: dest, 
           moves: [m | s.moves]}
  end

  def danger?([]), do: false
  def danger?(list) when is_list(list) do
    {evens, odds} = 
      list
      |> Enum.partition(fn e -> rem(e,2) == 0 end)
    danger?(evens, odds)
  end

  def danger?(_evens, []), do: false
  def danger?([], _odds), do: false
  def danger?(evens, [h | t]) do
    case (h + 1) in evens do
      true -> danger?(evens, t)
      false -> true
    end
  end

  def safe?(list), do: !danger?(list)


  def legal_moves(%{e: floor} = s) do
    s[floor]
    |> all_moves(floor)
    |> Enum.filter(fn move -> is_legal?(move, s[floor], s) end)
  end

  def is_legal?({el, dest}, from, state) do
    safe?(el) && safe?(from -- el) && safe?(el ++ state[dest]) 
  end

  
  def all_moves(list, floor) do
    list
    |> naive_moves(floor)
    |> Enum.map(&normalize/1)
    |> Enum.uniq

  end

  def normalize({[a,b], f}) when a > b, do: {[b,a], f}
  def normalize({_,_} = move), do: move

  def naive_moves(list, floor) do
    twos = for a <- list, b <- (list -- [a]), f <- @floor_moves[floor] do
      {[a,b],f}
    end  
    ones = for a <- list, f <- @floor_moves[floor] do
      {[a], f}
    end
    ones ++ twos
  end

end
