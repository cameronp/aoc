defmodule Nine.Super do
  import Utils.Parsing

  defmodule Node, do: defstruct repeats: 0, children: []

  def parse(s, version) when is_atom(version), do: parse(s, [], version)
  def parse("", res, _version), do: res |> Enum.reverse
  def parse(s, res, version) do
    case parse_node(s, version) do
      {node, rest} -> parse(rest, [node | res], version)
      :error -> take_text(s, res, version)
    end
  end
  
  def parse_node(s, version) do
    case parse_instruction(s) do
      {instruction, rest} -> build_node(instruction, rest, version)
      _ -> :error
    end
  end

  def parse_instruction("(" <> tail) do
    r = ~r/(\d+?)x(\d+?)\)(.+)/
    [_, len_s, repeat_s,  rest] = Regex.run(r, tail) 
    {{to_int(len_s), to_int(repeat_s)}, rest}
  end 
  def parse_instruction(_), do: :error

  def build_node({length, repeats}, s, version) do
    {to_parse, rest} = s |> String.split_at(length)
    children = 
      case version do
        :two -> parse(to_parse, :two)
        :one -> [to_parse]
      end
    node = %Node{children: children, repeats: repeats}
    {node, rest}
  end

  def parse_text(s), do: parse_text(s, "")
  def parse_text("", result), do: {result, ""}
  def parse_text("(" <> tail, result), do: {result, "("<>tail}
  def parse_text(<<next::binary-size(1), tail::binary>>, result), 
    do: parse_text(tail, result <> next)


  def take_text(s, res, version) do
    {text, rest} = parse_text(s)
    parse(rest, [text | res], version)
  end

  def len(list) when is_list(list) do
    list 
    |> Enum.reduce(0, fn element, sum -> sum + len(element) end)
  end
  def len(s) when is_binary(s), do: s |> String.length
  def len(%Node{repeats: r, children: cs}), do: r * len(cs)

  def assemble(list) when is_list(list) do
    list
    |> Enum.map(&assemble/1)
    |> Enum.join("")
  end
  def assemble(s) when is_binary(s), do: s
  def assemble(%Node{repeats: r, children: cs}) do
    cs
    |> assemble
    |> String.duplicate(r)
  end

  def decompress(s, version \\ :two), do: s |> parse(version) |> assemble
end
