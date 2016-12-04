defmodule Four.Solver do
  import Utils.Parsing

  defmodule Token do
    defstruct name: "", checksum: [], sector_id: 0, letters: %{},
      crypted: ""

    def new do
      letters = 
        ?a..?z
        |> Enum.map(fn c -> <<c::utf8>> end)
        |> Enum.reduce(%{}, fn l, ls -> Map.put(ls, l, 0) end)
      %Token{letters: letters}
    end

    def valid?(%Token{} = t) do
      expected_checksum = checksum(t.letters)
      expected_checksum == t.checksum
    end

    def checksum(%{} = letters) do
      fifth_frequency = 
        letters
        |> Enum.sort_by(fn {_k, v} -> v end)
        |> Enum.reverse
        |> Enum.take(5)
        |> Enum.reverse
        |> hd
        |> elem(1)

      letters
        |> Enum.filter(fn {_k, v} -> v >= fifth_frequency end)
        |> Enum.sort( fn {k1, v1}, {k2, v2} when v1 == v2 -> k1 < k2
                         {_, v1}, {_, v2} -> v1 >= v2
                      end)
        |> Enum.take(5)
        |> Enum.map(fn {k,_v} -> k end)
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
    def rot_x(c, n) when c == ?z, do: ?a |> rot_x(n-1)
    def rot_x(c, n), do: (c + 1) |> rot_x(n - 1)

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
