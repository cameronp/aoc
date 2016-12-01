defmodule Utils.Parsing do
  

  def readfile(f) do
    {:ok, s} = File.read(f)
    s
  end

  def to_int(s) do
    {i, ""} = Integer.parse(s) 
    i
  end

  def split_and_map(s, delimiter, fun) do
    s
    |> String.split(delimiter, trim: true)
    |> Enum.map(&String.rstrip/1)
    |> Enum.map(fun)
  end

end
