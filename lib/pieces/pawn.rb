class Pawn
  attr_accessor :color, :current_square, :possible_moves, :attacking_moves, :pinned, :double_move
  attr_reader :starting_square

  def initialize(color = nil, current_square = nil)
    @color = color
    @current_square = current_square
    @starting_square = current_square
    @possible_moves = []
    @attacking_moves = []
    @pinned = false
    @double_move = false
  end

  def self.starting_range?(row, col)
    starting_rows = [1, 6]
    starting_cols = (0..7)
    return true if starting_rows.include?(row) && starting_cols.include?(col)

    false
  end

  def moved?
    return true if @starting_square != @current_square

    false
  end

  def create_possible_moves
    row = @current_square[0]
    col = @current_square[1]
    create_up_1(row, col)
    create_up_2(row, col)
    create_attacking_moves(row, col)
  end

  def create_up_1(row, col)
    @possible_moves.push([row - 1, col]) if @color == :white && (row - 1).between?(0, 7)
    return unless @color == :black && (row + 1).between?(0, 7)

    @possible_moves.push([row + 1, col])
  end

  def create_up_2(row, col)
    return unless @starting_square == @current_square

    @possible_moves.push([row - 2, col]) if @color == :white && (row - 2).between?(0, 7)
    return unless @color == :black && (row + 2).between?(0, 7)

    @possible_moves.push([row + 2, col])
  end

  def create_attacking_moves(row, col)
    if @color == :white
      if (col - 1).between?(0, 7)
        @possible_moves.push([row - 1, col - 1])
        @attacking_moves.push([row - 1, col - 1])
      end
      if (col + 1).between?(0, 7)
        @possible_moves.push([row - 1, col + 1])
        @attacking_moves.push([row - 1, col + 1])
      end
    else
      if (col - 1).between?(0, 7)
        @possible_moves.push([row + 1, col - 1])
        @attacking_moves.push([row + 1, col - 1])
      end
      if (col + 1).between?(0, 7)
        @possible_moves.push([row + 1, col + 1])
        @attacking_moves.push([row + 1, col + 1])
      end
    end
  end

  def to_s
    if @color == :white
      "\u2659"
    else
      "\u265F"
    end
  end

  def self.starting_range_black?(row, col)
    starting_rows = [1]
    starting_cols = (0..7)
    return true if starting_rows.include?(row) && starting_cols.include?(col)

    false
  end

  def self.starting_range_white?(row, col)
    starting_rows = [6]
    starting_cols = (0..7)
    return true if starting_rows.include?(row) && starting_cols.include?(col)

    false
  end
end
