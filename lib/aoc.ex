defmodule Aoc do
  @days [One, Two, Three, Four]

  def run do
    @days
    |> Enum.each(fn day_module -> apply(day_module, :run, []) end)
  end
end
