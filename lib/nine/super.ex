defmodule Nine.Super do
  defmodule Node do
    defstruct repeats: 0, children: []
    alias Nine.Super.{Instruction, Text}
    def parse(s) do
      case Instruction.parse(s) do
        {instruction, rest} -> build_node(instruction, rest)
        _ -> :error
      end
    end

    def build_node({length, repeats}, s) do
      {to_parse, rest} = 
        s
        |> String.split_at(length)
      children = 
        Nine.Super.parse(to_parse)
      node = %Node{children: children, repeats: repeats}
      {node, rest}
    end
  end

  defmodule Instruction do
    alias Nine.Super.Value
    def parse("(" <> tail) do
      with {length, "x" <> rest} <- Value.parse(tail),
           {repeats, ")" <> rest1} <- Value.parse(rest) do
             {{length, repeats}, rest1}
           else
             :error -> :error
             _ -> :error
           end
    end
  
    def parse(_), do: :error
  end

  defmodule Text do
    def parse(s), do: parse(s, "")
    def parse("", result), do: {result, ""}
    def parse("(" <> tail, result), do: {result, "("<>tail}
    def parse(<<next::binary-size(1), tail::binary>>, result), 
      do: parse(tail, result <> next)
  end

  defmodule Value do
    def parse(s) do
      s
      |> Integer.parse
    end
  end
  
  alias Nine.Super.Node

  def parse(s), do: parse(s, [])
  def parse("", res), do: res |> Enum.reverse
  def parse(s, res) do
    case Node.parse(s) do
      {node, rest} -> parse(rest, [node | res])
      :error -> try_text(s, res)
    end
  end

  def try_text(s, res) do
    {text, rest} = Text.parse(s)
    parse(rest, [text | res])
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

  def decompress(s), do: s |> parse |> assemble
end
