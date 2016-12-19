defmodule Nineteen do
  
  def setup_circle(count) do
    1..count
    |> Enum.map(fn i -> {i, 1} end)
  end

  def go_round(circle), do: go_round(circle, [])

  def go_round([a], []), do: a
  def go_round([], [a]), do: a
  def go_round([], done), do: done |> Enum.reverse |> go_round([])
  def go_round([a], done) do
    next = done |> Enum.reverse
    go_round([a | next], [])
  end
  def go_round([{id_a, c_a},{_, c_b} | t], done) do
    go_round(t, [{id_a, c_a + c_b} | done]) 
  end


  def solve2, do: solve_quickly(3014387)

  def solve_quickly(n) do
    n 
    |> Integer.digits(3)
    |> compute
  #find the largest power of 3 < n, call it m
  #if n - m < m, then n - m is the answer
  #otherwise, I'm not sure.  at 2m it starts going by 2's
  end

  def compute([1 | _t] = trits) do
    original = trits |> Integer.undigits(3) 
    len = Enum.count(trits)
    high_power = :math.pow(3, len-1) |> round
    original - high_power
  end

  def solve(n) do
    n
    |> setup_circle
    |> across(n, [])
  end

  def solve_many(n) do
    1..n
    |> Enum.map(&solve/1)
    |> Enum.map(fn {i, _} -> i end)
    |> Enum.with_index
    |> Enum.map(fn {win, i} -> {i + 1, win} end)
  end

  def dump(list) do
    list
    |> Enum.map(fn {n, w} -> "#{n} : #{w}" end)
    |> Enum.join("\n")
    |> IO.puts
  end

  def check_count(count) when rem(count,100) == 0, 
    do: IO.puts("#{count}")
  def check_count(_), do: :ok


  def across([], 1, [last]), do: last
  def across([last], 1, []), do: last

  def across(list, count, done) do
    check_count(count)
    if Enum.count(list) >= (to_count(count) + 1) do
      across_normal(list,count,done) 
    else
      next = done |> Enum.reverse
      across(list ++ next, count, [])
    end
  end

  def across_normal(list, count, done) do
    {[{id_a, c_a} | t], [{_, c_b} | t1]} =
      list
      |> Enum.split(to_count(count))
    across(t ++ t1, count - 1, [{id_a, c_a + c_b} | done])
  end


  def to_count(count), do: div(count,2)
end
