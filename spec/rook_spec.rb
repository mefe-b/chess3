require_relative '../lib/pieces/rook'

describe Rook do
  describe '#create_possible_moves' do
    context 'at the start of the game for white' do
      subject(:start_white_rook_a1) { described_class.new(:white, [7, 0]) }
      subject(:start_white_rook_h1) { described_class.new(:white, [7, 7]) }
      it 'creates list of possible moves' do
        start_white_rook_a1.create_possible_moves
        start_white_rook_h1.create_possible_moves
        expect(start_white_rook_a1.possible_moves).to include([7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7],
                                                              [6, 0], [5, 0], [4, 0], [3, 0], [2, 0], [1, 0], [0, 0])
        expect(start_white_rook_h1.possible_moves).to include([7, 6], [7, 5], [7, 4], [7, 3], [7, 2], [7, 1], [7, 0],
                                                              [6, 7], [5, 7], [4, 7], [3, 7], [2, 7], [1, 7], [0, 7])
      end
    end
    context 'at the start of the game for black' do
      subject(:start_black_rook_a8) { described_class.new(:black, [0, 0]) }
      subject(:start_black_rook_h8) { described_class.new(:black, [0, 7]) }
      it 'creates list of possible moves' do
        start_black_rook_a8.create_possible_moves
        start_black_rook_h8.create_possible_moves
        expect(start_black_rook_a8.possible_moves).to include([0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7],
                                                              [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0])
        expect(start_black_rook_h8.possible_moves).to include([0, 6], [0, 5], [0, 4], [0, 3], [0, 2], [0, 1], [0, 0],
                                                              [1, 7], [2, 7], [3, 7], [4, 7], [5, 7], [6, 7], [7, 7])
      end
    end
  end
end
