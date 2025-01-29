require_relative "../lib/pieces/king"

describe King do
  describe "#create_possible_moves" do
    context "at the start of the game for white" do
      subject(:start_white_king) { described_class.new(:white, [7, 4]) }
      it "creates list of possible moves for king" do
        start_white_king.create_possible_moves
        expect(start_white_king.possible_moves).to include([7, 3], [7, 5], [6, 4], [6, 3], [6, 5])
      end
    end
    context "when king is the middle of board" do
      subject(:d4_white_king) { described_class.new(:white, [4, 3]) }
      it "creates list of possible moves" do
        d4_white_king.create_possible_moves
        expect(d4_white_king.possible_moves).to contain_exactly([3, 3], [3, 2], [3, 4], [5, 3], [5, 2], [5, 4],
                                                                [4, 2], [4, 4])
      end
    end
  end
  subject(:start_white_king) { described_class.new(:white, [7, 4]) }

  describe "#create_up_moves" do
    context "when king is on his starting square" do
      it "creates list of possible moves going up" do
        start_white_king.create_up_moves(7, 4)
        expect(start_white_king.possible_moves).to include([6, 4], [6, 3], [6, 5])
      end
    end
  end
  describe "#create_down_moves" do
    context "when king is on his starting square" do
      it "creates list of possible moves going down" do
        start_white_king.create_down_moves(7, 4)
        expect(start_white_king.possible_moves).to be_empty
      end
    end
  end
  describe "#create_left_moves" do
    context "when king is on his starting square" do
      it "creates list of possible moves going left" do
        start_white_king.create_left_moves(7, 4)
        expect(start_white_king.possible_moves).to include([7, 3])
      end
    end
  end
  describe "#create_right_moves" do
    context "when king is on his starting square" do
      it "creates list of possible moves going right" do
        start_white_king.create_right_moves(7, 4)
        expect(start_white_king.possible_moves).to include([7, 5])
      end
    end
  end
end