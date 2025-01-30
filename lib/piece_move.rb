require_relative 'board'
require 'pry-byebug'

class PieceMove
  attr_reader :board_obj, :board, :checking_pieces, :white_pieces, :black_pieces, :black_king, :white_king

  def initialize
    @board_obj = Board.new
    @board = @board_obj.board
    @board_obj.fill_board
    @king_squares = []
    @white_pieces = []
    @black_pieces = []
    @white_king = nil
    @black_king = nil
    @kings = []
    @checking_pieces = []
  end

  def self.convert_chess_notation(chess_notation)
    max_rank = 8
    a_ascii = 'a'.ord
    file = chess_notation[0]
    rank = chess_notation[1]
    rank = rank.to_i
    rank -= max_rank
    rank = rank.abs
    file = file.ord % a_ascii
    [rank, file]
  end

  def chess_notation_to_square(chess_notation)
    square = PieceMove.convert_chess_notation(chess_notation)
    @board[square[0]][square[1]]
  end

  def remove_impossible_pawn_moves(row, col)
    piece = @board[row][col]
    piece.possible_moves.dup.each do |move|
      square = @board[move[0]][move[1]]
      if (move[0] - row).abs == 1 && move[1] == col && square != (' ')
        piece.possible_moves.delete([move[0], move[1]])
        if piece.color == :white
          piece.possible_moves.delete([move[0] - 1, move[1]])
        else
          piece.possible_moves.delete([move[0] + 1, move[1]])
        end
        next
      end
      if (move[0] - row).abs == 2 && square != (' ')
        piece.possible_moves.delete([move[0], move[1]])
        next
      end
      next unless move[0] != row && move[1] != col

      unless (square != ' ' && square.color != piece.color) || en_pessant?(move, piece.color)
        piece.possible_moves.delete([move[0], move[1]])
      end
    end
  end

  def remove_impossible_bishop_moves(row, col)
    piece = @board[row][col]
    remove_diagonal_up_left(row, col, piece)
    remove_diagonal_up_right(row, col, piece)
    remove_diagonal_down_left(row, col, piece)
    remove_diagonal_down_right(row, col, piece)
  end

  def remove_impossible_rook_moves(row, col)
    piece = @board[row][col]
    remove_straight_up(row, col, piece)
    remove_straight_right(row, col, piece)
    remove_straight_down(row, col, piece)
    remove_straight_left(row, col, piece)
  end

  def remove_impossible_queen_moves(row, col)
    remove_impossible_bishop_moves(row, col)
    remove_impossible_rook_moves(row, col)
  end

  def remove_impossible_knight_moves(row, col)
    piece = board[row][col]
    piece.possible_moves.dup.each do |move|
      piece_on_move = board[move[0]][move[1]]
      piece.possible_moves.delete(move) if piece_on_move != ' ' && piece_on_move.color == piece.color
    end
  end

  def remove_impossible_king_moves
    @kings.each do |king|
      enemy_moves = []
      (0..7).each do |board_row|
        (0..7).each do |board_col|
          piece_on_square = board[board_row][board_col]
          next unless piece_on_square != ' ' && piece_on_square.color != king.color

          piece_on_square.possible_moves.each do |move|
            if piece_on_square.is_a?(Pawn)
              enemy_moves.push(move) if piece_on_square.attacking_moves.include?(move)
            else
              enemy_moves.push(move)
            end
          end
        end
      end
      enemy_moves = enemy_moves.uniq
      king.possible_moves.dup.each do |move|
        # binding.pry
        king.possible_moves.delete(move) if enemy_moves.include?(move)
        if board[move[0]][move[1]] != ' ' && board[move[0]][move[1]].color == king.color
          king.possible_moves.delete(move)
        end
      end
      next if king.possible_moves.empty?

      king.possible_moves.dup.each do |move|
        # binding.pry if @black_king.possible_moves[0] == [1, 5]
        row = king.current_square[0]
        col = king.current_square[1]
        removed_piece = @board[move[0]][move[1]]
        @board[move[0]][move[1]] = king
        king.possible_moves.delete(move) if check?
        @board[row][col] = king
        @board[move[0]][move[1]] = removed_piece
      end
    end
  end

  def remove_impossible_moves
    remove_impossible_non_king_moves
    remove_impossible_king_moves
    flip_double_moves
  end

  def create_moves
    clear_pieces
    (0..7).each do |row|
      (0..7).each do |col|
        piece_on_square = board[row][col]
        next unless piece_on_square != ' ' && !piece_on_square.pinned

        piece_on_square.create_possible_moves
        if piece_on_square.color == :white

          @white_pieces.push(piece_on_square)
        else
          @black_pieces.push(piece_on_square)
        end
      end
    end
  end

  def create_possible_moves
    clear_moves
    create_moves
    remove_impossible_moves
    @kings.each { |king| castle_move(king) }
  end

  def clear_moves
    (0..7).each do |row|
      (0..7).each do |col|
        piece_on_square = board[row][col]
        if piece_on_square != ' ' && !piece_on_square.pinned
          piece_on_square.possible_moves.clear
          piece_on_square.attacking_moves.clear if piece_on_square.is_a?(Pawn)
        end
      end
    end
  end

  def clear_pieces
    @white_pieces.clear
    @black_pieces.clear
  end

  # must create valid moves for other pieces before king
  # other pieces moves dictate where the king can go
  # b/c kings moves that put them in check are invalid
  def remove_impossible_non_king_moves
    (0..7).each do |row|
      (0..7).each do |col|
        piece_on_square = board[row][col]
        if piece_on_square != ' ' && !piece_on_square.is_a?(King) && !piece_on_square.pinned
          remove_impossible_bishop_moves(row, col) if piece_on_square.is_a?(Bishop)
          remove_impossible_knight_moves(row, col) if piece_on_square.is_a?(Knight)
          remove_impossible_pawn_moves(row, col) if piece_on_square.is_a?(Pawn)
          remove_impossible_queen_moves(row, col) if piece_on_square.is_a?(Queen)
          remove_impossible_rook_moves(row, col) if piece_on_square.is_a?(Rook)
        end
        next unless piece_on_square != ' ' && piece_on_square.is_a?(King)

        @kings.clear
        @white_king = piece_on_square if piece_on_square.color == :white
        @black_king = piece_on_square if piece_on_square.color == :black
        @kings = [@white_king, @black_king]
      end
    end
  end

  def remove_diagonal_up_left(row, col, piece)
    while square_in_bounds?(row - 1, col - 1) && @board[row - 1][col - 1] == ' '
      row -= 1
      col -= 1
    end
    blocked = true if square_in_bounds?(row - 1, col - 1) && @board[row - 1][col - 1].color == piece.color
    opposite_piece_found = 0
    while square_in_bounds?(row - 1, col - 1)
      row -= 1
      col -= 1
      opposite_piece_found += 1 if @board[row][col] != ' ' && @board[row][col].color != piece.color
      piece.possible_moves.delete([row, col]) unless opposite_piece_found == 1 && @board[row][col] != ' ' && !blocked
    end
  end

  def remove_diagonal_up_right(row, col, piece)
    # binding.pry if row == 7 && col == 2
    while square_in_bounds?(row - 1, col + 1) && @board[row - 1][col + 1] == ' '
      row -= 1
      col += 1
    end
    blocked = true if square_in_bounds?(row - 1, col + 1) && @board[row - 1][col + 1].color == piece.color

    opposite_piece_found = 0
    while square_in_bounds?(row - 1, col + 1)
      row -= 1
      col += 1
      opposite_piece_found += 1 if @board[row][col] != ' ' && @board[row][col].color != piece.color
      piece.possible_moves.delete([row, col]) unless opposite_piece_found == 1 && @board[row][col] != ' ' && !blocked
    end
  end

  def remove_diagonal_down_left(row, col, piece)
    # binding.pry
    while square_in_bounds?(row + 1, col - 1) && @board[row + 1][col - 1] == ' '
      row += 1
      col -= 1
    end
    blocked = true if square_in_bounds?(row + 1, col - 1) && @board[row + 1][col - 1].color == piece.color
    opposite_piece_found = 0
    while square_in_bounds?(row + 1, col - 1)
      row += 1
      col -= 1
      opposite_piece_found += 1 if @board[row][col] != ' ' && @board[row][col].color != piece.color
      piece.possible_moves.delete([row, col]) unless opposite_piece_found == 1 && @board[row][col] != ' ' && !blocked
    end
  end

  def remove_diagonal_down_right(row, col, piece)
    while square_in_bounds?(row + 1, col + 1) && @board[row + 1][col + 1] == ' '
      row += 1
      col += 1
    end
    blocked = true if square_in_bounds?(row + 1, col + 1) && @board[row + 1][col + 1].color == piece.color
    opposite_piece_found = 0
    while square_in_bounds?(row + 1, col + 1)
      row += 1
      col += 1
      opposite_piece_found += 1 if @board[row][col] != ' ' && @board[row][col].color != piece.color
      piece.possible_moves.delete([row, col]) unless opposite_piece_found == 1 && @board[row][col] != ' ' && !blocked
    end
  end

  def remove_straight_up(row, col, piece)
    row -= 1 while (row - 1).between?(0, 7) && board[row - 1][col] == ' '
    if !(row - 1).between?(0, 7)
      nil
    elsif board[row - 1][col].color == piece.color
      while (row - 1).between?(0, 7)
        piece.possible_moves.delete([row - 1, col])
        row -= 1
      end
    else
      row -= 1
      while (row - 1).between?(0, 7)
        piece.possible_moves.delete([row - 1, col])
        row -= 1
      end
    end
  end

  def remove_straight_right(row, col, piece)
    col += 1 while (col + 1).between?(0, 7) && board[row][col + 1] == ' '
    if !(col + 1).between?(0, 7)
      nil
    elsif board[row][col + 1].color == piece.color
      while (col + 1).between?(0, 7)
        piece.possible_moves.delete([row, col + 1])
        col += 1
      end
    else
      col += 1
      while (col + 1).between?(0, 7)
        piece.possible_moves.delete([row, col + 1])
        col += 1
      end
    end
  end

  def remove_straight_down(row, col, piece)
    row += 1 while (row + 1).between?(0, 7) && board[row + 1][col] == ' '
    if !(row + 1).between?(0, 7)
      nil
    elsif board[row + 1][col].color == piece.color
      while (row + 1).between?(0, 7)
        piece.possible_moves.delete([row + 1, col])
        row += 1
      end
    else
      row += 1
      while (row + 1).between?(0, 7)
        piece.possible_moves.delete([row + 1, col])
        row += 1
      end
    end
  end

  def remove_straight_left(row, col, piece)
    col -= 1 while (col - 1).between?(0, 7) && board[row][col - 1] == ' '
    if !(col - 1).between?(0, 7)
      nil
    elsif board[row][col - 1].color == piece.color
      while (col - 1).between?(0, 7)
        piece.possible_moves.delete([row, col - 1])
        col -= 1
      end
    else
      col -= 1
      while (col - 1).between?(0, 7)
        piece.possible_moves.delete([row, col - 1])
        col -= 1
      end
    end
  end

  def move_piece(old_square, new_square)
    piece = @board[old_square[0]][old_square[1]]
    @board[old_square[0]][old_square[1]] = ' '
    if pawn_played_en_pessant?(piece, new_square)
      row = new_square[0]
      col = new_square[1]
      if piece.color == :white
        row += 1
      else
        row -= 1
      end
      @board[row][col] = ' '
    end
    @board[new_square[0]][new_square[1]] = piece unless castling?(piece, new_square)
    castle(piece, new_square) if castling?(piece, new_square)
    piece.current_square = [new_square[0], new_square[1]]
    en_pessant(piece, old_square, new_square)
    promote(piece)
    create_possible_moves
  end

  def en_pessant(piece, old_square, new_square)
    return unless piece.is_a?(Pawn) && (old_square[0] - new_square[0]).abs == 2

    piece.double_move = true
  end

  def en_pessant?(move, color)
    row = move[0]
    col = move[1]
    if color == :white
      row += 1
    else
      row -= 1
    end
    piece = board[row][col]
    return true if piece.is_a?(Pawn) && piece.color != color && piece.double_move == true

    false
  end

  def promotion?(piece)
    return true if piece.is_a?(Pawn) && (piece.current_square[0].zero? || piece.current_square[0] == 7)

    false
  end

  def promote(piece)
    return unless promotion?(piece)

    new_piece = valid_promotion_input
    row = piece.current_square[0]
    col = piece.current_square[1]
    color = piece.color
    pieces = {
      'N' => Knight.new(color, [row, col]),
      'Q' => Queen.new(color, [row, col]),
      'B' => Bishop.new(color, [row, col]),
      'R' => Rook.new(color, [row, col])
    }
    board[row][col] = pieces[new_piece]
  end

  def promotion_input
    print "Piece format N:Knight, Q:Queen, R:Rook, B:Bishop\nWhich pieces would you like to promote to?: "
    gets.chomp.upcase
  end

  def valid_promotion_input?(input)
    possible_inputs = %w[N Q B R]
    return true if possible_inputs.include?(input)

    false
  end

  def valid_promotion_input
    piece_input = promotion_input
    until valid_promotion_input?(piece_input)
      print "\n"
      p piece_input
      puts 'Invalid: must be in chess notation format N:Knight, Q:Queen, R:Rook, B:Bishop'
      piece_input = promotion_input
    end
    piece_input
  end

  def pawn_played_en_pessant?(piece, move)
    return true if piece.is_a?(Pawn) && move[1] != piece.current_square[1] && board[move[0]][move[1]] == ' '

    false
  end

  def flip_double_moves
    pieces = black_pieces + white_pieces
    pieces.filter! { |piece| piece.is_a?(Pawn) }
    pieces.each { |piece| piece.double_move = false }
  end

  def square_in_bounds?(row, col)
    return true if row.between?(0, 7) && col.between?(0, 7)

    false
  end

  def check?
    attacking_moves = []
    @white_pieces.each do |piece|
      piece.possible_moves.each do |move|
        attacking_moves.push(move)
      end
    end
    @black_pieces.each do |piece|
      piece.possible_moves.each do |move|
        attacking_moves.push(move)
      end
    end
    attacking_moves = attacking_moves.uniq
    @kings.each do |king|
      return true if attacking_moves.any? { |move| king.current_square == (move) }
    end
    false
  end

  def find_checking_pieces(color_in_check)
    checking_pieces.clear
    if color_in_check == :white
      black_pieces.each do |piece|
        checking_pieces.push(piece) if piece.possible_moves.include?(@white_king.current_square)
      end
    else
      white_pieces.each do |piece|
        checking_pieces.push(piece) if piece.possible_moves.include?(@black_king.current_square)
      end
    end
  end

  def possible_block?
    knight_or_pawn = checking_pieces.any? { |piece| piece.is_a?(Pawn) || piece.is_a?(Knight) }
    unless knight_or_pawn
      return true if checking_pieces.length == 1

      return false

    end
    false
  end

  def checking_path
    checking_piece = checking_pieces[0]
    king = if checking_piece.color == :white
             @black_king
           else
             @white_king
           end
    if checking_path_horizontal?(king.current_square,
                                 checking_piece)
      return horizontal_checking_path(king.current_square,
                                      checking_piece)
    end
    if checking_path_diagonal?(king.current_square, checking_piece)
      return diagonal_up_right_checking_path(king.current_square, checking_piece) if checking_path_diagonal_up_right?(
        king.current_square, checking_piece
      )
      return diagonal_up_left_checking_path(king.current_square, checking_piece) if checking_path_diagonal_up_left?(
        king.current_square, checking_piece
      )

      if checking_path_diagonal_down_right?(
        king.current_square, checking_piece
      )
        return diagonal_down_right_checking_path(king.current_square,
                                                 checking_piece)
      end
      return diagonal_down_left_checking_path(king.current_square, checking_piece) if checking_path_diagonal_down_left?(
        king.current_square, checking_piece
      )
    end
    vertical_checking_path(king.current_square, checking_piece) if checking_path_vertical?(king.current_square,
                                                                                           checking_piece)
  end

  def checking_path_horizontal?(king_square, checking_piece)
    return true if king_square[0] == checking_piece.current_square[0]

    false
  end

  def checking_path_vertical?(king_square, checking_piece)
    return true if king_square[1] == checking_piece.current_square[1]

    false
  end

  def horizontal_checking_path(king_square, checking_piece)
    row = king_square[0]
    checking_piece_col = checking_piece.current_square[1]
    checking_path = []
    if king_square[1] < checking_piece_col
      while king_square[1] < (checking_piece_col - 1)
        checking_piece_col -= 1
        checking_path.push([row, checking_piece_col])
      end
    else
      while king_square[1] > checking_piece_col + 1
        checking_piece_col += 1
        checking_path.push([row, checking_piece_col])
      end
    end
    checking_path
  end

  def vertical_checking_path(king_square, checking_piece)
    col = king_square[1]
    checking_piece_row = checking_piece.current_square[0]
    checking_path = []
    if king_square[0] < checking_piece_row
      while king_square[0] < (checking_piece_row - 1)
        checking_piece_row -= 1
        checking_path.push([checking_piece_row, col])
      end
    else
      while king_square[0] > (checking_piece_row + 1)
        checking_piece_row += 1
        checking_path.push([checking_piece_row, col])
      end
    end
    checking_path
  end

  def diagonal_up_right_checking_path(king_square, checking_piece)
    king_row = king_square[0]
    checking_piece_row = checking_piece.current_square[0]
    checking_piece_col = checking_piece.current_square[1]
    checking_path = []
    while king_row > (checking_piece_row + 1)
      checking_piece_row += 1
      checking_piece_col -= 1
      checking_path.push([checking_piece_row, checking_piece_col])
    end
    checking_path
  end

  def diagonal_up_left_checking_path(king_square, checking_piece)
    king_row = king_square[0]
    checking_piece_row = checking_piece.current_square[0]
    checking_piece_col = checking_piece.current_square[1]
    checking_path = []
    while king_row > (checking_piece_row + 1)
      checking_piece_row += 1
      checking_piece_col += 1
      checking_path.push([checking_piece_row, checking_piece_col])
    end
    checking_path
  end

  def diagonal_down_left_checking_path(king_square, checking_piece)
    king_row = king_square[0]
    checking_piece_row = checking_piece.current_square[0]
    checking_piece_col = checking_piece.current_square[1]
    checking_path = []
    while king_row < (checking_piece_row - 1)
      checking_piece_row -= 1
      checking_piece_col += 1
      checking_path.push([checking_piece_row, checking_piece_col])
    end
    checking_path
  end

  def diagonal_down_right_checking_path(king_square, checking_piece)
    king_row = king_square[0]
    checking_piece_row = checking_piece.current_square[0]
    checking_piece_col = checking_piece.current_square[1]
    checking_path = []
    while king_row < (checking_piece_row - 1)
      checking_piece_row -= 1
      checking_piece_col -= 1
      checking_path.push([checking_piece_row, checking_piece_col])
    end
    checking_path
  end

  def checking_path_diagonal?(king_square, checking_piece)
    if king_square[0] != checking_piece.current_square[0] && king_square[1] != checking_piece.current_square[1]
      return true
    end

    false
  end

  def checking_path_diagonal_up_right?(king_square, checking_piece)
    if king_square[0] > checking_piece.current_square[0] && king_square[1] < checking_piece.current_square[1]
      return true
    end

    false
  end

  def checking_path_diagonal_up_left?(king_square, checking_piece)
    if king_square[0] > checking_piece.current_square[0] && king_square[1] > checking_piece.current_square[1]
      return true
    end

    false
  end

  def checking_path_diagonal_down_right?(king_square, checking_piece)
    if king_square[0] < checking_piece.current_square[0] && king_square[1] < checking_piece.current_square[1]
      return true
    end

    false
  end

  def checking_path_diagonal_down_left?(king_square, checking_piece)
    if king_square[0] < checking_piece.current_square[0] && king_square[1] > checking_piece.current_square[1]
      return true
    end

    false
  end

  def capture_checking_piece?
    return false unless checking_pieces.length == 1

    checking_piece = checking_pieces[0]
    if checking_piece.color == :white
      black_pieces.each do |piece|
        return true if piece.possible_moves.include?(checking_piece.current_square)
      end
    else
      white_pieces.each do |piece|
        return true if piece.possible_moves.include?(checking_piece.current_square)
      end
    end
    false
  end

  def remove_illegal_moves_in_check(color_in_check)
    legal_moves = []
    return unless check?

    find_checking_pieces(color_in_check)
    checking_path.each { |move| legal_moves.push(move) } if possible_block?
    legal_moves.push(checking_pieces[0].current_square) if capture_checking_piece?
    if color_in_check == :white
      white_pieces.each do |piece|
        piece.possible_moves.filter! { |move| legal_moves.include?(move) } unless piece.is_a?(King)
      end
    else
      black_pieces.each do |piece|
        piece.possible_moves.filter! { |move| legal_moves.include?(move) } unless piece.is_a?(King)
      end
    end
  end

  def legal_moves?(color_in_check)
    if color_in_check == :white
      @white_pieces.each do |piece|
        return true if piece.possible_moves.length.positive?
      end
    else
      @black_pieces.each do |piece|
        return true if piece.possible_moves.length.positive?
      end
    end
    false
  end

  def pinned?(piece)
    return false if piece.is_a?(King)

    row = piece.current_square[0]
    col = piece.current_square[1]
    board[row][col] = ' '
    create_possible_moves
    check_on_board = check?
    board[row][col] = piece
    create_possible_moves
    return true if check_on_board

    false
  end

  def remove_pinned_moves
    pinned_pieces = white_pieces.filter { |piece| pinned?(piece) } + black_pieces.filter { |piece| pinned?(piece) }
    pinned_pieces.each do |piece|
      piece.pinned = true
      row = piece.current_square[0]
      col = piece.current_square[1]
      board[row][col] = ' '
      create_possible_moves
      if piece.color == :white
        find_checking_pieces(:white)
      else
        find_checking_pieces(:black)
      end
      legal_moves = checking_pieces.map(&:current_square) + checking_path
      piece.possible_moves.filter! { |move| legal_moves.include?(move) }
      board[row][col] = piece
    end
    pinned_pieces.each { |piece| piece.pinned = false }
  end

  def short_castle?(king)
    king_row = king.current_square[0]
    king_col = king.current_square[1]
    rook_row = king.current_square[0]
    rook_col = king.current_square[1] + 3
    short_rook = board[rook_row][rook_col]
    clear_space = empty_space_between?([king_row, king_col], [rook_row, rook_col])
    if !check? && !king.moved? && short_rook.is_a?(Rook) && !short_rook.moved? && clear_space && can_move_right?(king)
      return true
    end

    false
  end

  def long_castle?(king)
    king_row = king.current_square[0]
    king_col = king.current_square[1]
    rook_row = king.current_square[0]
    rook_col = king.current_square[1] - 4
    long_rook = board[rook_row][rook_col]
    clear_space = empty_space_between?([king_row, king_col], [rook_row, rook_col])
    if !check? && !king.moved? && long_rook.is_a?(Rook) && !long_rook.moved? && clear_space && can_move_left?(king)
      return true
    end

    false
  end

  def empty_space_between?(starting_square, ending_square)
    row = starting_square[0]
    starting_col = starting_square[1]
    ending_col = ending_square[1]
    until (starting_col - ending_col).abs == 1
      if starting_col < ending_col
        starting_col += 1
      else
        starting_col -= 1
      end
      return false if board[row][starting_col] != ' '
    end
    true
  end

  def can_move_right1?(king)
    row = king.current_square[0]
    col = king.current_square[1]
    king.possible_moves.include?([row, col + 1])
  end

  def can_move_left1?(king)
    row = king.current_square[0]
    col = king.current_square[1]
    king.possible_moves.include?([row, col - 1])
  end

  def can_move_right2?(king)
    row = king.current_square[0]
    col = king.current_square[1]
    removed_piece = board[row][col + 2]
    board[row][col + 2] = king
    checked = check?
    board[row][col + 2] = removed_piece
    !checked
  end

  def can_move_left2?(king)
    row = king.current_square[0]
    col = king.current_square[1]
    removed_piece = board[row][col + 2]
    board[row][col + 2] = king
    checked = check?
    board[row][col + 2] = removed_piece
    !checked
  end

  def can_move_right?(king)
    can_move_right1?(king) && can_move_right2?(king)
  end

  def can_move_left?(king)
    can_move_left1?(king) && can_move_left2?(king)
  end

  def castle_move(king)
    row = king.current_square[0]
    col = king.current_square[1]
    king.possible_moves.push([row, col + 3]) if short_castle?(king)
    king.possible_moves.push([row, col - 4]) if long_castle?(king)
  end

  def castling?(piece, move)
    row = piece.current_square[0]
    long_col = piece.current_square[1] - 4
    short_col = piece.current_square[1] + 3
    short_move = [row, short_col]
    long_move = [row, long_col]
    return true if piece.is_a?(King) && (move == short_move || move == long_move)

    false
  end

  def castle(king, move)
    king_row = king.current_square[0]
    king_col = king.current_square[1]
    rook_row = move[0]
    rook_col = move[1]
    rook = board[rook_row][rook_col]
    board[king_row][king_col] = ' '
    board[rook_row][rook_col] = ' '
    if king_col < rook_col
      board[king_row][king_col + 2] = king
      board[rook_row][rook_row - 2] = rook
    else
      board[king_row][king_col - 2] = king
      board[rook_row][rook_col + 3] = rook
    end
  end
end
