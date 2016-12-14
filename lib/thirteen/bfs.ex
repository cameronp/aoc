defmodule Thirteen.BFS do
  defstruct context: nil, avail_fn: nil, move_fn: nil, visited: %{}, 
            queue: nil, max_depth: nil
  alias Thirteen.BFS

  def new(context, avail_fn, move_fn) do
    %BFS{
      context: context,
      avail_fn: avail_fn,
      move_fn: move_fn,
      queue: create_queue
    }
  end

  def new(context, avail_fn, move_fn, max_depth) do
    bfs = new(context, avail_fn, move_fn)
    %{bfs | max_depth: max_depth}
  end

  def path(%BFS{} = bfs, from, to), do: path(bfs, from, to, [], 0)

  def path(%BFS{}, from, from, path, _depth), do: path

  def path(%BFS{} = bfs, from, to, path, depth) do
    moves = 
      bfs.avail_fn.(from, bfs.context)
      |> Enum.map(fn m -> {m, bfs.move_fn.(from, m, bfs.context)} end)
      |> Enum.filter(fn {_, state} -> bfs.visited[state] == nil end)
      |> Enum.map(&add_path(&1, path))
      |> Enum.map(&add_depth(&1, depth + 1))
      |> remove_too_deep(bfs)
    
    case queue_and_next(bfs.queue, moves, bfs) do
      {{next_move, next_state, path, next_depth}, new_queue} ->
        bfs
        |> visit(from)
        |> set_queue(new_queue)
        |> path(next_state, to, path, next_depth)
      :empty -> bfs.visited
    end
  end

  def queue_and_next(queue, moves, bfs)  do
    queue
    |> enqueue(moves)
    |> first_unvisited(bfs)
  end

  def remove_too_deep(moves, %BFS{max_depth: nil}), do: moves
  def remove_too_deep(moves, %BFS{max_depth: max_depth}) do
    moves
    |> Enum.filter(fn {_,_,_,depth} -> depth <= max_depth end)
  end

  def add_path({m, s}, path), do: {m, s, [m | path]}
  def add_depth({m, s, p}, depth), do: {m, s, p, depth}

  def visit(%BFS{visited: visited} = bfs, state),
    do: %{bfs | visited: Map.put(visited, state, true)}

  def set_queue(%BFS{} = bfs, new_queue), 
    do: %{bfs | queue: new_queue}

  def first_unvisited(queue, %BFS{max_depth: nil} = bfs) do
    case queue |> dequeue do
      :empty -> :empty
      {next, new_queue} -> skip_if_unvisited(next, new_queue, bfs)
    end
  end

  def first_unvisited(queue, %BFS{max_depth: max_depth} = bfs) do
    case first_unvisited(queue, %{bfs | max_depth: nil})  do
      {{_,_,_,depth} = move, new_q} when depth < max_depth -> {move, new_q}
      {_, new_q} -> first_unvisited(new_q, bfs)
      :empty -> :empty
    end
  end
  
  def skip_if_unvisited(next, queue, bfs) do
    case bfs.visited[next] do
      true -> first_unvisited(queue, bfs)
      nil -> {next, queue}
    end
  end



  def create_queue, do: :queue.new

  def enqueue(q, list) when is_list(list) do
    list
    |> Enum.reduce(q, fn i, q -> enqueue(q, i) end)
  end

  def enqueue(q, i), do: :queue.in(i, q)

  def dequeue(q) do
    case :queue.out(q) do
     {{:value, v}, new_q} -> {v, new_q}
     {:empty, _} -> :empty
    end
  end
    
     
  
end
