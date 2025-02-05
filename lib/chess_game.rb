require 'yaml'
require 'fileutils'
require_relative '../lib/piece_move'
class ChessGame
  attr_accessor :board, :move_logic

  def initialize(move_logic = PieceMove.new, color_turn = :white, selected_square = nil, selected_next_square = nil,
                 turns = 0, draw = false, positions = {})
    @move_logic = move_logic
    @color_turn = color_turn
    @board = @move_logic.board_obj.board
    @selected_square = selected_square
    @selected_next_square = selected_next_square
    @turns = turns
    @draw = draw
    @positions = positions
  end

  def to_yaml
    YAML.dump(
      {
        move_logic: @move_logic,
        color_turn: @color_turn,
        selected_square: @selected_square,
        selected_next_square: @selected_next_square,
        turns: @turns,
        draw: @draw,
        positions: @positions
      }
    )
  end

  def self.from_yaml(string)
    data = YAML.load(string,
                     permitted_classes: [Symbol, PieceMove, Board, Rook, King, Bishop, Knight, Queen, Pawn], aliases: true)
    loaded_game = new(data[:move_logic], data[:color_turn], data[:selected_square], data[:selected_next_square],
                      data[:turns], data[:draw], data[:positions])
    puts "#{data[:color_turn]} to play"
    loaded_game.move_logic.board_obj.display_board
    loaded_game.play_game
  end

  def quit?(input)
    input == 'q'
  end

  def quit
    puts 'Exiting game...'
    abort
  end

  def save_game?(input)
    input.strip.downcase == 'save'
  end

  def save_game
    puts 'Enter a name for the save file'
    save_name = gets.chomp.strip

    return if save_name.empty?

    save_dir = File.join(__dir__, 'saves')
    FileUtils.mkdir_p(save_dir)

    file_path = File.join(save_dir, "#{save_name}.yml")

    File.open(file_path, 'w') do |file|
      file.write(to_yaml)
    end
    puts "Game saved to #{file_path}!"

    abort
  rescue StandardError => e
    puts "Save failed: #{e.message}"
  end

  def load_game?(input)
    input == 'load'
  end

  def cancel?(input)
    return false if input != 'cancel'

    @selected_next_square = input
    true
  end

  def load_game
    save_dir = File.join(__dir__, 'saves')
    unless Dir.exist?(save_dir)
      puts "Save directory not found: #{save_dir}"
      return
    end

    i = 1
    save_files = {}
    Dir.foreach('lib/saves') do |filename|
      next if ['.', '..'].include?(filename)

      puts("Save file #{i}: #{filename}")
      save_files[i.to_s] = filename
      i += 1
    end
    puts 'Enter the number of the save'
    save_file_number = gets.chomp
    p save_files[save_file_number]
    save_file_data = File.read("lib/saves/#{save_files[save_file_number]}")
    ChessGame.from_yaml(save_file_data)
  end

  def commands(command)
    command = command.downcase.strip
    return quit if quit?(command)
    return save_game if save_game?(command)

    load_game if load_game?(command)
  end

  def flip_player_turn
    @color_turn = if @color_turn == :white
                    :black
                  else
                    :white
                  end
  end

  def add_position
    if @positions[@board]
      @positions[@board] += 1
    else
      @positions[@board] = 1
    end
  end

  def threefold_repetition?
    @positions.each_value do |value|
      return true if value >= 3
    end
    false
  end

  def threefold_repetition
    @draw = true if threefold_repetition?
  end

  def draw?
    @draw == true
  end

  def king_v_king?
    return true if @move_logic.white_pieces.length == 1 && @move_logic.black_pieces.length == 1

    false
  end

  def king_v_bishop?
    white_pieces = @move_logic.white_pieces
    black_pieces = @move_logic.black_pieces
    white_bishop = white_pieces.any? { |piece| piece.is_a?(Bishop) }
    black_bishop = black_pieces.any? { |piece| piece.is_a?(Bishop) }
    return true if (white_pieces.length == 2 && white_bishop) && black_pieces.length == 1
    return true if (black_pieces.length == 2 && black_bishop) && white_pieces.length == 1

    false
  end

  def king_v_knight
    white_pieces = @move_logic.white_pieces
    black_pieces = @move_logic.black_pieces
    white_bishop = white_pieces.any? { |piece| piece.is_a?(Knight) }
    black_bishop = black_pieces.any? { |piece| piece.is_a?(Knight) }
    return true if (white_pieces.length == 2 && white_bishop) && black_pieces.length == 1
    return true if (black_pieces.length == 2 && black_bishop) && white_pieces.length == 1

    false
  end

  def insufficient_material?
    @draw = true if king_v_king? || king_v_bishop? || king_v_knight
  end

  def draw_offer(offer)
    return unless offer == 'draw'

    puts "#{@color_turn} offered a draw"
    puts 'Enter a:accept or d:decline'
    answer = gets.chomp.downcase
    return unless answer == 'a'

    @draw = true
  end

  def valid_piece_input
    square = piece_input
    return if commands(square)

    until valid_piece?(square)
      puts "#{square} is not valid, please enter a valid move"
      square = piece_input
      commands(square)
    end
    puts "\nSelected Square: #{square}"
    return if draw?

    translated_move = PieceMove.convert_chess_notation(square)
    @selected_square = @board[translated_move[0]][translated_move[1]]
    @move_logic.board_obj.highlight(@selected_square.possible_moves)
    @board[translated_move[0]][translated_move[1]]
  end

  def square_in_range?(square)
    row = square[0]
    col = square[1]
    return true if row.between?(0, 7) && col.between?(0, 7)

    false
  end

  def valid_piece?(square)
    draw_offer(square)
    return true if draw?

    return false if square == 'draw'
    return false unless square.length == 2

    selected_square = PieceMove.convert_chess_notation(square)
    return false unless square_in_range?(selected_square)

    selected_piece = @board[selected_square[0]][selected_square[1]]
    return false if selected_piece == ' ' || selected_piece.color != @color_turn

    return false if selected_piece.possible_moves.empty?

    true
  end

  def piece_input
    print "Select the square of the piece you'd like to move: "
    gets.chomp
  end

  def move_input
    print "Select the square where you'd like to move: "
    gets.chomp
  end

  def valid_move?(selected_piece, move)
    return true if cancel?(move)

    translated_move = PieceMove.convert_chess_notation(move)
    return true if selected_piece.possible_moves.include?([translated_move[0], translated_move[1]])

    false
  end

  def valid_move_input
    move = move_input
    return if commands(move)

    until valid_move?(@selected_square, move)
      puts "#{move} is not a valid move"
      move = move_input
      commands(move)
    end

    return if cancel?(move)

    puts "\nSquare to move: #{move}"
    translated_move = PieceMove.convert_chess_notation(move)
    @selected_next_square = [translated_move[0], translated_move[1]]
  end

  def play_round
    if @turns.zero?
      display_commands
      @move_logic.create_possible_moves
      @move_logic.board_obj.display_board
    end
    valid_piece_input
    return if draw?

    valid_move_input
    return if cancel?(@selected_next_square)

    @move_logic.move_piece([@selected_square.current_square[0], @selected_square.current_square[1]],
                           [@selected_next_square[0], @selected_next_square[1]])
    insufficient_material?
    add_position
    threefold_repetition
    @move_logic.board_obj.display_board
    flip_player_turn
    @turns += 1
  end

  def checkmate?
    if @move_logic.check?
      if @color_turn == :black
        @move_logic.remove_illegal_moves_in_check(:black)
        return true if @move_logic.black_king.possible_moves.empty? && !@move_logic.legal_moves?(:black)
      else
        @move_logic.remove_illegal_moves_in_check(:white)
        return true if @move_logic.white_king.possible_moves.empty? && !@move_logic.legal_moves?(:white)
      end
    end
    false
  end

  def display_commands
    puts 'Commands are open: save: save the game, load: load the game, cancel: draw to choose another draw: draw request'
  end

  def play_game
    play_round until checkmate? || draw?
    puts 'Game over'
    abort
  end
end

