require_relative "../lib/piece_move"
require "pry-byebug"

describe PieceMove do
  let(:piece_move) { described_class.new }
  describe "#convert_chess_notation" do
    it "takes a chess notation and converts it to an corresponding array" do
      a2 = PieceMove.convert_chess_notation("a2")
      d4 = PieceMove.convert_chess_notation("d4")
      f6 = PieceMove.convert_chess_notation("f6")
      expect(a2).to eq([6, 0])
      expect(d4).to eq([4, 3])
      expect(f6).to eq([2, 5])
    end
  end
  describe "#remove_impossible_pawn_moves" do
    context "at the start of the game" do
      it "removes impossible moves for pawns for white" do
        board = piece_move.board_obj.board
        e2 = board[6][4]
        e2.create_possible_moves
        piece_move.remove_impossible_pawn_moves(6, 4)
        expect(e2.possible_moves).to contain_exactly([5, 4], [4, 4])
      end
      it "removes impossible moves for pawns for black" do
        board = piece_move.board_obj.board
        e7 = board[1][4]
        e7.create_possible_moves
        piece_move.remove_impossible_pawn_moves(1, 4)
        expect(e7.possible_moves).to contain_exactly([2, 4], [3, 4])
      end
    end
    context "when a capture is possible" do
      it "removes impossible moves for white pawns" do
        board = piece_move.board_obj.board
        d3_black_pawn = Pawn.new(:black, [5, 3])
        e2 = board[6][4]
        board[5][3] = d3_black_pawn
        e2.create_possible_moves
        piece_move.remove_impossible_pawn_moves(6, 4)
        expect(e2.possible_moves).to contain_exactly([5, 4], [4, 4], [5, 3])
      end
      it "removes impossible moves for black pawns" do
        board = piece_move.board_obj.board
        d5_white_pawn = Pawn.new(:white, [2, 3])
        e7 = board[1][4]
        board[2][3] = d5_white_pawn
        e7.create_possible_moves
        piece_move.remove_impossible_pawn_moves(1, 4)
        expect(e7.possible_moves).to contain_exactly([2, 4], [3, 4], [2, 3])
      end
    end
    context "when a piece is blocking its path one square up" do
      it "removes impossible moves for white pawns" do
        board = piece_move.board_obj.board
        board[5][4] = Pawn.new
        e2 = board[6][4]
        e2.create_possible_moves
        piece_move.remove_impossible_pawn_moves(6, 4)
        expect(e2.possible_moves).to be_empty
      end
      it "removes impossible moves for black pawns" do
        board = piece_move.board_obj.board
        board[2][4] = Pawn.new
        e7 = board[1][4]
        e7.create_possible_moves
        piece_move.remove_impossible_pawn_moves(1, 4)
        expect(e7.possible_moves).to be_empty
      end
    end
    context "when a piece is blocking its path two squares up" do
      it "removes impossible moves for white pawns" do
        board = piece_move.board_obj.board
        board[4][4] = Pawn.new
        e2 = board[6][4]
        e2.create_possible_moves
        piece_move.remove_impossible_pawn_moves(6, 4)
        expect(e2.possible_moves).to contain_exactly([5, 4])
      end
      it "removes impossible moves for black pawns" do
        board = piece_move.board_obj.board
        board[3][4] = Pawn.new
        e7 = board[1][4]
        e7.create_possible_moves
        piece_move.remove_impossible_pawn_moves(1, 4)
        expect(e7.possible_moves).to contain_exactly([2, 4])
      end
    end
    context "when en pessant from black is possible" do
      it "has the move to capture en pessant" do
        board = piece_move.board_obj.board
        d4 = Pawn.new(:black, [4, 3])
        board[4][3] = d4
        piece_move.move_piece([6, 4], [4, 4])
        piece_move.board_obj.display_board
        expect(d4.possible_moves).to include([5, 4])
      end
    end
    context "when en pessant from white is possible" do
      it "has the move to capture en pessant" do
        board = piece_move.board_obj.board
        piece_move.move_piece([6, 4], [3, 4])
        e5 = board[3][4]
        piece_move.move_piece([1, 3], [3, 3])
        piece_move.board_obj.display_board
        expect(e5.possible_moves).to include([2, 3])
      end
    end
    context "when en pessant from white is was possible 1 turn ago" do
      it "dos not have the move to capture en pessant" do
        board = piece_move.board_obj.board
        piece_move.move_piece([6, 4], [3, 4])
        e5 = board[3][4]
        piece_move.move_piece([1, 3], [3, 3])
        piece_move.move_piece([6, 0], [5, 0])
        piece_move.board_obj.display_board
        expect(e5.possible_moves).not_to include([2, 3])
      end
    end
  end

  describe "#remove_impossible_bishop_moves" do
    let(:board) { piece_move.board }
    context "at the start of the game" do
      it "removes impossible moves for white light squared bishop" do
        white_light_squared_bishop = Bishop.new(:white, [7, 5])
        board[7][5] = white_light_squared_bishop
        white_light_squared_bishop.create_possible_moves
        piece_move.remove_impossible_bishop_moves(7, 5)
        expect(white_light_squared_bishop.possible_moves).to be_empty
      end
      it "removes impossible moves for white dark squared bishop" do
        white_dark_squared_bishop = Bishop.new(:white, [7, 2])
        board[7][2] = white_dark_squared_bishop
        white_dark_squared_bishop.create_possible_moves
        piece_move.remove_impossible_bishop_moves(7, 2)
        expect(white_dark_squared_bishop.possible_moves).to be_empty
      end
      it "removes impossible moves for black light squared bishop" do
        black_light_squared_bishop = Bishop.new(:black, [0, 5])
        board[0][5] = black_light_squared_bishop
        black_light_squared_bishop.create_possible_moves
        piece_move.remove_impossible_bishop_moves(0, 5)
        expect(black_light_squared_bishop.possible_moves).to be_empty
      end
      it "removes impossible moves for black dark squared bishop" do
        black_dark_squared_bishop = Bishop.new(:black, [0, 2])
        board[0][2] = black_dark_squared_bishop
        black_dark_squared_bishop.create_possible_moves
        piece_move.remove_impossible_bishop_moves(0, 2)
        expect(black_dark_squared_bishop.possible_moves).to be_empty
      end
    end
    context "when the white bishop is at the center" do
      it "removes the impossible moves for bishop" do
        bishop = Bishop.new(:white, [4, 3])
        board[4][3] = bishop
        bishop.create_possible_moves
        piece_move.remove_impossible_bishop_moves(4, 3)
        expect(bishop.possible_moves).to contain_exactly([5, 4], [5, 2], [3, 4], [3, 2], [2, 1], [2, 5], [1, 6], [1, 0])
      end
    end
    context "when black bishop is at the center" do
      it "removes the impossible moves for bishop" do
        bishop = Bishop.new(:black, [2, 4])
        board[2][4] = bishop
        bishop.create_possible_moves
        piece_move.remove_impossible_bishop_moves(2, 4)
        expect(bishop.possible_moves).to contain_exactly([3, 3], [4, 2], [5, 1], [6, 0], [3, 5], [4, 6], [5, 7])
      end
    end
    context "when the white bishop can attack a piece" do
      it "removes impossible moves and keeps move to attack" do
        bishop = Bishop.new(:white, [5, 3])
        black_pawn = Pawn.new(:black, [3, 5])
        board[5][3] = bishop
        board[3][5] = black_pawn
        bishop.create_possible_moves
        piece_move.remove_impossible_bishop_moves(5, 3)
        expect(bishop.possible_moves).to contain_exactly([4, 2], [4, 4], [3, 1], [3, 5], [2, 0])
      end
    end
    context "when the black bishop can attack a piece" do
      it "removes impossible moves and keeps move to attack" do
        bishop = Bishop.new(:black, [2, 1])
        white_pawn = Pawn.new(:white, [4, 3])
        board[2][1] = bishop
        board[4][3] = white_pawn
        bishop.create_possible_moves
        piece_move.remove_impossible_bishop_moves(2, 1)
        expect(bishop.possible_moves).to contain_exactly([3, 0], [3, 2], [4, 3])
      end
    end
    context "white bishop is blocked by its friendly pieces" do
      it "removes all moves" do
        bishop = Bishop.new(:white, [4, 4])
        white_pawn_d3 = Pawn.new(:white, [5, 3])
        white_pawn_f3 = Pawn.new(:white, [5, 5])
        white_pawn_d5 = Pawn.new(:white, [3, 3])
        white_pawn_f5 = Pawn.new(:white, [3, 5])
        board[5][3] = white_pawn_d3
        board[3][5] = white_pawn_f5
        board[3][3] = white_pawn_d5
        board[5][5] = white_pawn_f3
        board[4][4] = bishop
        bishop.create_possible_moves
        piece_move.remove_impossible_bishop_moves(4, 4)
        expect(bishop.possible_moves).to be_empty
      end
    end
    context "black bishop is blocked by its friendly pieces" do
      it "removes all moves" do
        bishop = Bishop.new(:black, [3, 4])
        white_pawn_d6 = Pawn.new(:black, [2, 3])
        white_pawn_f6 = Pawn.new(:black, [2, 5])
        white_pawn_d5 = Pawn.new(:black, [4, 3])
        white_pawn_f5 = Pawn.new(:black, [4, 5])
        board[2][3] = white_pawn_d6
        board[4][5] = white_pawn_f5
        board[4][3] = white_pawn_d5
        board[2][5] = white_pawn_f6
        board[3][4] = bishop
        bishop.create_possible_moves
        piece_move.remove_impossible_bishop_moves(3, 4)
        expect(bishop.possible_moves).to be_empty
      end
    end
  end

  describe "#remove_impossible_rook_moves" do
    let(:board) { piece_move.board }
    context "start of game for a1" do
      it "removes impossible moves for rooks" do
        rook_a1 = board[7][0]
        rook_a1.create_possible_moves
        piece_move.remove_impossible_rook_moves(7, 0)
        expect(rook_a1.possible_moves).to be_empty
      end
    end
    context "start of game for h1" do
      it "removes impossible moves for rooks" do
        rook_h1 = board[7][7]
        rook_h1.create_possible_moves
        piece_move.remove_impossible_rook_moves(7, 7)
        expect(rook_h1.possible_moves).to be_empty
      end
    end
    context "start of game for a8" do
      it "removes impossible moves for rooks" do
        rook_a8 = board[0][0]
        rook_a8.create_possible_moves
        piece_move.remove_impossible_rook_moves(0, 0)
        expect(rook_a8.possible_moves).to be_empty
      end
    end
    context "start of game for h8" do
      it "removes impossible moves for rooks" do
        rook_h8 = board[0][7]
        rook_h8.create_possible_moves
        piece_move.remove_impossible_rook_moves(0, 7)
        expect(rook_h8.possible_moves).to be_empty
      end
    end
    context "rook in the middle of the board on d4" do
      it "removes impossible moves and keep moves attacking" do
        rook_d4 = Rook.new(:white, [4, 3])
        board[4][3] = rook_d4
        rook_d4.create_possible_moves
        piece_move.remove_impossible_rook_moves(4, 3)
        expect(rook_d4.possible_moves).to contain_exactly([5, 3], [3, 3], [2, 3], [1, 3],
                                                          [4, 2], [4, 1], [4, 0], [4, 4], [4, 5], [4, 6], [4, 7])
      end
    end
    context "rook is blocked by friendly and enemy piece" do
      it "removes impossible moves" do
        rook_f5 = Rook.new(:black, [3, 5])
        white_pawn_e5 = Pawn.new(:white, [3, 4])
        black_pawn_g5 = Pawn.new(:black, [3, 6])
        board[3][5] = rook_f5
        board[3][4] = white_pawn_e5
        board[3][6] = black_pawn_g5
        rook_f5.create_possible_moves
        piece_move.remove_impossible_rook_moves(3, 5)
        expect(rook_f5.possible_moves).to contain_exactly([3, 4], [2, 5], [4, 5], [5, 5], [6, 5])
      end
    end
  end

  describe "#remove_impossible_queen_moves" do
    let(:board) { piece_move.board }
    context "At the start of the game" do
      it "removes white queen's impossible moves" do
        white_queen = board[7][3]
        white_queen.create_possible_moves
        piece_move.remove_impossible_queen_moves(7, 3)
        expect(white_queen.possible_moves).to be_empty
      end
    end
    context "At the start of the game" do
      it "removes black queen's impossible moves" do
        black_queen = board[0][3]
        black_queen.create_possible_moves
        piece_move.remove_impossible_queen_moves(0, 3)
        expect(black_queen.possible_moves).to be_empty
      end
    end
    context "white queen in middle of board e4" do
      it "removes white queen's possible moves" do
        white_queen_e4 = Queen.new(:white, [4, 4])
        board[4][4] = white_queen_e4
        white_queen_e4.create_possible_moves
        piece_move.remove_impossible_queen_moves(4, 4)
        expect(white_queen_e4.possible_moves).to contain_exactly([4, 3], [4, 2], [4, 1], [4, 0],
                                                                 [4, 5], [4, 6], [4, 7],
                                                                 [5, 4], [3, 4], [2, 4], [1, 4],
                                                                 [3, 3], [2, 2], [1, 1],
                                                                 [3, 5], [2, 6], [1, 7],
                                                                 [5, 3], [5, 5])
      end
    end
  end

  describe "#remove_impossible_knight_moves" do
    let(:board) { piece_move.board }
    context "when b1 knight is a start" do
      it "removes impossible moves" do
        knight_b1 = board[7][1]
        knight_b1.create_possible_moves
        piece_move.remove_impossible_knight_moves(7, 1)
        expect(knight_b1.possible_moves).to contain_exactly([5, 0], [5, 2])
      end
    end
    context "when g1 knight is a start" do
      it "removes impossible moves" do
        knight_g1 = board[7][6]
        knight_g1.create_possible_moves
        piece_move.remove_impossible_knight_moves(7, 6)
        expect(knight_g1.possible_moves).to contain_exactly([5, 5], [5, 7])
      end
    end
    context "when b8 knight is a start" do
      it "removes impossible moves" do
        knight_b8 = board[0][1]
        knight_b8.create_possible_moves
        piece_move.remove_impossible_knight_moves(0, 1)
        expect(knight_b8.possible_moves).to contain_exactly([2, 0], [2, 2])
      end
    end
    context "when g8 knight is a start" do
      it "removes impossible moves" do
        knight_g8 = board[0][6]
        knight_g8.create_possible_moves
        piece_move.remove_impossible_knight_moves(0, 6)
        expect(knight_g8.possible_moves).to contain_exactly([2, 5], [2, 7])
      end
    end
    context "knight is center of board" do
      it "removes impossible moves" do
        knight_d4 = Knight.new(:white, [4, 3])
        knight_d4.create_possible_moves
        board[4][3] = knight_d4
        piece_move.remove_impossible_knight_moves(4, 3)
        expect(knight_d4.possible_moves).to contain_exactly([2, 2], [2, 4], [3, 1], [3, 5], [5, 1], [5, 5])
      end
    end
    context "knight can attack" do
      it "removes impossible moves and keeps attacking moves" do
        knight_g3 = Knight.new(:black, [5, 6])
        knight_g3.create_possible_moves
        board[5][6] = knight_g3
        piece_move.remove_impossible_knight_moves(5, 6)
        expect(knight_g3.possible_moves).to contain_exactly([7, 5], [7, 7], [6, 4], [4, 4], [3, 5], [3, 7])
      end
    end
  end

  describe "#remove_impossible_king_moves" do
    let(:board) { piece_move.board }
    context "at the start of the game for white" do
      it "removes impossible moves" do
        white_king = board[7][4]
        white_king.create_possible_moves
        piece_move.remove_impossible_non_king_moves
        piece_move.remove_impossible_king_moves
        expect(white_king.possible_moves).to be_empty
      end
    end
    context "at the start of the game for white" do
      it "removes impossible moves" do
        black_king = board[0][4]
        black_king.create_possible_moves
        piece_move.remove_impossible_non_king_moves
        piece_move.remove_impossible_king_moves
        expect(black_king.possible_moves).to be_empty
      end
    end
    context "when a king has move that put him in check" do
      it "removes impossible moves" do
        white_king = board[7][4]
        black_rook_c6 = Rook.new(:black, [3, 2])
        board[3][2] = black_rook_c6
        piece_move.move_piece([7, 4], [4, 3])
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        expect(white_king.possible_moves).to contain_exactly([3, 2], [5, 3], [5, 4], [4, 4])
      end
    end
  end

  describe "#check?" do
    let(:board) { piece_move.board }
    context "when white king is in check by a pawn" do
      it "returns true" do
        black_pawn = Pawn.new(:black, [3, 4])
        piece_move.move_piece([7, 4], [4, 3])
        board[3][4] = black_pawn
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        expect(piece_move.check?).to be true
      end
    end
    context "when black king is in check by a pawn" do
      it "returns true" do
        black_king = King.new(:black, [3, 4])
        white_pawn = Pawn.new(:white, [4, 3])
        board[3][4] = black_king
        board[4][3] = white_pawn
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        expect(piece_move.check?).to be true
      end
    end
    context "when white king is not in check" do
      it "returns false" do
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        expect(piece_move.check?).to be false
      end
    end
    context "when white king is in check by black queen" do
      it "returns true" do
        piece_move.move_piece([7, 4], [4, 3])
        black_queen = Queen.new(:black, [2, 1])
        board[2][1] = black_queen
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        expect(piece_move.check?).to be true
      end
    end
  end

  describe "#checking_pieces" do
    let(:board) { piece_move.board }
    context "when 2 pieces are checking the king" do
      it "returns a list of the checking pieces" do
        black_queen = Queen.new(:black, [2, 1])
        black_rook = Rook.new(:black, [4, 6])
        piece_move.move_piece([7, 4], [4, 3])
        board[2][1] = black_queen
        board[4][6] = black_rook
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:white)
        expect(piece_move.checking_pieces.length).to eq(2)
        expect(piece_move.checking_pieces).to contain_exactly(Queen, Rook)
      end
    end
  end

  describe "#possible_block?" do
    let(:board) { piece_move.board }
    context "when king check can be blocked" do
      it "returns true" do
        black_rook = Rook.new(:black, [4, 6])
        piece_move.move_piece([7, 4], [4, 3])
        board[4][6] = black_rook
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:white)
        expect(piece_move.possible_block?).to be true
      end
    end
    context "when 2 pieces are checking the king" do
      it "returns false" do
        black_queen = Queen.new(:black, [2, 1])
        black_rook = Rook.new(:black, [4, 6])
        piece_move.move_piece([7, 4], [4, 3])
        board[2][1] = black_queen
        board[4][6] = black_rook
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:white)
        expect(piece_move.possible_block?).to be false
      end
    end
    context "when king checked by a knight" do
      it "returns false" do
        black_knight = Knight.new(:black, [5, 5])
        piece_move.move_piece([7, 4], [4, 3])
        board[5][5] = black_knight
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:white)
        expect(piece_move.possible_block?).to be false
      end
    end
    context "when king checked by a pawn" do
      it "returns false" do
        piece_move.move_piece([0, 4], [3, 4])
        piece_move.move_piece([6, 3], [4, 3])
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:black)
        expect(piece_move.possible_block?).to be false
      end
    end
  end

  describe "#checking_path" do
    let(:board) { piece_move.board }
    context "when check is horizontal right" do
      it "returns path of the check" do
        black_rook = Rook.new(:black, [4, 6])
        piece_move.move_piece([7, 4], [4, 3])
        board[4][6] = black_rook
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:white)
        expect(piece_move.checking_path).to contain_exactly([4, 5], [4, 4])
      end
    end
    context "when check is horizontal left" do
      it "returns path of the check" do
        white_rook = Rook.new(:white, [5, 4])
        piece_move.move_piece([0, 4], [2, 4])
        board[5][4] = white_rook
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:black)
        expect(piece_move.checking_path).to contain_exactly([4, 4], [3, 4])
      end
    end
    context "when check is vertical up" do
      it "returns path of the check" do
        black_rook = Rook.new(:black, [2, 3])
        piece_move.move_piece([7, 4], [5, 3])
        board[2][3] = black_rook
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:white)
        expect(piece_move.checking_path).to contain_exactly([3, 3], [4, 3])
      end
    end
    context "when check is vertical up" do
      it "returns path of the check" do
        white_rook = Rook.new(:white, [4, 0])
        piece_move.move_piece([0, 4], [4, 6])
        board[4][0] = white_rook
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:black)
        expect(piece_move.checking_path).to contain_exactly([4, 1], [4, 2], [4, 3], [4, 4], [4, 5])
      end
    end
    context "when check is diagonal up-left" do
      it "returns path of the check" do
        black_bishop = Bishop.new(:black, [2, 1])
        piece_move.move_piece([7, 4], [5, 4])
        board[2][1] = black_bishop
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:white)
        expect(piece_move.checking_path).to contain_exactly([3, 2], [4, 3])
      end
    end
    context "when check is diagonal up-right" do
      it "returns path of the check" do
        black_bishop = Bishop.new(:black, [2, 6])
        piece_move.move_piece([7, 4], [5, 3])
        board[2][6] = black_bishop
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:white)
        expect(piece_move.checking_path).to contain_exactly([3, 5], [4, 4])
      end
    end
    context "when check is diagonal down-left" do
      it "returns path of the check" do
        white_queen = Queen.new(:white, [5, 1])
        piece_move.move_piece([0, 4], [2, 4])
        board[5][1] = white_queen
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:black)
        expect(piece_move.checking_path).to contain_exactly([4, 2], [3, 3])
      end
    end
    context "when check is diagonal down-right" do
      it "returns path of the check" do
        white_queen = Queen.new(:white, [5, 6])
        piece_move.move_piece([0, 4], [2, 3])
        board[5][6] = white_queen
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:black)
        expect(piece_move.checking_path).to contain_exactly([4, 5], [3, 4])
      end
    end
  end

  describe "#capture_checking_piece?" do
    let(:board) { piece_move.board }
    context "when checking piece an be captured" do
      it "returns square of checking piece" do
        black_knight = Knight.new(:black, [4, 6])
        white_rook = Rook.new(:white, [4, 1])
        piece_move.move_piece([7, 4], [5, 4])
        board[4][6] = black_knight
        board[4][1] = white_rook
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.find_checking_pieces(:white)
        expect(piece_move.capture_checking_piece?).to be true
      end
    end
  end

  describe "#remove_illegal_moves_in_check" do
    let(:board) { piece_move.board }
    context "when checking piece an be captured" do
      it "returns square of checking piece" do
        black_knight = Knight.new(:black, [4, 6])
        white_rook = Rook.new(:white, [4, 1])
        piece_move.move_piece([7, 4], [5, 4])
        board[4][6] = black_knight
        board[4][1] = white_rook
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.remove_illegal_moves_in_check(:white)
        expect(white_rook.possible_moves).to contain_exactly([4, 6])
        piece_move.white_pieces.each do |piece|
          expect(piece.possible_moves).to be_empty if piece != white_rook && !piece.is_a?(King)
        end
      end
    end
    context "when a check can be blocked" do
      it "removes all moves that are blocking" do
        e6 = board[1][3]
        white_bishop = Bishop.new(:white, [5, 1])
        piece_move.move_piece([0, 4], [2, 4])
        piece_move.clear_moves
        board[5][1] = white_bishop
        piece_move.board_obj.display_board
        piece_move.create_possible_moves
        piece_move.remove_illegal_moves_in_check(:black)
        expect(e6.possible_moves).to contain_exactly([3, 3])
        piece_move.black_pieces.each do |piece|
          expect(piece.possible_moves).to be_empty if piece != e6 && !piece.is_a?(King)
        end
      end
    end
  end

  describe "#pinned?" do
    let(:board) { piece_move.board }
    context "when a knight is pinned by a rook" do
      it "returns true" do
        black_rook = Rook.new(:black, [2, 4])
        piece_move.move_piece([7, 4], [5, 4])
        white_knight = Knight.new(:white, [4, 4])
        board[2][4] = black_rook
        board[4][4] = white_knight
        piece_move.create_moves
        piece_move.board_obj.display_board
        expect(piece_move.pinned?(white_knight)).to be true
      end
    end
    context "when a pawn is pinned by a bishop" do
      it "returns true" do
        piece_move.move_piece([0, 4], [2, 1])
        piece_move.move_piece([7, 2], [5, 4])
        piece_move.move_piece([1, 0], [3, 2])
        pawn = board[3][2]
        piece_move.board_obj.display_board
        expect(piece_move.pinned?(pawn)).to be true
      end
    end
    context "when a piece is not pinned" do
      it "returns false" do
        piece_move.move_piece([0, 4], [2, 1])
        piece_move.move_piece([7, 2], [5, 4])
        piece_move.move_piece([1, 0], [3, 2])
        piece_move.move_piece([0, 1], [4, 3])
        pawn = board[3][2]
        knight = board[4][3]
        piece_move.board_obj.display_board
        expect(piece_move.pinned?(pawn)).to be false
        expect(piece_move.pinned?(knight)).to be false
      end
    end
  end
  describe "#remove_pinned_moves" do
    let(:board) { piece_move.board }
    context "when a white knight is pinned by a black rook" do
      it "removes all the knight's moves" do
        piece_move.move_piece([7, 4], [5, 4])
        piece_move.move_piece([7, 1], [4, 4])
        piece_move.move_piece([0, 0], [2, 4])
        knight = board[4][4]
        piece_move.board_obj.display_board
        piece_move.remove_pinned_moves
        expect(knight.possible_moves).to be_empty
      end
    end
    context "when a black pawn is pinned by a white bishop" do
      it "removes all the pawn's moves" do
        piece_move.move_piece([0, 4], [2, 4])
        piece_move.move_piece([1, 3], [3, 3])
        piece_move.move_piece([7, 5], [5, 1])
        pawn = board[3][3]
        piece_move.board_obj.display_board
        piece_move.remove_pinned_moves
        expect(pawn.possible_moves).to be_empty
      end
    end
    context "when white and black are both pinned" do
      it "removes the illegal moves for both sides" do
        piece_move.move_piece([0, 4], [2, 4])
        piece_move.move_piece([1, 3], [3, 3])
        piece_move.move_piece([7, 5], [5, 1])
        piece_move.move_piece([7, 4], [5, 6])
        piece_move.move_piece([0, 3], [3, 4])
        piece_move.move_piece([7, 2], [4, 5])
        black_pawn = board[3][3]
        white_bishop = board[4][5]
        piece_move.board_obj.display_board
        piece_move.remove_pinned_moves
        expect(black_pawn.possible_moves).to be_empty
        expect(white_bishop.possible_moves).to contain_exactly([3, 4])
      end
    end
  end

  describe "#promotion?" do
    context "pawn has promoted" do
      before do
        allow(piece_move).to receive(:gets).and_return("R")
      end
      it "returns true" do
        a2 = piece_move.board[6][0]
        piece_move.move_piece([6, 0], [0, 0])
        piece_move.board_obj.display_board
        expect(piece_move.promotion?(a2)).to be true
      end
    end
    context "pawn has not promoted" do
      it "returns false" do
        a2 = piece_move.board[6][0]
        piece_move.move_piece([6, 0], [4, 0])
        piece_move.board_obj.display_board
        expect(piece_move.promotion?(a2)).to be false
      end
    end
  end
  describe "#promote" do
    context "when a pawn has promoted to a knight" do
      before do
        new_piece = "N"
        allow(piece_move).to receive(:gets).and_return(new_piece)
      end
      it "replaces pawn with knight" do
        a2 = piece_move.board[6][0]
        piece_move.move_piece([6, 0], [0, 0])
        piece_move.promote(a2)
        piece_move.board_obj.display_board
        expect(piece_move.board[0][0]).to be_kind_of(Knight)
      end
    end
    context "when invalid inputs is given twice then a correct one" do
      before do
        allow(piece_move).to receive(:gets).and_return("Z", "K", "R") # Invalid, invalid, then valid
      end
      it "prints 2 error messages, then plays the move and promotes correctly" do
        prompt_message = "Piece format N:Knight, Q:Queen, R:Rook, B:Bishop\nWhich pieces would you like to promote to?:"
        error_message = "Invalid: must be in chess notation format N:Knight, Q:Queen, R:Rook, B:Bishop"
        allow(piece_move).to receive(:puts).with(prompt_message)
        expect(piece_move).to receive(:puts).with(error_message).twice
        piece_move.move_piece([6, 0], [0, 0])
        expect(piece_move.board[0][0]).to be_kind_of(Rook)
      end
    end
  end

  describe "#short_castle?" do
    context "when white king can castle short" do
      it "returns true" do
        king = piece_move.board[7][4]
        piece_move.board[7][5] = " "
        piece_move.board[7][6] = " "
        piece_move.create_possible_moves
        piece_move.board_obj.display_board
        expect(piece_move.short_castle?(king)).to be true
      end
    end
  end
  describe "#long_castle?" do
    context "when white king can castle long" do
      it "returns true" do
        king = piece_move.board[7][4]
        piece_move.board[7][3] = " "
        piece_move.board[7][2] = " "
        piece_move.board[7][1] = " "
        piece_move.create_possible_moves
        piece_move.board_obj.display_board
        expect(piece_move.long_castle?(king)).to be true
      end
    end
  end
  describe "#castle" do
    context "when white king can castle long" do
      it "the pieces move on the board correctly" do
        king = piece_move.board[7][4]
        piece_move.board[7][3] = " "
        piece_move.board[7][2] = " "
        piece_move.board[7][1] = " "
        piece_move.create_possible_moves
        piece_move.castle(king, [7, 0])
        piece_move.board_obj.display_board
        expect(piece_move.board[7][2]).to be_kind_of(King)
        expect(piece_move.board[7][3]).to be_kind_of(Rook)
      end
    end
    context "when white king can castle short" do
      it "the pieces move on the board correctly" do
        king = piece_move.board[7][4]
        piece_move.board[7][5] = " "
        piece_move.board[7][6] = " "
        piece_move.create_possible_moves
        piece_move.castle(king, [7, 7])
        piece_move.board_obj.display_board
        expect(piece_move.board[7][6]).to be_kind_of(King)
        expect(piece_move.board[7][5]).to be_kind_of(Rook)
      end
    end
  end
end