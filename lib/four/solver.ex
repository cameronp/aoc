defmodule Four.Solver do
  import Utils.Parsing

  defmodule Token do
    defstruct name: "", checksum: [], sector_id: 0, letters: %{}, crypted: ""

    def new do
     %Token{}
    end

    def valid?(%Token{} = t) do
      t.checksum == compute_checksum(t)
    end

    def compute_checksum(%Token{letters: letters}) do
      letters
      |> Enum.sort_by(fn {_, v} -> v end, &Kernel.>=/2)
      |> Enum.take(5)
      |> just_keys
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
  end
  
  def part1, do: solve(&sum_ids/1)
  def part2, do: solve(&find_storeroom/1)

  def sum_ids(tokens) do
    tokens 
    |> Enum.reduce(0, fn t, sum -> sum + t.sector_id end)
  end

  def find_storeroom(tokens) do
    tokens    
    |> Enum.find(fn t -> t.name =~ "northpole" end)
    |> Map.get(:sector_id)
  end

  def validate(tokens) do
    tokens
    |> Enum.filter(&Token.valid?/1)
  end

  def decode(tokens) do
    tokens
    |> Enum.map(&Token.decrypt/1)
  end

  def solve(solver) do
    load
    |> parse
    |> validate
    |> decode
    |> solver.()
  end

  def load(file \\ "data/four/input.txt") do
    file
    |> readfile
  end

  def parse(s) do
    s 
    |> split_and_map("\n", &build_token/1)
  end

  def build_token(s) do
    record = parse_record(s)
    Token.new
    |> count_letters(record.crypted)
    |> set_sector_id(record.sector_id)
    |> set_crypted(record.crypted)
    |> set_checksum(record.checksum)
 end

  def parse_record(s) do
      ~r/(?<crypted>.+)-(?<sector_id>[0-9]+)\[(?<checksum>[a-z]+)/
       |> Regex.named_captures(s)
       |> atomize_keys
  end

  def set_crypted(token, s) do
   %{token | crypted: s}
  end

  def count_letters(t, ""), do: t
  def count_letters(t, "-" <> tail), do: t |> count_letters(tail)
  def count_letters(%Token{} = t,<<letter::utf8, tail::binary>>) do
    l = <<letter::utf8>>
        new_t = %{t | letters: Map.update(t.letters, l, 1, &(&1 + 1))}
    count_letters(new_t, tail) 
  end

  def set_sector_id(%Token{} = t, s) do
    %{t | sector_id: to_int(s)}
  end

  def set_checksum(%Token{} = t, s) do
    checksum =
      s
      |> String.split("", trim: true)
    %{t | checksum: checksum}
  end
end
