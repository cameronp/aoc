defmodule Utils.Parsing do
@moduledoc """
Helper functions to assist in parsing input data.
"""  

@doc """
Takes a path, returns a binary.  Easier for pipelining.
"""
  def readfile(f) do
    {:ok, s} = File.read(f)
    s
  end

@doc """
Optimistically parse an integer
"""
  def to_int(s) do
    {i, ""} = Integer.parse(s) 
    i
  end

  @doc """
Splits a binary on the specified delimeter, strips the resulting binaries, and calls
the passed in function over them.
  """
  def split_and_map(s, delimiter, fun) do
    s
    |> String.split(delimiter, trim: true)
    |> Enum.map(&String.rstrip/1)
    |> Enum.map(fun)
  end

end
