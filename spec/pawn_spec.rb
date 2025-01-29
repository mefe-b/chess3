require_relative "../lib/pieces/pawn"

describe Pawn do
  describe "#create_possible_moves" do
    context "at the start of the game for white" do
      subject(:start_white_pawn_a2) { described_class.new(:white, [6, 0]) }
      subject(:start_white_pawn_e2) { described_class.new(:white, [6, 3]) }
      it "creates list of possible moves" do
        start_white_pawn_a2.create_possible_moves
        start_white_pawn_e2.create_possible_moves
        expect(start_white_pawn_a2.possible_moves).to contain_exactly([5, 0], [4, 0], [5, 1])
        expect(start_white_pawn_e2.possible_moves).to contain_exactly([5, 3], [4, 3], [5, 2], [5, 4])
      end
    end
    context "at the start of the game for black" do
      subject(:start_black_pawn_a6) { described_class.new(:black, [1, 0]) }
      subject(:start_black_pawn_e6) { described_class.new(:black, [1, 3]) }
      it "creates list of possible moves" do
        start_black_pawn_a6.create_possible_moves
        start_black_pawn_e6.create_possible_moves
        expect(start_black_pawn_a6.possible_moves).to contain_exactly([2, 0], [3, 0], [2, 1])
        expect(start_black_pawn_e6.possible_moves).to contain_exactly([2, 3], [3, 3], [2, 2], [2, 4])
      end
    end
  end
end