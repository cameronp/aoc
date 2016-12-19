defmodule Sixteen do

  def part1, do: solve("10001001100000001", 272)
  def part2, do: solve("10001001100000001", 35651584)

  def solve(initial, size) do
    initial
    #|> message("filling")
    |> fill(size)
    #|> message("generating cs")
    |> checksum
  end

  def message(val, s) do
    IO.puts(s)
    val
  end

  def invert(""), do: ""
  def invert("1" <> tail), do: "0" <> invert(tail)
  def invert("0" <> tail), do: "1" <> invert(tail)
  
  def expand(a) do
    b = 
      a
      |> String.reverse
      |> invert

    a <> "0" <> b
  end

  def generate(cur, target_size), 
    do: generate(cur, String.length(cur), target_size)

  def generate(cur, len, target_size) when len < target_size do
    next = cur |> expand
    next_len = (2 * len) + 1 
    #IO.puts("generating, length: #{next_len}")
    generate(next, next_len, target_size)
  end

  def generate(cur, _len, _target), do: cur

  def fill(initial, length) do
    initial
    |> generate(length)
    |> String.slice(0,length)
  end

  def checksum(s), do: checksum(s, String.length(s))

  def checksum(s, len) when rem(len, 2) == 1, do: s
  def checksum(s, len) do
    next = 
      s
      |> pairs
      |> Enum.map(&pair_mapper/1)
      |> Enum.join("")
    checksum(next, div(len, 2)) 
  end

  def pair_mapper(<<a::binary-size(1), a::binary-size(1)>>), do: "1"
  def pair_mapper(_), do: "0"


  def pairs(""), do: []
  def pairs(<<pair::binary-size(2), tail::binary>>) do
    [pair | pairs(tail)]
  end
  
end
