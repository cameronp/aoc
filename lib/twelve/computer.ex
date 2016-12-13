defmodule Twelve.Computer do
  import Utils.Parsing
  
  defstruct memory: %{}, registers: %{a: 0, b: 0, c: 0, d: 0, ip: 0}
  
  alias Twelve.Computer

  def part1, do: solve(c: 0)
  def part2, do: solve(c: 1)


  def solve(regs) do
    load
    |> parse
    |> init_regs(regs)
    |> process
  end

  def init_regs(%Computer{} = c, c: c_val) do
    c |> set_reg(:c, c_val) 
  end

  def load(file \\ "data/twelve/input.txt") do
    file
    |> readfile
  end

  def process(%Computer{} = c) do
    case c.memory[c.registers.ip]  do
      nil -> c
      command -> c |> exec_command(command) |> process
    end
  end
  
  def exec_command(%Computer{} = c, {:cpy, from, to}) do
    val = get_val(c, from)
    c |> set_reg(to, val) |> inc_ip
  end

  def exec_command(%Computer{} = c, {:inc, arg}) do
    c |> inc_reg(arg) |> inc_ip
  end
  
  def exec_command(%Computer{} = c, {:dec, arg}) do
    c |> dec_reg(arg) |> inc_ip 
  end

  def exec_command(%Computer{} = c, {:jnz, reg, offset}) do
    case c.registers[reg] do
      0 -> c |> inc_ip
      _ -> c |> set_reg(:ip, c.registers.ip + offset)
    end
  end


  def inc_reg(%Computer{} = c, reg), do: c |> set_reg(reg, c.registers[reg] + 1)

  def dec_reg(%Computer{} = c, reg), do: c |> set_reg(reg, c.registers[reg] - 1)

  def get_val(_, v) when is_number(v), do: v
  def get_val(%Computer{} = c, a), do: c.registers[a]

  def inc_ip(%Computer{} = c), do: c |> set_reg(:ip, c.registers.ip + 1)

  def set_reg(%Computer{} = c, reg, val) do
    new_regs = 
      c.registers
      |> Map.put(reg, val)
    %{c | registers: new_regs}
  end
  
  def parse(data) do
    memory = 
      data
      |> split_and_map("\n", &parse_line/1)
      |> Enum.with_index
      |> Enum.map(fn {a,b} -> {b, a} end)
      |> Enum.into(%{})
    %Computer{memory: memory}
  end

  def parse_line("cpy " <> args) do
    [from, to] = 
      args
      |> String.split(" ")
      |> Enum.map(&parse_arg/1)
    {:cpy, from, to}
  end

  def parse_line("jnz " <> args) do
    [from, to] = 
      args
      |> String.split(" ")
      |> Enum.map(&parse_arg/1)
    {:jnz, from, to}
  end

  def parse_line("dec " <> arg) do
    {:dec, String.to_atom(arg)}
  end

  def parse_line("inc " <> arg) do
    {:inc, String.to_atom(arg)}
  end
  def parse_line(_), do: :nyi


  def parse_arg(s) do
    case Integer.parse(s) do
      {n, _} when is_number(n) -> n
      :error -> s |> String.to_atom 
    end
  end
end
