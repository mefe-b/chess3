require_relative '../lib/board'
describe Board do
  let(:chess_board) { described_class.new }
  describe '#display_baord' do
    before do
      chess_board.fill_board
    end
    context 'when board is filled' do
      it 'displays pieces correctly' do
        chess_board.display_board
      end
    end
  end
  describe '#fill_board' do
    before do
      chess_board.send(:fill_board)
    end
    it 'fills board with chess pieces' do
      expected_positions = {
        # White major pieces
        [0, 0] => Rook, [0, 1] => Knight, [0, 2] => Bishop, [0, 3] => Queen, [0, 4] => King,
        [0, 5] => Bishop, [0, 6] => Knight, [0, 7] => Rook,

        # Black major pieces
        [7, 0] => Rook, [7, 1] => Knight, [7, 2] => Bishop, [7, 3] => Queen, [7, 4] => King,
        [7, 5] => Bishop, [7, 6] => Knight, [7, 7] => Rook,

        # White pawns
        [1, 0] => Pawn, [1, 1] => Pawn, [1, 2] => Pawn, [1, 3] => Pawn,
        [1, 4] => Pawn, [1, 5] => Pawn, [1, 6] => Pawn, [1, 7] => Pawn,

        # Black pawns
        [6, 0] => Pawn, [6, 1] => Pawn, [6, 2] => Pawn, [6, 3] => Pawn,
        [6, 4] => Pawn, [6, 5] => Pawn, [6, 6] => Pawn, [6, 7] => Pawn
      }

      expected_positions.each do |(row, col), piece_class|
        expect(chess_board.board[row][col]).to be_a(piece_class)
      end
    end
    it 'places black pieces correctly' do
      expected_colors = {
        # (row 0): Black pieces
        [0, 0] => :black, [0, 1] => :black, [0, 2] => :black, [0, 3] => :black,
        [0, 4] => :black, [0, 5] => :black, [0, 6] => :black, [0, 7] => :black,

        # (row 1): Black pawns
        [1, 0] => :black, [1, 1] => :black, [1, 2] => :black, [1, 3] => :black,
        [1, 4] => :black, [1, 5] => :black, [1, 6] => :black, [1, 7] => :black
      }

      expected_colors.each do |(row, col), expected_color|
        piece = chess_board.board[row][col]
        expect(piece.color).to eq(expected_color)
      end
    end
    it 'places white pieces correctly' do
      expected_colors = {
        # (row 7): White pieces
        [7, 0] => :white, [7, 1] => :white, [7, 2] => :white, [7, 3] => :white,
        [7, 4] => :white, [7, 5] => :white, [7, 6] => :white, [7, 7] => :white,

        # (row 6): White pawns
        [6, 0] => :white, [6, 1] => :white, [6, 2] => :white, [6, 3] => :white,
        [6, 4] => :white, [6, 5] => :white, [6, 6] => :white, [6, 7] => :white
      }

      expected_colors.each do |(row, col), expected_color|
        piece = chess_board.board[row][col]
        expect(piece.color).to eq(expected_color)
      end
    end
    it 'sets the current squares' do
      staring_rows = [0, 1, 6, 7]
      chess_board.board.each_with_index do |row, row_index|
        row.each_index do |col_index|
          if staring_rows.include?(row_index)
            piece = chess_board.board[row_index][col_index]
            expect(piece.current_square).to eq([row_index, col_index])
          end
        end
      end
    end
  end

  describe '#highlight' do
    before do
      chess_board.fill_board
    end
    context 'when board is filled' do
      it 'displays pieces correctly' do
        moves = [[0, 0]]
        chess_board.highlight(moves)
      end
    end
  end
end
