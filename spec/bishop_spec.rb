require_relative "../lib/pieces/bishop"

describe Bishop do
  describe "#create_possible_moves" do
    context "at the start of the game for white" do
      subject(:start_white_light_bishop) { described_class.new(:white, [7, 5]) }
      subject(:start_white_dark_bishop) { described_class.new(:white, [7, 2]) }
      it "creates list of possible moves" do
        start_white_light_bishop.create_possible_moves
        start_white_dark_bishop.create_possible_moves
        expect(start_white_light_bishop.possible_moves).to contain_exactly([6, 4], [5, 3], [4, 2], [3, 1], [2, 0],
                                                                           [6, 6], [5, 7])
        expect(start_white_dark_bishop.possible_moves).to contain_exactly([6, 1], [5, 0],
                                                                          [6, 3], [5, 4], [4, 5], [3, 6], [2, 7])
      end
    end
  end
end