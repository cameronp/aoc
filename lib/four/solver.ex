defmodule Four.Solver do
  import Utils.Parsing

  defmodule Token do
    defstruct name: "", checksum: [], sector_id: 0, letters: %{}, crypted: ""

    def new do
     %Token{letters: init_letter_map}
    end

    def valid?(%Token{} = t) do
      t.checksum == compute_checksum(t)
    end

    def compute_checksum(%Token{letters: letters}) do
      fifth_frequency = 
        letters
        |> nth_frequency(5)

      letters
        |> occuring_at_least(fifth_frequency)
        |> Enum.sort(&letter_comparator/2)
        |> Enum.take(5)
        |> just_keys
    end

    def occuring_at_least(letters, freq) do
      letters
      |> Enum.filter(fn {_k, v} -> v >= freq end)
    end

    def decrypt(t) do
      name = 
        _decrypt(t.crypted, t.sector_id)
      %{t | name: name}
    end

    def _decrypt("", _), do: ""
    def _decrypt("-" <> tail, rot), do: " " <> _decrypt(tail, rot)
    def _decrypt(<<c :: utf8, tail::binary>>, rot) do
      new_c = rot_x(c, rot)
      <<new_c::utf8>> <> _decrypt(tail, rot)
    end

    def rot_x(c, 0), do: c
    def rot_x(c, n) when n > 25, do: rot_x(c, rem(n, 26))
    def rot_x(c, n) do
      case c + n do
        res when res <= ?z -> res
        rotate -> rotate - ?z - 1 + ?a
      end
    end

    defp just_keys(pairs) do
      pairs 
      |> Enum.map(fn {k,_v} -> k end)
    end

    # Produces a map of letters to zeros.. %{"a" => 0, "b" => 0...}
    defp init_letter_map do
      ?a..?z
      |> Enum.map(fn c -> <<c::utf8>> end)
      |> Enum.reduce(%{}, fn l, ls -> Map.put(ls, l, 0) end)
    end

    # compares two letter / frequency pairs.  Sorts primarily on frequency
    # with alphabetical order of the letter as a tie-breaker
    defp letter_comparator({k1, v1}, {k2, v2}) when v1 == v2, do: k1 < k2
    defp letter_comparator({_, v1}, {_, v2}), do: v1 > v2

    # Returns the count of characters in nth place sorted by frequency, highest
    # to lowest. so if the map is %{"a" => 4, "b" => "2", "c" => 2, "d" => 0}
    # then nth_frequency(map, 3), will return 2.
    defp nth_frequency(%{} = letters, n) do
      letters
        |> Enum.sort(fn {_, a}, {_, b} -> a > b end)
        |> Enum.at(n-1)
        |> elem(1)
    end
  end

  alias Token

  def part1 do
    load
    |> parse
    |> solve
  end

  def part2 do
    load
    |> parse
    |> Enum.filter(fn t -> Token.valid?(t) end)
    |> decode
    |> Enum.find(fn t -> t.name =~ "northpole" end)
    |> Map.get(:sector_id)
  end
  
  def decode(tokens) do
    tokens
    |> Enum.map(&Token.decrypt/1)
  end

  def solve(input) do
    input 
    |> Enum.filter(fn t -> Token.valid?(t) end)
    |> Enum.reduce(0, fn t, sum -> sum + t.sector_id end)
  end

  def load(file \\ "data/four/input.txt") do
    file
    |> readfile
  end

  def parse(s) do
    s 
    |> split_and_map("\n", &parse_token/1)
  end

  def parse_token(s) do
    token = _parse_token(s, Token.new)
    name = 
      s
      |> String.split("[")
      |> hd
      |> String.replace(~r/[0-9]/, "")
    %{token | crypted: name}
  end

  def _parse_token("", t), do: t
  def _parse_token("-" <> tail, t), do: tail |> _parse_token(t)
  def _parse_token(<<letter::utf8, tail::binary>>, 
                   %Token{} = t)
      when letter in ?a..?z do
    l = <<letter::utf8>>
    new_letters = Map.put(t.letters, l, t.letters[l] + 1)
    new_t = %{t | letters: new_letters}
    _parse_token(tail, new_t) 
  end

  def _parse_token(<<n::utf8, _tail::binary>> = s, t) when n in ?0..?9 do
    {id, checksum_raw} = Integer.parse(s)
    checksum = 
      checksum_raw 
      |> parse_checksum

    %{t | sector_id: id, checksum: checksum}
  end

  def parse_checksum(s) do
    s
    |> String.replace(~r/[\[\]]/, "", global: true)
    |> String.split("", trim: true)
  end



end
