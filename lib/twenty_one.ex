defmodule TwentyOne do
  import Utils.Parsing

  def crack(cmds, target) do
    letters = target |> String.split("")
    combos = for a <- letters, 
                 b <- letters -- [a], 
                 c <- letters -- [a,b],
                 d <- letters -- [a,b,c],
                 e <- letters -- [a,b,c,d],
                 f <- letters -- [a,b,c,d,e],
                 g <- letters -- [a,b,c,d,e,f],
                 h <- letters -- [a,b,c,d,e,f,g],
                 do: a <> b <> c <> d <> e <> f <> g <> h
    combos
    |> Enum.filter(fn att -> String.length(att) == 8 end)
    |> Enum.find(fn attempt -> do_process(cmds, attempt) == target end)
    #|> Enum.find( fn att -> String.length(att) != 8 end)
  end

  def test(file \\ "data/twenty_one/test.txt") do
    file
    |> load
    |> parse
    |> do_process("abcde")
  end

  def solve3(file \\ "data/twenty_one/input.txt") do
    file
    |> load
    |> parse
    |> do_process("cegdahbf") 
  end

  def solve2(file \\ "data/twenty_one/input.txt") do
    file
    |> load
    |> parse
    |> crack("fbgdceah")
  end

  def solve(file \\ "data/twenty_one/input.txt") do
    file
    |> load
    |> parse
    |> do_process("abcdefgh")
  end

  def load(file), do: file |> readfile


  def parse(data) do
    data
    |> split_and_map("\n", &parse_line/1)
  end

  def do_process(cmds, s), do: process(s, cmds)

  def log_handle_cmd(s, cmd) do
    handle_cmd(s, cmd)
  end

  def process(s, []), do: s
  def process(s, [cmd | t]), do: s |> log_handle_cmd(cmd) |> process(t)
  
  def handle_cmd(s, {:swap_pos, x, y}), do: swap_pos(s, x, y)
  def handle_cmd(s, {:swap_l, x, y}), do: swap_letter(s, x, y)
  def handle_cmd(s, {:rev, x, y}), do: reverse(s, x, y)
  def handle_cmd(s, {:move, x, y}), do: move(s, x, y)
  def handle_cmd(s, {:rot, dir, count}), do: rot(s, dir, count)
  def handle_cmd(s, {:rot_b, letter}), do: rotate_based(s, letter)

  def parse_line(line) do
    case match(line) do
      [_, "swap letter", x, y] -> {:swap_l, x, y}
      [_, "swap position", x, y] -> {:swap_pos, to_int(x), to_int(y)}
      [_, "reverse positions", x, y] -> {:rev, to_int(x), to_int(y)}
      [_, "move", x, y] -> {:move, to_int(x), to_int(y)}
      [_, "rotate based", x] -> {:rot_b, x}
      [_, "rotate", dir, count] -> 
        {:rot, String.to_atom(dir), to_int(count)}

    end
  end
  
  def match(s) do
    [
      ~r/(swap position) (\d+) with position (\d+)/,
      ~r/(swap letter) (\w) with letter (\w)/,
      ~r/(reverse positions) (\d+) through (\d+)/,
      ~r/(rotate) (left|right) (\d+) step/,
      ~r/(rotate based) on position of letter (\w)/,
      ~r/(reverse) positions (\d+) through (\d+)/,
      ~r/(move) position (\d+) to position (\d+)/
    ]
    |> Enum.map(fn r -> Regex.run(r,s) end) 
    |> Enum.find(fn match -> match end)
  end

  def move(s, x, y) when x > y do
    len = String.length(s)
    [
      String.slice(s, 0, y),
      String.slice(s, x, 1),
      String.slice(s, y, x - y),
      String.slice(s, x + 1, len)
    ]
    |> Enum.join("")
  end
  def move(s, x, y) do
    len = String.length(s)
    [
      String.slice(s, 0, x),
      String.slice(s, x + 1, y - x),
      String.slice(s, x, 1),
      String.slice(s, y + 1, len)
    ]
    |> Enum.join("")
  end

  def reverse(s, x, y) when x > y, do: reverse(s, y, x)
  def reverse(s, x, y) do
    len = String.length(s)
    to_rev = String.slice(s, x, y - x + 1)
    [
      String.slice(s, 0, x),
      String.reverse(to_rev),
      String.slice(s, y + 1, len)
    ]
    |> Enum.join("")
  end

  def rotate_based(s, letter) do
    case find_index(s, letter) do
      i when i >= 4 -> rot(s, :right, i + 2)
      i -> rot(s, :right, i + 1)
    end
  end

  def rot(s, _dir, 0), do: s
  def rot(s, dir, count), do: s |> rot_one(dir) |> rot(dir, count - 1)

  def rot_one(s, :right) do
    len = String.length(s)
    [
      String.slice(s, -1, 1),
      String.slice(s, 0, len - 1)
    ]
    |> Enum.join("")
  end

  def rot_one(s, :left) do
    len = String.length(s)
    [
      String.slice(s, 1, len),
      String.slice(s, 0, 1)
    ]
    |> Enum.join("")
  end

  def swap_letter(s, x, y) do
    x_pos = find_index(s, x)
    y_pos = find_index(s, y)
    swap_pos(s, x_pos, y_pos)
  end

  def find_index(s, target), do: find_index(s, target, 0)
  def find_index("", _, _), do: nil
  def find_index(<<c::binary-size(1), _t::binary>>, c, n), do: n
  def find_index(<<_::binary-size(1), t::binary>>, c, n), 
    do: t |> find_index(c, n + 1)

  def swap_pos(s, x, y) when x > y, do: swap_pos(s, y, x)
  def swap_pos(s, x, x), do: s
  def swap_pos(s, x, y) do
    len = String.length(s)

    [
      String.slice(s, 0, x), 
      String.slice(s, y, 1), 
      String.slice(s, x+1,y - x - 1),
      String.slice(s, x, 1),
      String.slice(s, y + 1, len),
    ]
    |> Enum.join("")
  end


end
