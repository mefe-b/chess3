require_relative '../lib/pieces/knight'

describe Knight do
  describe '#create_possible_moves' do
    context 'when knight is in the middle of the board' do
      subject(:d4_white_knight) { described_class.new(:white, [4, 3]) }
      it 'creates list of possible moves' do
        d4_white_knight.create_possible_moves
        expect(d4_white_knight.possible_moves).to contain_exactly([2, 2], [6, 2], [2, 4], [6, 4],
                                                                  [3, 1], [5, 1], [3, 5], [5, 5])
      end
    end
    context 'when knight is on edge of board' do
      subject(:a1_white_knight) { described_class.new(:white, [7, 0]) }
      it 'creates list of possible moves' do
        a1_white_knight.create_possible_moves
        expect(a1_white_knight.possible_moves).to contain_exactly([5, 1], [6, 2])
      end
    end
  end
  describe '#create_up_moves' do
    context 'when knight is in the middle of the board' do
      subject(:d4_white_knight) { described_class.new(:white, [4, 3]) }
      it 'creates list of possible moves going up' do
        d4_white_knight.create_up_moves(4, 3)
        expect(d4_white_knight.possible_moves).to contain_exactly([2, 2], [2, 4])
      end
    end
  end
  describe '#create_down_moves' do
    context 'when knight is in the middle of the board' do
      subject(:d4_white_knight) { described_class.new(:white, [4, 3]) }
      it 'creates list of possible moves going down' do
        d4_white_knight.create_down_moves(4, 3)
        expect(d4_white_knight.possible_moves).to contain_exactly([6, 2], [6, 4])
      end
    end
  end
  describe '#create_left_moves' do
    context 'when knight is in the middle of the board' do
      subject(:d4_white_knight) { described_class.new(:white, [4, 3]) }
      it 'creates list of possible moves going left' do
        d4_white_knight.create_left_moves(4, 3)
        expect(d4_white_knight.possible_moves).to contain_exactly([3, 1], [5, 1])
      end
    end
  end
  describe '#create_right_moves' do
    context 'when knight is in the middle of the board' do
      subject(:d4_white_knight) { described_class.new(:white, [4, 3]) }
      it 'creates list of possible moves going right' do
        d4_white_knight.create_right_moves(4, 3)
        expect(d4_white_knight.possible_moves).to contain_exactly([3, 5], [5, 5])
      end
    end
  end
end
