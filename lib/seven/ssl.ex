defmodule Seven.SSL do
  defmodule State do
    defstruct abas: %{}, babs: %{}, brace_level: 0

    def record_aba(s,a,b)  do
      abas = 
        s.abas
        |> Map.put({a,b}, true)
      %{s | abas: abas}
    end

    def record_bab(s,b,a)  do
      babs = 
        s.babs
        |> Map.put({b,a}, true)
      %{s | babs: babs}
    end
  end  

  def supported?(s) when is_binary(s), 
    do: s |> String.to_char_list |> supported?

  def supported?(list) do
    list 
    |> scan_for_abas 
    |> scan_for_babs(list)
    |> find_matching_abas_and_babs 
  end


  def find_matching_abas_and_babs(%State{} = s) do
    s.abas
    |> Map.keys
    |> Enum.any?(fn {a, b} -> s.babs[{b, a}] end)
  end

  def scan_for_abas(list) when is_list(list), 
    do: scan_for_abas(list, %State{})

  def scan_for_abas([], s), do: s
  def scan_for_abas([a,b,a | t], %{brace_level: 0} = s) when a != b, do: 
    scan_for_abas([b,a | t], State.record_aba(s, a, b))
  def scan_for_abas([?[ | t], %State{brace_level: bl} = s),
    do: t |> scan_for_abas(%{s | brace_level: bl + 1}) 
  def scan_for_abas([?] | t], %State{brace_level: bl} = s),
    do: t |> scan_for_abas(%{s | brace_level: bl - 1}) 
  def scan_for_abas([_a | t], s), do: scan_for_abas(t,s)

  def scan_for_babs(s, []), do: s
  def scan_for_babs(%{brace_level: bl} = s, [b, a, b | t])
    when (b != a) and (bl > 0),
    do: scan_for_babs(State.record_bab(s, b, a), [a,b | t])
  def scan_for_babs(%State{brace_level: bl} = s, [?[ | t]),
    do: scan_for_babs(%{s | brace_level: bl + 1}, t) 
  def scan_for_babs(%State{brace_level: bl} = s, [?] | t]),
    do: scan_for_babs(%{s | brace_level: bl - 1}, t) 
  def scan_for_babs(s, [_b | t]), do: s|> scan_for_babs(t)
  


end
