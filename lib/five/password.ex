defmodule Five.Password do
  @puzzle_input "reyedfim"

  alias Experimental.Flow

  def part1(input \\ @puzzle_input), 
    do: solve(input, &interesting?/1, &construct_part1/1)

  def part2(input \\ @puzzle_input), 
    do: solve(input, &very_interesting?/1, &construct_part2/1)

  def solve(input, hash_selector, code_constructor) do
    flow_of_hashes(input)  
    |> Flow.filter(hash_selector)
    |> code_constructor.()
  end

  def construct_part1(flow) do
    flow
    |> Flow.map(&sixth_char/1)
    |> Enum.take(8)
    |> Enum.join("")
  end

  def construct_part2(flow) do
    flow
    |> Flow.map(&pos_and_value/1)
    |> Enum.reduce_while(%{}, &pos_and_val_reducer/2)
    |> code_from_map
  end

  def flow_of_hashes(input) do
    Stream.iterate(0, &(&1 + 1))
    |> Flow.from_enumerable
    |> Flow.map(&generate_hashable(&1, input))
    |> Flow.map(&md5/1)
  end

  def generate_hashable(n, base), do: "#{base}#{n}"

  def md5(s), do: :crypto.hash(:md5, s) |> Base.encode16

  def sixth_char(s), do: s |> String.slice(5,1)
  def seventh_char(s), do: s |> String.slice(6,1)

  def interesting?("00000" <> _tail), do: true
  def interesting?(_), do: false

  def very_interesting?("00000" <> <<pos::utf8>> <> _t) when pos in ?0..?7, do: true
  def very_interesting?(_), do: false

  def pos_and_value(hash), do: {sixth_char(hash), seventh_char(hash)}

  def pos_and_val_reducer(entry, %{} = positions) do
    if Enum.count(positions) == 8 do
      {:halt, positions}
    else
      {:cont, store_if_new(entry, positions)}
    end
  end

  def store_if_new({pos, val}, positions) do
    case positions[pos] do
      nil -> Map.put(positions, pos, val) 
      _ -> positions
    end
  end
 
  def code_from_map(%{} = map)  do
    0..7
    |> Enum.map(&to_string/1)
    |> Enum.map(fn pos -> map[pos] end)
    |> Enum.join("")
  end
end
