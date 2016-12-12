defmodule Eleven.Bits do
  use Bitwise
  
  @room_paths %{0 => [1], 1 => [0,2], 2 => [1,3], 3 => [2]}

  defmodule Cache do

    def setup do
      IO.puts("Initializing....")
      {:ok, state_agent} = Agent.start(fn ->%{} end)
      set(state_agent, :rooms, valid_rooms) 
      set(state_agent, :states, valid_states(state_agent))
      IO.puts("Searching...")
      state_agent
    end

    def states(state_agent), do: state_agent |> get(:states) 
    def rooms(state_agent), do: state_agent |> get(:rooms) 

    def with_elevator(states) do
      states
      |> Enum.map(&add_elevator/1)
      |> List.flatten
    end

    def add_elevator(state) do
      0..3
      |> Enum.map(fn floor -> {state, floor} end)
    end
  

    def set(state_agent, key, value) do
      Agent.update(state_agent, fn s -> Map.put(s, key, value) end)
    end

    def get(state_agent, key) do
      Agent.get(state_agent, fn s -> s[key] end)
    end

    def valid_room?(room, cache) do
      get(cache, :rooms) 
      |> Map.get(room)
    end

    def valid_rooms do
      all_rooms
      |> Enum.filter(&Eleven.Bits.compute_if_room_is_valid/1)
      |> Enum.map(fn room -> {room, true} end)
      |> Enum.into(%{})
    end

    def all_rooms, do: 0..1023

    def valid_states(cache) do
      all_possible_states
      |> Enum.filter(&compute_if_state_is_valid(&1, cache))
      |> Enum.map(fn state -> {state, room_ints(state)} end)
      |> Enum.into(%{})
    end

    def room_ints(state) do
      0..3
      |> Enum.map(fn r -> {r, Eleven.Bits.to_room_int(state, r)} end)
      |> Enum.into(%{})
    end

    def all_possible_states do
      0..max_state
    end

    def max_state do
      :math.pow(2,20) |> round  
    end

    def compute_if_state_is_valid(state_int, cache) do
      0..3
      |> Enum.map(fn room -> Eleven.Bits.to_room_int(state_int, room) end)
      |> Enum.all?(&valid_room?(&1, cache))
    end

  end
  @offsets %{tm: 0, tg: 2, sm: 4, sg: 6, rm: 8, rg: 10, 
             cm: 12, cg: 14, pm: 16, pg: 18}
  @items [:pg, :pm, :cg, :cm, :rg, :rm, :sg, :sm, :tg, :tm]



  def to_state_int([a,b,c,d]) 
  when is_list(a) and is_list(b) and is_list(c) and is_list(d) do
    0
    |> to_state_int(b, 1) 
    |> to_state_int(c, 2) 
    |> to_state_int(d, 3) 
  end

  def to_state_int(result, list, floor) do
    list
    |> Enum.map(fn atom -> @offsets[atom] end)
    |> Enum.reduce(result, fn off, r-> (floor <<< off) ||| r end)
  end

  def to_room_int(state_int, room) do
      <<a::unsigned-integer-size(2),
      b::unsigned-integer-size(2),
      c::unsigned-integer-size(2),
      d::unsigned-integer-size(2),
      e::unsigned-integer-size(2),
      f::unsigned-integer-size(2),
      g::unsigned-integer-size(2),
      h::unsigned-integer-size(2),
      i::unsigned-integer-size(2),
      j::unsigned-integer-size(2)>> = <<state_int::unsigned-integer-size(20)>>
      [a,b,c,d,e,f,g,h,i,j]
      |> Enum.map(fn ^room -> 1
                     _ -> 0 end)
      |> Integer.undigits(2)
  end

  def move(state_int, move, room) do
    effect_int = moves[move].effects[room]
    effect_mask = moves[move].mask
    new_state = (state_int &&& effect_mask) ||| effect_int
    new_state
  end

  def possible_moves(state_int, floor, states_map) do
    room_int = states_map[state_int][floor]
    moves
    |> Map.keys
    |> Enum.filter(fn move -> (move &&& room_int) == move end)
  end


  def combos(list1, list2) do
    for a <- list1, b <- list2, do: {a,b} 
  end

  def legal_moves({state_int, from_floor}, states_map) do
    possibles = 
      state_int
      |> possible_moves(from_floor, states_map)
    
    @room_paths[from_floor]
      |> combos(possibles)      
      |> Enum.map(fn {to_floor, m} -> {{to_floor, m}, move(state_int, m, to_floor)} end)
      |> Enum.filter(fn {_m, state} -> states_map[state] end)
      |> Enum.map(fn {m, _s} -> m end)
  end

  # The code that generated this madness is commented out below
  def moves do  
      %{48 => %{effects: %{0 => 0, 1 => 1280, 2 => 2560, 3 => 3840}, mask: 1044735},
        34 => %{effects: %{0 => 0, 1 => 1028, 2 => 2056, 3 => 3084}, mask: 1045491},
        130 => %{effects: %{0 => 0, 1 => 16388, 2 => 32776, 3 => 49164},
          mask: 999411},
        68 => %{effects: %{0 => 0, 1 => 4112, 2 => 8224, 3 => 12336}, mask: 1036239},
        136 => %{effects: %{0 => 0, 1 => 16448, 2 => 32896, 3 => 49344},
          mask: 999231},
        64 => %{effects: %{0 => 0, 1 => 4096, 2 => 8192, 3 => 12288}, mask: 1036287},
        20 => %{effects: %{0 => 0, 1 => 272, 2 => 544, 3 => 816}, mask: 1047759},
        17 => %{effects: %{0 => 0, 1 => 257, 2 => 514, 3 => 771}, mask: 1047804},
        65 => %{effects: %{0 => 0, 1 => 4097, 2 => 8194, 3 => 12291}, mask: 1036284},
        8 => %{effects: %{0 => 0, 1 => 64, 2 => 128, 3 => 192}, mask: 1048383},
        192 => %{effects: %{0 => 0, 1 => 20480, 2 => 40960, 3 => 61440},
          mask: 987135},
        1 => %{effects: %{0 => 0, 1 => 1, 2 => 2, 3 => 3}, mask: 1048572},
        32 => %{effects: %{0 => 0, 1 => 1024, 2 => 2048, 3 => 3072}, mask: 1045503},
        520 => %{effects: %{0 => 0, 1 => 262208, 2 => 524416, 3 => 786624},
          mask: 261951},
        3 => %{effects: %{0 => 0, 1 => 5, 2 => 10, 3 => 15}, mask: 1048560},
        640 => %{effects: %{0 => 0, 1 => 278528, 2 => 557056, 3 => 835584},
          mask: 212991},
        2 => %{effects: %{0 => 0, 1 => 4, 2 => 8, 3 => 12}, mask: 1048563},
        512 => %{effects: %{0 => 0, 1 => 262144, 2 => 524288, 3 => 786432},
          mask: 262143},
        272 => %{effects: %{0 => 0, 1 => 65792, 2 => 131584, 3 => 197376},
          mask: 851199},
        10 => %{effects: %{0 => 0, 1 => 68, 2 => 136, 3 => 204}, mask: 1048371},
        544 => %{effects: %{0 => 0, 1 => 263168, 2 => 526336, 3 => 789504},
          mask: 259071},
        128 => %{effects: %{0 => 0, 1 => 16384, 2 => 32768, 3 => 49152},
          mask: 999423},
        320 => %{effects: %{0 => 0, 1 => 69632, 2 => 139264, 3 => 208896},
          mask: 839679},
        768 => %{effects: %{0 => 0, 1 => 327680, 2 => 655360, 3 => 983040},
          mask: 65535},
        5 => %{effects: %{0 => 0, 1 => 17, 2 => 34, 3 => 51}, mask: 1048524},
        256 => %{effects: %{0 => 0, 1 => 65536, 2 => 131072, 3 => 196608},
          mask: 851967},
        40 => %{effects: %{0 => 0, 1 => 1088, 2 => 2176, 3 => 3264}, mask: 1045311},
        80 => %{effects: %{0 => 0, 1 => 4352, 2 => 8704, 3 => 13056}, mask: 1035519},
        260 => %{effects: %{0 => 0, 1 => 65552, 2 => 131104, 3 => 196656},
          mask: 851919},
        160 => %{effects: %{0 => 0, 1 => 17408, 2 => 34816, 3 => 52224},
          mask: 996351},
        16 => %{effects: %{0 => 0, 1 => 256, 2 => 512, 3 => 768}, mask: 1047807},
        257 => %{effects: %{0 => 0, 1 => 65537, 2 => 131074, 3 => 196611},
          mask: 851964},
        4 => %{effects: %{0 => 0, 1 => 16, 2 => 32, 3 => 48}, mask: 1048527},
        12 => %{effects: %{0 => 0, 1 => 80, 2 => 160, 3 => 240}, mask: 1048335},
        514 => %{effects: %{0 => 0, 1 => 262148, 2 => 524296, 3 => 786444},
          mask: 262131}}
  end

  #def move_effect_mask(move) do
        #[a,b,c,d,e,f,g,h,i,j] = 
      #move
      #|> move_desc
      #|> Enum.map(fn 1 -> 0
                     #0 -> 3 end)

      #<<move_effect_int::unsigned-integer-size(20)>> =
        #<<a::unsigned-integer-size(2),
        #b::unsigned-integer-size(2),
        #c::unsigned-integer-size(2),
        #d::unsigned-integer-size(2),
        #e::unsigned-integer-size(2),
        #f::unsigned-integer-size(2),
        #g::unsigned-integer-size(2),
        #h::unsigned-integer-size(2),
        #i::unsigned-integer-size(2),
        #j::unsigned-integer-size(2)>> 
      #move_effect_int 
  #end


  #def move_effect_int(move, room) do
        #[a,b,c,d,e,f,g,h,i,j] = 
      #move
      #|> move_desc
      #|> Enum.map(fn 1 -> room
                     #0 -> 0 end)

      #<<move_effect_int::unsigned-integer-size(20)>> =
        #<<a::unsigned-integer-size(2),
        #b::unsigned-integer-size(2),
        #c::unsigned-integer-size(2),
        #d::unsigned-integer-size(2),
        #e::unsigned-integer-size(2),
        #f::unsigned-integer-size(2),
        #g::unsigned-integer-size(2),
        #h::unsigned-integer-size(2),
        #i::unsigned-integer-size(2),
        #j::unsigned-integer-size(2)>> 
      #move_effect_int 
  #end

  #def move_desc(move), do: move |> Integer.digits(2) |> pad_to(10)
  
  #def moves_with_effects_and_masks do
    #moves
    #|> Enum.map(fn m -> {m, %{effects: effect_ints_for(m), mask: move_effect_mask(m)}} end)
    #|> Enum.into(%{})
  #end

  #def effect_ints_for(m) do
    #0..3
    #|> Enum.map(fn r -> {r, move_effect_int(m,r)} end)
    #|> Enum.into(%{})
  #end

  #def moves do
    #two_gens = 
      #doubles
      #|> Enum.map(&as_gen/1)
    #two_chips = 
      #doubles
      #|> Enum.map(&as_chip/1)
    #one_gens =
      #singles
      #|> Enum.map(&as_gen/1)
    #one_chips =
      #singles
      #|> Enum.map(&as_chip/1)
    #(two_gens ++ two_chips ++ one_gens ++ one_chips ++ pairs)
    #|> Enum.map(&bits_to_room/1)
  #end

  #def as_gen(l), do: {l, [0,0,0,0,0]}
  #def as_chip(l), do: {[0,0,0,0,0], l}

  #def singles do
    #[1,2,4,8,16] 
    #|> Enum.map(&Integer.digits(&1,2))
    #|> Enum.map(&pad_to(&1,5))
  #end

  #def pairs do
    #[1, 2, 4, 8, 16]
    #|> Enum.map(&Integer.digits(&1,2))
    #|> Enum.map(&pad_to(&1,5))
    #|> Enum.map(fn side -> {side, side} end)
  #end

  #def doubles do
    #0..31
    #|> Enum.filter(fn n -> count_bits(n) == 2 end)
    #|> Enum.map(&Integer.digits(&1,2))
    #|> Enum.map(&pad_to(&1,5))
  #end
  
  def room_to_bits(room_desc) do
    room_desc
    |> Integer.digits(2)
    |> pad_to(10)
    |> Enum.chunk(2)
    |> Enum.reduce({[],[]}, fn [g,c], {gens, chips} -> {[g | gens], [c | chips]} end)
  end


  def bits_to_room(bits), do: bits |> bits_to_room([]) |> Integer.undigits(2)
  def bits_to_room({[],[]}, result), do: result
  def bits_to_room({[h | t], [h1 | t1]}, result), do: bits_to_room({t, t1}, [h, h1 | result])

  def count_bits(n), do: n |> Integer.digits(2) |> Enum.count(fn d -> d == 1 end)

  def compute_if_room_is_valid(room_desc) do
    room_desc
    |> room_to_bits
    |> _compute_if_room_is_valid
  end

  def _compute_if_room_is_valid({[], _}), do: true
  def _compute_if_room_is_valid({_, []}), do: true
  def _compute_if_room_is_valid({[0,0,0,0,0], _}), do: true
  def _compute_if_room_is_valid({_, [0,0,0,0,0]}), do: true
  def _compute_if_room_is_valid({[1 | gen_t], [1 | chip_t]}),
    do: _compute_if_room_is_valid({gen_t, chip_t})
  def _compute_if_room_is_valid({[0 | gen_t], [1 | chip_t]}),
    do: false
  def _compute_if_room_is_valid({[1 | gen_t], [0 | chip_t]}),
    do: _compute_if_room_is_valid({gen_t, chip_t})
  def _compute_if_room_is_valid({[0 | gen_t], [0 | chip_t]}),
    do: _compute_if_room_is_valid({gen_t, chip_t})
  

  def pad_to(list, n) do
    pad_needed = n - Enum.count(list)
    duplicate(pad_needed, 0) ++ list
  end

  def duplicate(0, _), do: []
  def duplicate(n, val), do: [val | duplicate(n-1, val)]
end
