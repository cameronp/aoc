defmodule Seven.TLS do
 defmodule State do
    defstruct abba_outside: false, abba_inside: false, brace_level: 0
  end
  def supported?(s) when is_binary(s), do: s |> String.to_char_list |> supported?(%State{})



  def supported?([], s), do: s.abba_outside && !s.abba_inside
  def supported?([a,b,b,a | t], %State{brace_level: 0} = s) when a != b, 
    do: t |> supported?(%{s | abba_outside: true})
  def supported?([a,b,b,a | t], s) when a != b, 
    do: t |> supported?(%{s | abba_inside: true})
  def supported?([?[ | t], %State{brace_level: bl} = s),
    do: t |> supported?(%{s | brace_level: bl + 1}) 
  def supported?([?] | t], %State{brace_level: bl} = s),
    do: t |> supported?(%{s | brace_level: bl - 1}) 
  def supported?([_a | t], s), do: t |> supported?(s)


  
end
