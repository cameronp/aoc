defmodule MD5 do

  def encode(input), do: convert_to_hex_string(encode_raw(input))

  def encode_raw(string), do: :erlang.md5(string)

  def convert_to_hex_string(<<>>), do: ""
  def convert_to_hex_string(<< head :: unsigned-integer-size(8), tail :: binary>>), do:
    convert_to_hex_value(head) <> convert_to_hex_string(tail)

  def convert_to_hex_value(byte) do
    hex_digit(div(byte, 16)) <> hex_digit(rem(byte,16))
  end

  def hex_digit(value) do
      map = %{10 => "A", 11 => "B", 12 => "C", 13 => "D", 14 => "E", 15 => "F"}
      cond do
        (value < 0) -> :error
        (value > 15) -> :error
        (value <= 9) -> to_string(value)
        true -> map[value]
      end
  end
end
