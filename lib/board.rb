require 'pry-byebug'
require 'rainbow'
Dir[File.join(__dir__, 'pieces', '*.rb')].sort.each { |file| require file }

# Describes a chess board
class Board
  attr_accessor :board

  WHITE_BACKGROUND = 'ffffff'.freeze
  LIGH_STEEL_BLUE_BACKGROUND = '6e7b8b'.freeze
  LILAC_BACKGROUND = '8470ff'.freeze
  def initialize
    @board = Array.new(8) { Array.new(8) { ' ' } }
  end

  def display_board
    print "\n"
    print '  '
    (97..104).each { |num| print " #{num.chr} " }
    count = 8
    print "\n"
    @board.each_with_index do |row, row_index|
      print "#{count} "
      row.each_with_index do |col, col_index|
        if (row_index + col_index).even?
          display_background(col, WHITE_BACKGROUND)
        else
          display_background(col, GREEN_BACKGROUND)
        end
      end
      print "\n"
      count -= 1
    end
  end

  def highlight(moves)
    print "\n"
    print '  '
    (97..104).each { |num| print " #{num.chr} " }
    count = 8
    print "\n"
    @board.each_with_index do |row, row_index|
      print "#{count} "
      row.each_with_index do |col, col_index|
        # binding.pry
        if moves.include?([row_index, col_index])
          display_background(col, YELLOW_BACKGROUND)
        elsif (row_index + col_index).even?
          display_background(col, WHITE_BACKGROUND)
        else
          display_background(col, GREEN_BACKGROUND)
        end
      end
      print "\n"
      count -= 1
    end
  end

  def display_background(square, background)
    print Rainbow(' ').background(background)
    print Rainbow(square).background(background)
    print Rainbow(' ').background(background)
  end

  def fill_board
    @board.each_index do |row|
      @board.each_index do |col|
        place_starting_rooks(row, col)
        place_starting_knights(row, col)
        place_starting_bishops(row, col)
        place_starting_queens(row, col)
        place_starting_kings(row, col)
        place_starting_pawns(row, col)
      end
    end
  end

  def place_starting_rooks(row, col)
    return unless Rook.starting_range?(row, col)

    @board[row][col] = if Rook.starting_range_black?(row, col)
                         Rook.new(:black, [row, col])
                       else
                         Rook.new(:white, [row, col])
                       end
  end

  def place_starting_knights(row, col)
    return unless Knight.starting_range?(row, col)

    @board[row][col] = if Knight.starting_range_black?(row, col)
                         Knight.new(:black, [row, col])
                       else
                         Knight.new(:white, [row, col])
                       end
  end

  def place_starting_bishops(row, col)
    return unless Bishop.starting_range?(row, col)

    @board[row][col] = if Bishop.starting_range_black?(row, col)
                         Bishop.new(:black, [row, col])
                       else
                         Bishop.new(:white, [row, col])
                       end
  end

  def place_starting_queens(row, col)
    return unless Queen.starting_range?(row, col)

    @board[row][col] = if Queen.starting_range_black?(row, col)
                         Queen.new(:black, [row, col])
                       else
                         Queen.new(:white, [row, col])
                       end
  end

  def place_starting_kings(row, col)
    return unless King.starting_range?(row, col)

    @board[row][col] = if King.starting_range_black?(row, col)
                         King.new(:black, [row, col])
                       else
                         King.new(:white, [row, col])
                       end
  end

  def place_starting_pawns(row, col)
    return unless Pawn.starting_range?(row, col)

    @board[row][col] = if Pawn.starting_range_black?(row, col)
                         Pawn.new(:black, [row, col])
                       else
                         Pawn.new(:white, [row, col])
                       end
  end

  def clear_board
    (0..7).each do |row|
      (0..7).each do |col|
        @board[row][col] = ' '
      end
    end
  end
end
