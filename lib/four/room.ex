defmodule Four.Room do
  import Utils.Parsing
  defstruct name: "", checksum: [], sector_id: 0, letters: %{}, crypted: ""
  alias Four.Room

  def new do
    %Room{}
  end

  def new(s) when is_binary(s), do: build_room(s)

  def valid?(%Room{} = r), do: r.checksum == compute_checksum(r)

  def decrypt(r), do: %{r | name: _decrypt(r.crypted, r.sector_id)}

  def build_room(s) do
    record = parse_record(s)
    Room.new
    |> count_letters(record.crypted)
    |> set_sector_id(record.sector_id)
    |> set_crypted(record.crypted)
    |> set_checksum(record.checksum)
 end

  defp parse_record(s) do
      ~r/(?<crypted>.+)-(?<sector_id>[0-9]+)\[(?<checksum>[a-z]+)/
       |> Regex.named_captures(s)
       |> atomize_keys
  end

  defp set_crypted(r, s), do: %{r | crypted: s}

  defp set_sector_id(%Room{} = r, s), do: %{r | sector_id: to_int(s)}

  defp set_checksum(%Room{} = r, s), 
    do: %{r | checksum: String.split(s, "", trim: true)}

  defp count_letters(r, ""), do: r
  defp count_letters(r, "-" <> tail), do: r |> count_letters(tail)
  defp count_letters(%Room{} = r,<<letter::utf8, tail::binary>>) do
    l = <<letter::utf8>>
    new_r = %{r | letters: Map.update(r.letters, l, 1, &(&1 + 1))}
    count_letters(new_r, tail) 
  end

  defp compute_checksum(%Room{letters: letters}) do
    letters
    |> Enum.sort_by(fn {_, v} -> v end, &Kernel.>=/2)
    |> Enum.take(5)
    |> just_keys
  end

  defp _decrypt("", _), do: ""
  defp _decrypt("-" <> tail, rot), do: " " <> _decrypt(tail, rot)
  defp _decrypt(<<c :: utf8, tail::binary>>, rot) do
    new_c = rot_x(c, rot)
    <<new_c::utf8>> <> _decrypt(tail, rot)
  end

  defp rot_x(c, 0), do: c
  defp rot_x(c, n) when n > 25, do: rot_x(c, rem(n, 26))
  defp rot_x(c, n) do
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
