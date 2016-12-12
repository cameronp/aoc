defmodule Eleven.Game do
  @floor_moves %{1 => [2], 2 => [1,3], 3 => [2,4], 4 => [3]}
  def init do
    %{ 1 => [3,4,9,10], 
      2=>[2,5,6,7,8], 
      3 => [1], 
      4 =>[], 
      e: 3, 
      moves: []  
    }
  end
  # | -,* |  ,* |...
  def display(state) do
    4..1
    |> Enum.map(&row_disp(&1,state))
    |> Enum.join("\n")
    |> IO.puts
  end

  def row_disp(row, state) do
    state[row]
    |> row_disp
  end


  def row_disp(row) do
    1..10
    |> Enum.map(&char_for(&1, row)) 
    |> Enum.chunk(2)
    |> Enum.map(&Enum.join(&1, ","))
    |> Enum.join("|")
    
  end

  @items ~w(E TM TG SM SG RM RG CM CG PM PG)
  
  def char_for(i, row) when rem(i,2) == 0, do: char_for(i, row, &red/1)
  def char_for(i, row), do: char_for(i, row, &yellow/1)

  def char_for(i, row, color) do
    case i in row do
      true -> @items |> Enum.at(i) |> color.()
      false -> ".."
    end     
  end

  def red(s), do: IO.ANSI.red <> s <> IO.ANSI.white
  def yellow(s), do: IO.ANSI.yellow <> s <> IO.ANSI.white


end
