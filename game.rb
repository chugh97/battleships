require 'date'

class Ship
  attr_accessor :size
  attr_reader :ship_name
  def initialize
    @ship_name = rand(36**8).to_s(36)   
  end
end

class BattleShip < Ship
  def initialize
     super
     @size = 2
  end
end

class Destroyer < Ship
  def initialize
     super
     @size = 4
  end
end

class Cell
  attr_accessor :pos_xy,:display_name,:has_ship,:is_hit,:ship_type,:is_sea
end


class Coordinate
  attr_accessor :letter, :numb
  def co_ordinate
    @letter + @num.to_s
  end
end


class DisplayGameMoves
   COMPUTER = "COMPUTER"
   NO_OF_MESSAGES_TO_DISPLAY = 2

   def self.display_last_two_game_moves(gamemoves)
     unless gamemoves.empty?
        gamemoves.sort!{|m1,m2| m1.time_move_played <=> m2.time_move_played}
        gamemoves.each do |gm| 
           puts "Move for #{gm.player} who played #{gm.move} resulting in #{gm.message}"
        end
     end
   end
end

class GameMove
  attr_accessor :player,:move, :message, :move_status, :time_move_played
end

class MoveStatus
  SUCCESS = 0
  FAILURE = 1
  INVALID = 2
  HAS_ALREADY_BEEN_PLAYED = 3  
end

class Board
  attr_accessor :cells
  def intialize
     cells = []
  end
end

class ShipsForGame
   attr_accessor :ships
  def initialize
     @ships = []
  end 

end

class GameBoard
  BOARD_SIZE = 10
  NO_OF_DESTROYERS = 2
  NO_OF_BATTLE_SHIPS = 1
  COMPUTER = 'COMPUTER'
  attr_reader :board_characters, :board_numbers, :board, :player
  attr_accessor  :temp_cells, :last_move, :ship_sunk_status,:ships_for_game
  
  def initialize(player)
    @player = player
    @board_characters = ("A".."J").to_a
    @board_numbers = (0..9).to_a 
    assign_ships_to_game  
    set_up_ships
    display_board
  end

  def assign_ships_to_game
     ships_for_game = ShipsForGame.new
     bs = Hash.new
     bs[:ship_type] = BattleShip
     bs[:no_of_ships] = NO_OF_BATTLE_SHIPS
     ds = Hash.new
     ds[:ship_type] = Destroyer
     ds[:no_of_ships] = NO_OF_DESTROYERS
     ships_for_game.ships << bs
     #ships_for_game.ships << ds
     @ships_for_game = []
     ships_for_game.ships.each do |s| 
        @ships_for_game << s
     end
  end

  def set_up_ships
    clear_blank_board
    unless @ships_for_game.nil? || @ships_for_game.empty?
      @ships_for_game.each do |ship|
         ship_type = ship[:ship_type]
         no_of_ships = ship[:no_of_ships]
         for counter in 0..((no_of_ships.to_i) -1)
           add_ship_to_board(ship_type)
	   @temp_cells = nil
	 end
      end
    end
  end

  def clear_blank_board
    board = Board.new
    board.cells = []
    board_cells = @board_characters.product(@board_numbers).collect { |x,y| x + (y+1).to_s }
    board_cells.each do |cell|
       cell_object = Cell.new
       cell_object.pos_xy = cell
       cell_object.display_name = cell
       cell_object.has_ship = false
       cell_object.is_hit = false
       cell_object.ship_type = nil
       cell_object.is_sea = false
       h = Hash.new(:key => cell, :value => cell_object)
       board.cells.push(h)
    end
    @board = board
  end

  def add_ship_to_board(type_of_ship)
    result = false
    rnd_cell = nil
    while result == false do
       while rnd_cell.nil? do
        rnd_cell = randomise_start_value(type_of_ship)
        
      end
      ship = create_instance_of_ship_type(type_of_ship)
      rnd_cell[:ship_type] = type_of_ship
      result = try_adding_ship_to_board(rnd_cell, ship)
      if (result == true)
        add_ship_to_cells_on_board(ship)
      else
        rnd_cell = nil
      end
    end
  end
   
  def create_class(klass)
    klass.new
  end

  def create_instance_of_ship_type(type_of_ship)
     create_class type_of_ship
  end

  def try_adding_ship_to_board(cell_start, ship)
    @temp_cells = nil
    temp_cells = [];
    temp_cells << cell_start

    cells_after_direction_1 = nil
    size = ship.size
    for counter in 1..(size-1)
      cells_after_direction_1 = try_direction_1(temp_cells)
    end

    result = check_if_potential_direction_feasible(cells_after_direction_1, size)
 
    if (result == true)
      @temp_cells = cells_after_direction_1
    end

    cell_after_direction_2 = nil
    if (result == false)
      @temp_cells = nil
      @temp_cells = []
      temp_cells = []
      temp_cells << cell_start
      for counter in 1..(size-1)
        cells_after_direction_2 = try_direction_2(temp_cells)
      end
      result = check_if_potential_direction_feasible(cells_after_direction_2, size)
      if (result == true)
        @temp_cells = cells_after_direction_2
      end
    end
    result
  end

  def check_if_potential_direction_feasible(cells, size)
    result = false
    if (cells.nil?)
      result = false
    elsif (cells.size != size)
      result = false
    else 
      result = cells.each do |cell|
         cell[:value].has_ship == false
      end
      result = result.size > 0 ? true: false
    end
    result
  end

  def split_display_name(display_name)
    if display_name =~ /([A-J])([0-9])/
       h = Hash.new
       h[:display_name] = $1
       h[:number] =  $2
    end 
    h
  end

  def try_direction_1(temp_cells) 
    last_cell = temp_cells.last
    disp_name= last_cell[:value].display_name
    last_coordinate = split_display_name(disp_name)
    board_size_minus_one = BOARD_SIZE - 1
    if (last_coordinate[:number].to_i >= board_size_minus_one )
      return temp_cells
    end    
    cell = get_cell_by_key(last_coordinate[:display_name] + (last_coordinate[:number].to_i + 1).to_s)
    
    if !cell.nil?
      temp_cells << cell
    end    
    temp_cells
  end

  def try_direction_2(temp_cells)
    last_cell = temp_cells.last
    last_coordinate = split_display_name(last_cell[:value].display_name)
    if last_coordinate[:number].to_i <= 0
      return temp_cells
    end
    cell = get_cell_by_key(last_coordinate[:display_name] + (last_coordinate[:number].to_i - 1).to_s)
    if !cell.nil?
      temp_cells << cell
    end    
    temp_cells
  end


  def get_cell_by_key(key)
    cells = @board.cells.select do |cell| 
      cell[:key][:key] == key 
    end
    cell = cells[0][:value]
    cell
  end

  def send_text_to_console(content, console_color = "")
    print content
    $stdout.flush
  end

  def is_winner
    count = 0
    @ships_for_game.ships.each do |ship|
      no_of_ships = ship[:value]
      ship_type = ship[:key]
      ship_instance = create_instance_of_ship_from_type(ship_type)
      count+= no_of_ships * ship_instance.size
    end

   result = @board.cells.each do |cell| 
      cell[:value][:value].has_ship && cell[:value][:value].is_hit  
   end
   puts "The result size is" + result.size.to_s
   result.size == count
  end

  def add_ship_to_cells_on_board(ship)
    cells = @temp_cells
    first_cell = cells.first
    cells.each do |cell|
      display_name = cell[:value].display_name
      cell_from_board = @board.cells.select do |c|
         c[:key][:key] == display_name
      end
       
      cell_from_board.each do |c|
         c[:value][:value].has_ship = true
      end
     
      cell_from_board_start_point = cell_from_board[0][:value][:value]
      if (!cell_from_board_start_point.nil? && !first_cell.nil?)
         cell_from_board_start_point.ship_type = first_cell[:ship_type]
         cell_from_board_start_point.has_ship = true
      end

     if @ship_sunk_status.nil?
       @ship_sunk_status = []
     end
     h = Hash.new
     h[:ship_name] = ship.ship_name
     h[:ship] = ship 
     h[:ship_occupying_cells] = @temp_cells
     @ship_sunk_status << h
      @temp_cells = nil
    end
  end

  def get_random_cell
    result = true
    potential_cell = nil
    
    while (result == true) do 
      random_letter = @board_characters[rand(1..10)-1]
      random_number = rand(1..10)
      random_cell = random_letter + random_number.to_s
      potential_cell = @board.cells.select do |cell|
           cell[:key][:key] == random_cell
      end
      
      if (potential_cell && potential_cell.size > 0)
         result = false
         return potential_cell[0][:key]
      end               
    end    
  end

  def randomise_start_value(type_of_ship)
      ship = create_class (type_of_ship)
      rnd_cell = get_random_cell
      full_name = rnd_cell[:value].display_name
      h = split_display_name(full_name)
      no_on_cell = h[:number].to_i
      upper_bounds = no_on_cell + ship.size - 1
      lower_bounds = no_on_cell - ship.size + 1
      if (rnd_cell[:value].has_ship == false && (upper_bounds < BOARD_SIZE || lower_bounds > 0))
         return rnd_cell
      else
         nil
      end  
 end

  def randomise_cell_for_computer_to_play
      
      rnd_cell = get_random_cell   
      if (rnd_cell[:value].is_sea == true || rnd_cell[:value].is_hit)
         return nil
      else
         return rnd_cell
      end      
      
  end

  def computer_play_move
    if @player == COMPUTER
       rnd_cell = nil
       while rnd_cell.nil? do
          rnd_cell = randomise_cell_for_computer_to_play
       end

       gm = play_move(rnd_cell[:key])
       gm.time_move_played = DateTime.now
    end
    gm
  end

  def play_move(input)
   gm = GameMove.new
   gm.player = @player
   gm.move = input
   cell_to_play = @board.cells.select do |cell|
           cell[:key][:key] == input.upcase
   end
   cell_played = cell_to_play[0][:value][:value]
   if cell_played.nil?
     gm.message = "Invalid Move"
     gm.move_status = MoveStatus::INVALID
   else
     if cell_played.is_sea == true || cell_played.is_hit == true
       gm.message = "Move has already been played"
       gm.move_status = MoveStatus::HAS_ALREADY_BEEN_PLAYED
     elsif cell_played.has_ship == true
       cell_played.is_hit = true
       gm.message = "You hit a ship!!!"
       gm.move_status = MoveStatus::SUCCESS

       has_sunk_a_ship = check_player_has_sunk_a_ship(input)
       if (has_sunk_a_ship == true)
         gm.message += ", Also you have sunk it!!!!"
       end
     else
       cell_played.is_sea = true
       gm.message = "You hit a sea! Better luck next time!!!"
       gm.move_status = MoveStatus::FAILURE    
     end 
     gm.time_move_played = DateTime.now
   end
   gm
  end

  def check_player_has_sunk_a_ship(input)
    result = false
    unless @ship_sunk_status.nil? || @ship_sunk_status.empty?
      @ship_sunk_status.each do |val|
        cells = val[:ship_occupying_cells]
        unless cells.nil?
          cells_attacked = cells.select do |cell|
            cell[:value].display_name == input.upcase
          end
          if cells_attacked && cells_attacked.size > 0 
            cells_hit_count = cells.select{|cell| 
               cell[:value].has_ship == true && cell[:value].is_hit }.size
            if cells.size == cells_hit_count
              puts "well done!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
              return result = true
            end
          end
        end        
      end
    end
    result
  end

  def is_game_over
    if is_winner
       return true
    end
    return false
  end

  def is_winner
    count = 0
    @ships_for_game.each do |ship|
      no_of_ships = ship[:no_of_ships]
      ship_type = ship[:ship_type]
      ship_instance = create_class ship_type
      count += no_of_ships * ship_instance.size
    end
 
    how_many_ship_cells_have_been_hit = @board.cells.select do |cell|
      cell[:value][:value].has_ship == true && cell[:value][:value].is_hit == true 
    end
    how_many_ship_cells_have_been_hit.size == count
  end

  def display_board
    if @player.upcase != "COMUPTER"
      puts "|**| - Bombed ship |XX| - Sea, |A1| - Cell ready to strike"
      puts ""
      puts "--------------Game Board #{@player}-------------------------------------"
      cnt = 0
      for i in (0..@board_characters.size - 1)
        for j in (0..@board_numbers.size - 1)
          key = @board_characters[i] + (j + 1).to_s
          cell = get_cell_by_key(key)
          if (cell[:value].has_ship == true)
             cnt+= 1 
	     if (cell[:value].is_hit == true)
               send_text_to_console "|**|"
             else
               if (cell[:value].ship_type == Destroyer)
                 send_text_to_console "|DD|"
               elsif (cell[:value].ship_type == BattleShip)
                 send_text_to_console "|BB|"
               end
      	     end
          else
            if (cell[:value].is_sea == true)
              send_text_to_console "|XX|"
            else
              send_text_to_console "|#{key}|"
            end
          end
        end
        puts ""
      end
      puts ""
    end 
  end
end

module Program
  EXIT = "EXIT"
  puts "Battle Ships game copyright SC"
  attr_accessor :game_moves 
    
  def self.play_battle_ships
    @game_moves = []

    puts "Please enter your name:"
    player = gets.chomp
    if player.nil? || player.empty? || player.upcase == "COMPUTER"
      player = "Player 1"
    end
  
    game_board_player = GameBoard.new(player)

    game_board_computer = GameBoard.new("COMPUTER")
    result = true
    while (result == true)
      puts "#{player} please make your move for e.g. G7"
      input = gets.chomp
      if (input.nil? || input.empty?)
        puts "please enter a valid value e.g. G7"
      end
      if (input == EXIT)
        result = false
      end

      if (!input.nil? && !input.empty? && result == true)
        sleep 1
        system ("clear")
        puts input
        player_move = game_board_player.play_move(input)
        @game_moves << player_move
        computer_move = game_board_computer.computer_play_move
        @game_moves << computer_move

        display_gameboards(game_board_player, game_board_computer)
        is_game_over = false
       
        is_game_over = determine_if_game_is_finished(game_board_player, game_board_computer)

        if (is_game_over == true)
          system ("clear")
          DisplayGameMoves.display_last_two_game_moves(@game_moves)
          display_gameboards(game_board_player, game_board_computer)
          
          puts "Do you wish another challenge of Battleships?"
          input = gets.chomp
          input = play_again_or_exit_game(input)
        end

        result = exit_game_and_display_thank_you_message(input)
      end
    end
  end

  def self.exit_game_and_display_thank_you_message(input)
    result= true
    if (input.upcase == EXIT)
      system("clear")
      puts "Thanks you for player Shaleen Chugh's version of Battle ships"
      result = false
    end
    result
  end

  def self.play_again_or_exit_game(input)
    if (input.upcase != "Y" && input.upcase != "N")
      begin
        puts "Do you wish another challenge? Y/N"
        input = gets.chomp
      end while (input.upcase != "Y" && input.upcase != "N")
    end
    if (input.upcase == "Y")
      play_battle_ships
    elsif (input.upcase == "N")
      input = EXIT
    end
    input
  end

  def self.determine_if_game_is_finished(gb1,gb2)
    is_game_over = false
    if (gb1.is_game_over == true)
      gm1 = GameMove.new
      gm1.player = gb1.player
      gm1.message = "You Win!!!!!!!!!!"
      gm1.time_move_played = DateTime.now
      @game_moves << gm1
      is_game_over = true
   elsif (gb2.is_game_over == true)
      gm2 = GameMove.new
      gm2.player = gb1.player
      gm2.message = "Computer Wins!!!!!!!!!!"
      gm2.time_move_played = DateTime.now
      @game_moves << gm2
      is_game_over = true
   end
   is_game_over
  end

  def self.display_gameboards(gb1,gb2)
    gb1.display_board
    gb2.display_board
  end
end

Program.play_battle_ships
