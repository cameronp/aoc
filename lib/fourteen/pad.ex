defmodule Fourteen.Pad do

  defmodule KeyStreamState, do: defstruct candidates: []

  def key_stream(salt) do
    salt
    |> triplet_stream
    |> Stream.transform(%KeyStreamState{}, &key_reducer/2)
  end

  def prune_candidates(list, index) do
    list
    |> Enum.filter(fn {_, i, _} -> i + 1000 >= index end)
  end

  def key_reducer({hash, index, _} = candidate, %KeyStreamState{} = s) do
    possible_keys = 
      s.candidates
      |> prune_candidates(index)
      
    case extract_quint(hash) do
      nil -> 
        s
        |>record_candidate([candidate | possible_keys])
        |> skip 
      quint -> 
        s 
        |> record_candidate([candidate | possible_keys])
        |> handle_quint(candidate, quint)
    end
  end

  def handle_quint(s, {_, index, _} = candidate, quint) do
    dump(s, candidate)
    matches =  
      s.candidates
      |> Enum.filter(fn {_, i, ^quint} -> i != index; _ -> false end)
      |> Enum.sort_by(fn {_, i, _} -> i end)
    case matches do
      [] -> s |> skip
      [first | _] -> 
        s
        |> remove_candidate(first)
        |> return_key(first)
    end
  end

  def skip(s), do: {[], s}
  def return_key(s, key), do: {[key], s}

  def record_candidate(%KeyStreamState{} = s, candidates),
    do: %{s | candidates: candidates}

  def remove_candidate(s, candidate), 
    do: %{s | candidates: s.candidates -- [candidate]}

  def dump(s, {hash, i, _}) do
    IO.puts("handling #{i} -- #{hash} --")
    s.candidates
    |> dump
  end

  def dump(list) when is_list(list) do
    list
    |> Enum.map(fn {_, i, triplet} -> ~s(\t{#{i}, "#{triplet}"}) end)
    |> Enum.join("\n")
    |> IO.puts
  end


  

  def triplet_stream(salt) do
    salt
    |> hash_stream
    |> Stream.map(&extract_triplet/1)
    |> Stream.filter(&has_triplet?/1)
  end

  def hash_stream(salt) do
    salt
    |> hashable_stream
    |> Stream.map(&hash/1)
    |> Stream.with_index
  end

  def hash(s), do: :crypto.hash(:md5, s) |> Base.encode16

  def hashable_stream(salt) do
    Stream.unfold(0, &hashable_unfolder(&1, salt))
  end

  def hashable_unfolder(i, salt), do: {"#{salt}#{i}", i + 1}

  def has_triplet?({_, _, nil}), do: false
  def has_triplet?({_, _, _}), do: true

  def extract_triplet({s, i}) when is_binary(s) do
    triplet = 
      s
      |> String.to_char_list 
      |> extract_triplet
    {s, i, triplet}
  end

  def extract_triplet([]), do: nil
  def extract_triplet([a,a,a | _]), do: <<a::utf8>>
  def extract_triplet([_ | t]), do: extract_triplet(t)

  def extract_quint(s) when is_binary(s), do: s |> String.to_char_list |> extract_quint

  def extract_quint([]), do: nil
  def extract_quint([a,a,a,a,a | _]), do: <<a::utf8>>
  def extract_quint([_ | t]), do: extract_quint(t)
     
  
  
end
