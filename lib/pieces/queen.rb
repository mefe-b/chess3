class Queen
  attr_accessor :color, :current_square, :possible_moves, :pinned

  def initialize(color = nil, current_square = nil)
    @color = color
    @current_square = current_square
    @possible_moves = []
    @pinned = false
  end

  def to_s
    if @color == :white
      "\u2655"
    else
      "\u265B"
    end
  end

  def create_possible_moves
    board_range = (0..7)
    current_row = @current_square[0]
    current_col = @current_square[1]
    create_possible_horizontal(current_row, current_col, board_range)
    create_possible_vertical(current_row, current_col, board_range)
    create_possible_diagonal(current_row, current_col, board_range)
  end

  def create_possible_horizontal(current_row, current_col, board_range)
    board_range.each do |number|
      @possible_moves.push([number, current_col]) unless current_row == number
    end
  end

  def create_possible_vertical(current_row, current_col, board_range)
    board_range.each do |number|
      @possible_moves.push([current_row, number]) unless current_col == number
    end
  end

  def create_possible_diagonal(current_row, current_col, board_range)
    create_diagonal_down_left(current_row, current_col, board_range)
    create_diagonal_down_right(current_row, current_col, board_range)
    create_diagonal_up_left(current_row, current_col, board_range)
    create_diagonal_up_right(current_row, current_col, board_range)
  end

  def create_diagonal_down_right(current_row, current_col, board_range)
    while board_range.include?(current_row + 1) && board_range.include?(current_col + 1)
      @possible_moves.push([current_row += 1, current_col += 1])
    end
  end

  def create_diagonal_down_left(current_row, current_col, board_range)
    while board_range.include?(current_row + 1) && board_range.include?(current_col - 1)
      @possible_moves.push([current_row += 1, current_col -= 1])
    end
  end

  def create_diagonal_up_right(current_row, current_col, board_range)
    while board_range.include?(current_row - 1) && board_range.include?(current_col + 1)
      @possible_moves.push([current_row -= 1, current_col += 1])
    end
  end

  def create_diagonal_up_left(current_row, current_col, board_range)
    while board_range.include?(current_row - 1) && board_range.include?(current_col - 1)
      @possible_moves.push([current_row -= 1, current_col -= 1])
    end
  end

  def self.starting_range?(row, col)
    starting_rows = [0, 7]
    starting_cols = [3]
    return true if starting_rows.include?(row) && starting_cols.include?(col)

    false
  end

  def self.starting_range_black?(row, col)
    starting_rows = [0]
    starting_cols = [3]
    return true if starting_rows.include?(row) && starting_cols.include?(col)

    false
  end

  def self.starting_range_white?(row, col)
    starting_rows = [7]
    starting_cols = [3]
    return true if starting_rows.include?(row) && starting_cols.include?(col)

    false
  end
end
