class King
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
      "\u2654"
    else
      "\u265A"
    end
  end

  def create_possible_moves
    current_row = @current_square[0]
    current_col = @current_square[1]
    create_up_moves(current_row, current_col)
    create_down_moves(current_row, current_col)
    create_right_moves(current_row, current_col)
    create_left_moves(current_row, current_col)
  end

  def create_up_moves(current_row, current_col)
    return unless current_row.positive?

    @possible_moves.push([current_row - 1, current_col])
    @possible_moves.push([current_row - 1, current_col + 1]) if current_col < 7
    @possible_moves.push([current_row - 1, current_col - 1]) if current_col.positive?
  end

  def create_down_moves(current_row, current_col)
    return unless current_row < 7

    @possible_moves.push([current_row + 1, current_col])
    @possible_moves.push([current_row + 1, current_col + 1]) if current_col < 7
    @possible_moves.push([current_row + 1, current_col - 1]) if current_col.positive?
  end

  def create_left_moves(current_row, current_col)
    return unless current_col.positive?

    @possible_moves.push([current_row, current_col - 1])
  end

  def create_right_moves(current_row, current_col)
    return unless current_col < 7

    @possible_moves.push([current_row, current_col + 1])
  end

  def self.starting_range?(row, col)
    starting_rows = [0, 7]
    starting_cols = [4]
    return true if starting_rows.include?(row) && starting_cols.include?(col)

    false
  end

  def self.starting_range_black?(row, col)
    starting_rows = [0]
    starting_cols = [4]
    return true if starting_rows.include?(row) && starting_cols.include?(col)

    false
  end

  def self.starting_range_white?(row, col)
    starting_rows = [7]
    starting_cols = [4]
    return true if starting_rows.include?(row) && starting_cols.include?(col)

    false
  end

  def moved?
    @current_square != @starting_square
  end
end
