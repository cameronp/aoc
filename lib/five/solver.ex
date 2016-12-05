defmodule Five.Solver do
  import Utils.Parsing

  def part1, do: solve()
  def part2, do: solve2()

  def solve() do
    "reyedfim"
    |> hash_stream
    |> Stream.filter(&MD5.encode/1)    
    |> Enum.take(8)
    |> Enum.map(&sixth/1)
  end

  def solve2() do
    {:ok, agent} = Agent.start(fn -> %{} end)
    "reyedfim"
    |> hash_stream
    |> Stream.filter(fn h -> very_interesting(h, agent) end)
    |> Enum.take(8)
  end

  def very_interesting("00000" <> <<pos::utf8, val::utf8, _t::binary>>, agent) 
  when pos >= ?0 and pos < ?8
  do
    case Agent.get(agent, fn map -> map[<<pos::utf8>>] end) do
      nil -> store(pos,val,agent)
      _ -> false
    end
  end

  def very_interesting(_, _), do: false

  def store(pos, val, agent) do
    Agent.update(agent, fn map -> Map.put(map, <<pos::utf8>>, <<val::utf8>>) end)
    IO.puts(<<pos::utf8>> <> " : " <> <<val::utf8>>)
  end

  def load(file \\ "data/five/input.txt") do
    file
    |> readfile
  end

  def parse(data) do
    data
  end

  def sixth("00000" <> <<c::utf8, _t::binary>>), do: <<c::utf8>>

  def hash_stream(base) do
    Stream.unfold({base, 0}, fn {base, n} -> gen_candidate(base, n) end)
    |> Stream.map(fn s -> MD5.encode(s) end)
  end

  def gen_candidate(base, n), do: {"#{base}#{n}", {base, n+1}}
  
  def interesting?("00000" <> _tail), do: true
  def interesting?(_), do: false

end
