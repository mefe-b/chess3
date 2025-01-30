class Rook
  attr_accessor :color, :current_square, :possible_moves, :pinned

  def initialize(color = nil, current_square = nil)
    @color = color
    @current_square = current_square
    @starting_square = current_square
    @possible_moves = []
    @pinned = false
  end

  def to_s
    if @color == :white
      "\u2656"
    else
      "\u265C"
    end
  end

  def create_possible_moves
    board_range = (0..7)
    current_row = @current_square[0]
    current_col = @current_square[1]
    board_range.each do |number|
      @possible_moves.push([number, current_col]) unless current_row == number
      @possible_moves.push([current_row, number]) unless current_col == number
    end
  end

  def self.starting_range?(row, col)
    starting_rows = [0, 7]
    starting_cols = [0, 7]
    return true if starting_rows.include?(row) && starting_cols.include?(col)

    false
  end

  def self.starting_range_black?(row, col)
    starting_rows = [0]
    starting_cols = [0, 7]
    return true if starting_rows.include?(row) && starting_cols.include?(col)

    false
  end

  def self.starting_range_white?(row, col)
    starting_rows = [7]
    starting_cols = [0, 7]
    return true if starting_rows.include?(row) && starting_cols.include?(col)

    false
  end

  def moved?
    @current_square != @starting_square
  end
end
