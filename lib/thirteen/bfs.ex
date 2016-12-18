defmodule Thirteen.BFS do
  defstruct context: nil, avail_fn: nil, move_fn: nil, visited: %{}, 
            queue: nil, max_depth: nil, visited_fn: nil, visit_fn: nil,
            errors: []

  alias Thirteen.BFS

  def init(key_list) do
    key_list
    |> Enum.reduce(%BFS{}, &handle_key/2)
    |> required([:context, :avail_fn, :move_fn])
    |> defaults([visited_fn: nil, visit_fn: nil, max_depth: nil])
    |> setup_queue
  end

  def setup_queue(bfs), do: %{bfs | queue: create_queue}

  def required(bfs, keys) do
    errors = 
      keys
      |> Enum.filter(fn k -> Map.get(bfs, k) == nil end)
      |> Enum.map(fn k -> {:missing_required, k} end)
    %{bfs | errors: bfs.errors ++ errors}
  end

  def defaults(bfs, defaults) do
    defaults
    |> Enum.reduce(bfs, fn {k, d}, acc -> apply_default(acc, k, d) end) 
  end

  def apply_default(bfs, k, d) do
    case Map.get(bfs, k) do
      nil -> Map.put(bfs, k, d)
      _ -> bfs
    end
  end

  def handle_key({:context, c}, bfs), do: %{bfs | context: c}
  def handle_key({:avail_fn, f}, bfs), do: %{bfs | avail_fn: f}
  def handle_key({:move_fn, f}, bfs), do: %{bfs | move_fn: f}
  def handle_key({:max_depth, d}, bfs), do: %{ bfs | max_depth: d}
  def handle_key({:visit_fn, f}, bfs), do: %{bfs | visit_fn: f}
  def handle_key({:visited_fn, f}, bfs), do: %{bfs | visited_fn: f}

  def new_path(bfs, from, to), do: new_path(bfs, from, to, [], 0)

  def new_path(_bfs, from, from, path, _depth), do: path

  def new_path(bfs, from, to, path, depth) do
    # get all available moves
    moves = bfs.avail_fn.(bfs.context, from)

    # collect the resulting states from those moves
    moves_and_states = 
      moves
      |> Enum.map(fn m -> {m, bfs.move_fn.(bfs.context, m)} end)

    # filter out any already visited states
    unvisited_moves_and_states =
      moves_and_states
      |> Enum.filter(fn {_m, s} -> !visited?(bfs, s) end)

    # if we're not already at the max_depth, then enqueue the moves, paths, and depths that remain
    to_queue =
      unvisited_moves_and_states
      |> filter_moves_to_queue(depth + 1, bfs.max_depth)
      |> queue_entries(path, depth + 1)

    enqueued = enqueue(bfs.queue, to_queue)

    # take the first unvisited queue entry, if the queue is empty, we're done
    case first_unvisited(enqueued, bfs) do
      {{next, new_path, new_depth}, new_queue} ->
        bfs
        |> visit(from)  
        |> set_queue(new_queue)
        |> new_path(next, to, new_path, new_depth)
      :empty -> bfs |> visit(from)
    end
  end
  
  
  def filter_moves_to_queue(moves, _depth, nil), do: moves
  def filter_moves_to_queue(moves, depth, max_depth) when depth < max_depth, do: moves
  def filter_moves_to_queue(_moves, _, _), do: []
  


  def queue_entries(moves_and_states, path, depth) do
    moves_and_states
    |> Enum.map(fn {m,s} -> {s, [m | path], depth} end)
  end


  def visit(%BFS{visited: visited, visit_fn: nil} = bfs, state),
    do: %{bfs | visited: Map.put(visited, state, true)}

  def visit(%BFS{visit_fn: vfn, context: c} = bfs, state),
    do: %{bfs | context: vfn.(c, state)}

  def visited?(%BFS{visited: visited, visited_fn: nil}, state),
    do: visited[state] != nil

  def visited?(%BFS{visited_fn: vfn, context: c}, state), 
    do: vfn.(c, state)

  def set_queue(%BFS{} = bfs, new_queue), 
    do: %{bfs | queue: new_queue}

  def first_unvisited(queue, bfs) do
    case queue |> dequeue do
      :empty -> :empty
      {next, new_queue} -> skip_if_visited(next, new_queue, bfs)
    end
  end

  def skip_if_visited(next, queue, bfs) do
    case visited?(bfs, next) do
      true -> first_unvisited(queue, bfs)
      false -> {next, queue}
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
