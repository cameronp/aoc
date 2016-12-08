defmodule Eight.Screen do
  defstruct pixels: %{}, height: 0, width: 0

  alias Eight.Screen

  def new(width, height) do
    %Screen{
      height: height,
      width: width
    }
  end
  
  def set(screen, points) when is_list(points) do
    points
    |> Enum.reduce(screen, fn p, s -> set(s, p) end)
  end

  def set(screen, point) when is_tuple(point) do
    screen.pixels
    |> Map.put(point, true)
    |> update_pixels(screen)
  end

  
  def clear(screen, points) when is_list(points) do
    points
    |> Enum.reduce(screen, fn p, s -> clear(s, p) end)
  end

  def clear(screen, point) when is_tuple(point) do
    screen.pixels
    |> Map.put(point, false)
    |> update_pixels(screen)
  end

  def rect(screen, width, height) do
    rect_points(width, height)
    |> Enum.reduce(screen, fn point, s -> set(s, point) end)
  end

  def rect_points(width, height) do
    for x<-0..(width - 1), y <- 0..(height - 1), do: {x,y} 
  end

  def get(screen, point) do
    screen.pixels[point]
  end

  def dump(screen, orientation, n) do
    screen
    |> points(orientation, n)
    |> Enum.map(fn p -> get(screen, p) end)
    |> Enum.map(&display_value/1)
    |> Enum.join("")
  end

  def display(screen) do
    0..(screen.height - 1)
    |> Enum.map(fn r -> dump(screen, :row, r) end)
    |> Enum.join("\n")
    |> IO.puts
  end
  
  def rotate(s, row_or_column, y, n) do
    max = case row_or_column do
       :row -> s.width
       :column -> s.height
    end

    [to_set, to_clear] =
      points(s, row_or_column, y)
      |> Enum.map(fn p -> {p, get(s,p)} end)
      |> Enum.map(fn {p, val} -> {rotate_point(p, row_or_column, max, n), val} end)
      |> Enum.partition(fn {_, val} -> val end)
      |> Tuple.to_list
      |> Enum.map(&just_points/1)
    s
    |> set(to_set)
    |> clear(to_clear)
  end

  def just_points(points_and_values) do
    points_and_values
    |> Enum.map(fn {p, _} -> p end)
  end

  def rotate_point({x,y}, :row, max, n) do
    new_x = (x + n) |> rem(max)
    {new_x, y}
  end

  def rotate_point({x,y}, :column, max, n) do
    new_y = (y + n) |> rem(max)
    {x, new_y}
  end

  def points(s, :row, y), do: for x <- xvals(s), do: {x, y} 
  def points(s, :column, x), do: for y <- yvals(s), do: {x, y} 

  def xvals(s), do: 0..(s.width - 1)
  def yvals(s), do: 0..(s.height - 1)
  
  def update_pixels(pixels, screen), do: %{screen | pixels: pixels}

  def display_value(true), do: "#"
  def display_value(_), do: "."
end
