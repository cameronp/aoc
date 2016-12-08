defmodule Aoc do
  @days [One, Two, Three, Four, Five, Six, Seven, Eight]

  def run do
    @days
    |> Enum.each(fn day_module -> apply(day_module, :run, []) end)
  end

  def time(module, part) do
    IO.puts "Running #{module}, part #{part}"
    {time, _res} = :timer.tc(fn -> run_part(module, part) end)     
    IO.puts "Completed: #{timer_format(time)}"

  end

  def run_part(module, part) do
    apply(module, ("part#{part}" |> String.to_atom), [])
  end

  def timer_format(time) when time < 1_000, do: "#{time} microseconds"
  def timer_format(time) when time < 1_000_000, do: "#{to_millis(time)} milliseconds"
  def timer_format(time), do: "#{to_seconds(time)} seconds"

  def to_millis(time), do: (time / 1_000) |> round
  def to_seconds(time), do: (time / 100_000) |> round |> fn t -> t/10 end.()
end
