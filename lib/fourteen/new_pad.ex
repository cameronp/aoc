defmodule NewPad do

  def solve(salt, n) do
    salt
    |> key_stream
    |> Enum.take(2*n)
    |> Enum.sort_by(fn {{_key, i}, _} -> i end)
    |> Enum.take(n)
    |> Enum.reverse
    |> Enum.map(fn {{_, i}, _} -> i end)
    |> hd
  end


  def key_stream(salt)  do
    salt
    |> candidate_stream
    |> Stream.transform([], &key_reducer/2)
  end

  def key_reducer({{_trip, nil}, i} = current, past_candidates) do
    new_past = 
      past_candidates
      |> prune(i)
    {[], [current | new_past]}
  end

  def key_reducer({{_, quint}, i} = current, past_candidates) do
    new_past =
      past_candidates
      |> prune(i)

    keys = 
      new_past
      |> find_keys(quint)
      |> Enum.map(&attach_match(&1, current))

    {keys, [current | new_past]}
  end

  def attach_match(key, current), do: {key, current}

  def find_keys(past, quint) do
    past
    |> Enum.filter(fn {{trip, _}, _} -> trip == quint end)
  end

  def prune(candidates, i) do
    candidates
    |> Enum.filter(fn {_, past_i} -> past_i + 1000 >= i end)
  end

  def candidate_stream(salt) do
    salt
    |> hashable_stream
    |> Stream.map(&stretched_hash/1)
    |> Stream.map(&extract_triplet_and_quint/1)
    |> Stream.with_index
    |> Stream.filter(&interesting?/1)
  end

  def interesting?({{trip, quint}, _}) when trip != nil or quint != nil, do: true
  def interesting?({{_,_},_}), do: false

  def extract_triplet_and_quint(s) do
    {extract_triplet(s), extract_quint(s)}
  end
  
  def extract_triplet(""), do: nil
  def extract_triplet(<<a::utf8,a::utf8,a::utf8, _::binary>>), do: <<a::utf8>> 
  def extract_triplet(<<_::utf8, t::binary>>), do: extract_triplet(t)
    
  def extract_quint(""), do: nil
  def extract_quint(<<a::utf8, a::utf8, a::utf8,a::utf8,a::utf8, _::binary>>), do: <<a::utf8>> 
  def extract_quint(<<_::utf8, t::binary>>), do: extract_quint(t)

  
  def stretched_hash(s) do
    1..2017
    |> Enum.reduce(s, fn _i, acc -> hash(acc) end)
  end

  def hash(s), do: :crypto.hash(:md5, s) |> Base.encode16(case: :lower)


  def hashable_stream(salt) do
    Stream.unfold(0, &hashable_unfolder(&1, salt))
  end

  def hashable_unfolder(i, salt) do
    {"#{salt}#{i}", i + 1}
  end



end
