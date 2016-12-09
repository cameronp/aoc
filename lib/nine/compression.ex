defmodule Nine.Compression do
  import Utils.Parsing

  def decompress(s), do: decompress(s, [])

  def decompress("", res), do: res |> Enum.reverse |> Enum.join
  def decompress("(" <> tail, res) do
     {marker, rest} = ("(" <> tail) |> capture_marker
     {pattern, rest2} = capture_pattern(marker, rest)
     repeated = repeated_pattern(marker, pattern)
     decompress(rest2, repeated ++ res)
  end

  def decompress(s, res) do
    r = ~r/(.+?)(\(.+)/
    case Regex.run(r,s) do
      [_, uncompressed, rest] -> decompress(rest, [uncompressed | res])
      nil -> decompress("", [s | res])
    end

  end
  
  def repeated_pattern({_, count}, pattern) do
    1..count
    |> Enum.map(fn _ -> pattern end)
  end

  def capture_marker(s) do
    r = ~r/\((\d+)x(\d+)\)(.+)/
    case Regex.run(r, s) do
      [_, length, count, rest] -> {{to_int(length), to_int(count)}, rest}
      nil -> :error
    end
  end

  def capture_pattern({length, _}, data) do
    data
    |> String.split_at(length)
  end

  
end
