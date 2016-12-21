defmodule Dragon do

  def fill(seed, size) do 
    _fill(seed, String.length(seed), size) 
    |> eval_deferred
    |> String.slice(0,size)
  end

  def _fill(current, cur_len, size) when cur_len >= size, do: current
  def _fill(current, cur_len, size) do
    current
    |> step_defer
    |> _fill(cur_len * 2 + 1, size)
  end

  def step_defer(a) do
    [a, "0", (a |> rev_defer |> not_defer)]
  end

  def rev_defer([:rev, a]), do: a
  def rev_defer([:not, a]), do: [:rev, not_defer(a)]

  def rev_defer(a) when is_list(a) do
    a
    |> Enum.reverse
    |> Enum.map(&rev_defer/1)
  end

  def rev_defer("0"), do: "0"
  def rev_defer("1"), do: "1"
  def rev_defer(a) when is_binary(a), do: [:rev, a]

   
  def not_defer([:not, a]), do: a
  def not_defer([:rev, a]), do: [:rev, not_defer(a)]

  def not_defer(a) when is_list(a) do
    a
    |> Enum.map(&not_defer/1)
  end

  def not_defer("0"), do: "1"
  def not_defer("1"), do: "0"
  def not_defer(a) when is_binary(a), do: [:not, a]

  def eval_deferred(a) when is_binary(a), do: a

  def eval_deferred([:rev, a]) when is_binary(a) do
    String.reverse(a) 
  end

  def eval_deferred([:rev, a]) when is_list(a) do
    a
    |> eval_deferred
    |> String.reverse
  end

  def eval_deferred([:not, a]) when is_binary(a) do
    a
    |> knot
  end

  def eval_deferred([:not, a]) when is_list(a) do
    a
    |> eval_deferred
    |> knot
  end

  def eval_deferred(l) when is_list(l) do
    l
    |> Enum.map(&eval_deferred/1)
    |> Enum.join("")
  end


  def knot(""), do: ""
  def knot("1" <> t), do: "0" <> knot(t)
  def knot("0" <> t), do: "1" <> knot(t)
  

  

end
