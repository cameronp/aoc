defmodule Ten.Solver do
  import Utils.Parsing
  import String, only: [to_atom: 1]

  def solve(input \\ "data/ten/input.txt") do
    input
    |> readfile
    |> parse
    |> process
  end

  def parse(data) do
    {inits, transfers} = 
      data
      |> split_and_map("\n", &parse_line/1)
      |> Enum.partition(&is_init_cmd?/1)

    %{inits: inits, transfers: transfers}
  end

  alias Ten.Robot
  def process(%{inits: inits, transfers: transfers}) do
    Robot.create_directory!
    |> process_inits(inits)
    |> process_transfers(transfers)
    |> keep_ticking
  end

  def keep_ticking(dir) do
    tick_all(dir)
    keep_ticking(dir)
  end

  def tick_all(dir) do
    #IO.read(:line)
    state = Agent.get(dir, fn s -> s end)  
    state
    |> Map.values
    |> Enum.each(&Robot.tick/1) 
  end

  def process_transfers(dir, transfers) do
    transfers
    |> Enum.each(&process_one_transfer(dir, &1))
    dir
  end

  def process_one_transfer(dir, {:transfer, {:from, id}, {:low, low}, {:high, high}}) do
    Robot.set_filter(dir, id, low, high)
  end

  def process_inits(dir, inits) do
    inits
    |> Enum.each(&process_one_init(dir, &1))
    dir
  end

  def process_one_init(dir, {:initialize, bot, chip}) do
    Robot.deliver(dir, bot, chip)
  end

  def is_init_cmd?({:initialize, _, _}), do: true
  def is_init_cmd?(_), do: false

  def parse_line("value" <> rest) do
    r = ~r/\s(\d+)\sgoes\sto\sbot\s(\d+)/
    [_, value, bot] = Regex.run(r, rest)
    {:initialize, to_int(bot), to_int(value)}
  end

  def parse_line("bot" <> rest) do
    [from_id, _, _, _, low_type, low_target, _, _, _, high_type, high_target] =
      rest |> String.lstrip |> String.split("\s")

    {:transfer, 
      {:from, to_int(from_id)}, 
      {:low, {low_type |> to_atom, low_target |> to_int}},
      {:high, {high_type |> to_atom, high_target |> to_int}}
     }
  end

  def parse_line(_), do: "nyi"
end
