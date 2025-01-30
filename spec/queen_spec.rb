require_relative '../lib/pieces/queen'

describe Queen do
  describe '#create_possible_moves' do
    context 'at the start of the game for white' do
      subject(:start_white_queen) { described_class.new(:white, [7, 3]) }
      it 'creates list of possible moves' do
        start_white_queen.create_possible_moves
        horizontal_moves = [[7, 0], [7, 1], [7, 2], [7, 4], [7, 5], [7, 6], [7, 7]]
        vertical_moves = [[6, 3], [5, 3], [4, 3], [3, 3], [2, 3], [1, 3], [0, 3]]
        diagonal_moves = [[6, 2], [5, 1], [4, 0], [6, 4], [5, 5], [4, 6], [3, 7]]
        expect(start_white_queen.possible_moves).to contain_exactly(*horizontal_moves, *vertical_moves, *diagonal_moves)
      end
    end
    context 'at the start of the game for black' do
      subject(:start_black_queen) { described_class.new(:black, [0, 3]) }
      it 'creates list of possible moves' do
        start_black_queen.create_possible_moves
        horizontal_moves = [[0, 0], [0, 1], [0, 2], [0, 4], [0, 5], [0, 6], [0, 7]]
        vertical_moves = [[7, 3], [6, 3], [5, 3], [4, 3], [3, 3], [2, 3], [1, 3]]
        diagonal_moves = [[1, 2], [2, 1], [3, 0], [1, 4], [2, 5], [3, 6], [4, 7]]
        expect(start_black_queen.possible_moves).to contain_exactly(*horizontal_moves, *vertical_moves, *diagonal_moves)
      end
    end
  end
end
