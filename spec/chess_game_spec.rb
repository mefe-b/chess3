require_relative '../lib/chess_game'

describe ChessGame do
  let(:game) { described_class.new }
  describe '#valid_piece?' do
    context 'when a valid square is entered for white' do
      it 'returns true' do
        valid_move1 = 'e2'
        valid_move2 = 'a1'
        expect(game.valid_piece?(valid_move1)).to be false
        expect(game.valid_piece?(valid_move2)).to be false
      end
    end
    context 'when a invalid square is entered for white' do
      it 'returns true' do
        valid_move1 = 'e4'
        valid_move2 = 'a4'
        expect(game.valid_piece?(valid_move1)).to be false
        expect(game.valid_piece?(valid_move2)).to be false
      end
    end
    context 'when a valid square is entered for black' do
      it 'returns true' do
        valid_move1 = 'f8'
        valid_move2 = 'h7'
        game.send(:flip_player_turn)
        expect(game.valid_piece?(valid_move1)).to be false
        expect(game.valid_piece?(valid_move2)).to be false
      end
    end
    context 'when a invalid square is entered for black' do
      it 'returns true' do
        valid_move1 = 'f4'
        valid_move2 = 'h2'
        game.send(:flip_player_turn)
        expect(game.valid_piece?(valid_move1)).to be false
        expect(game.valid_piece?(valid_move2)).to be false
      end
    end
  end

  describe '#valid_move?' do
    context 'when a valid move is entered for white' do
      it 'returns true' do
        selected_piece = game.board[6][3]
        valid_move = 'd3'
        game.move_logic.send(:create_possible_moves)
        expect(game.valid_move?(selected_piece, valid_move)).to be true
      end
    end
    context 'when a invalid move is entered for white' do
      it 'returns true' do
        selected_piece = game.board[6][3]
        invalid_move = 'h1'
        game.move_logic.send(:create_possible_moves)
        expect(game.valid_move?(selected_piece, invalid_move)).to be false
      end
    end
  end
  describe '#play_round' do
    context 'at the start of the game' do
      before do
        selected_square = 'e2'
        selected_move = 'e4'
        allow(game).to receive(:gets).and_return(selected_square, selected_move)
      end
      it 'moves the correct piece to the correct square' do
        game.send(:play_round)
        old_position = game.move_logic.chess_notation_to_square('e2')
        new_position = game.move_logic.chess_notation_to_square('e4')
        expect(new_position).to be_a(Pawn)
        expect(old_position).to eq(' ')
      end
    end
    context 'white and black both play a move' do
      before do
        moves = %w[d2 d4 e7 e5]
        allow(game).to receive(:gets).and_return(*moves)
      end
      it 'moves the correct piece to the correct square' do
        game.send(:play_round)
        game.send(:play_round)
        old_position_white = game.move_logic.chess_notation_to_square('d2')
        new_position_white = game.move_logic.chess_notation_to_square('d4')
        old_position_black = game.move_logic.chess_notation_to_square('e7')
        new_position_black = game.move_logic.chess_notation_to_square('e5')
        expect(new_position_white).to be_a(Pawn)
        expect(old_position_white).to eq(' ')
        expect(new_position_black).to be_a(Pawn)
        expect(old_position_black).to eq(' ')
      end
    end
    context 'white and black both play a move' do
      before do
        moves = %w[d2 d4 e7 e5 c1 f4 e5 f4]
        allow(game).to receive(:gets).and_return(*moves)
        (moves.length / 2).times { game.send(:play_round) }
      end
      it 'moves the correct piece to the correct square' do
        final_position_white_pawn = game.move_logic.chess_notation_to_square('d4')
        final_position_black_pawn = game.move_logic.chess_notation_to_square('f4')
        expect(final_position_white_pawn).to be_a(Pawn).and have_attributes(color: :white)
        expect(final_position_black_pawn).to be_a(Pawn).and have_attributes(color: :black)
      end
    end
    context 'white and black both play a move' do
      before do
        moves = %w[d2 d4 e7 e5 c1 f4 e5 f4]
        allow(game).to receive(:gets).and_return(*moves)
        (moves.length / 2).times { game.send(:play_round) }
      end
      it 'moves the correct piece to the correct square' do
        final_position_white_pawn = game.move_logic.chess_notation_to_square('d4')
        final_position_black_pawn = game.move_logic.chess_notation_to_square('f4')
        expect(final_position_white_pawn).to be_a(Pawn).and have_attributes(color: :white)
        expect(final_position_black_pawn).to be_a(Pawn).and have_attributes(color: :black)
      end
    end
    context 'given invalid moves' do
      before do
        moves = %w[d2 d3 e7 e6 d3 d5 d4 e6 e4 e5]
        allow(game).to receive(:gets).and_return(*moves)
        ((moves.length / 2) - 1).times { game.send(:play_round) }
      end
      it 'reprompt until valid move is given and moves correctly' do
        final_position_white_pawn = game.move_logic.chess_notation_to_square('d4')
        final_position_black_pawn = game.move_logic.chess_notation_to_square('e5')
        expect(final_position_white_pawn).to be_a(Pawn).and have_attributes(color: :white)
        expect(final_position_black_pawn).to be_a(Pawn).and have_attributes(color: :black)
      end
    end
    context 'when en pessant is played' do
      before do
        moves = %w[e2 e4 h7 h6 e4 e5 d7 d5 e5 d6 h6 h5]
        allow(game).to receive(:gets).and_return(*moves)
        ((moves.length / 2) - 1).times { game.send(:play_round) }
      end
      it 'capture with en pessant' do
        expect(game.move_logic.board[3][3]).to eq(' ')
      end
    end
    context 'when white castles' do
      before do
        moves = %w[e2 e4 d7 d5 f1 c4 e7 e6 g1 f3 e6 e5 e1 h1]
        allow(game).to receive(:gets).and_return(*moves)
        7.times { game.send(:play_round) }
      end
      it 'is a valid move and places pieces correctly' do
        error_message = 'h1 is not a valid move'
        game.move_logic.board_obj.display_board
        expect(game.board[7][6]).to be_kind_of(King)
        expect(game.board[7][5]).to be_kind_of(Rook)
        expect(game).not_to receive(:puts).with(error_message)
      end
    end
    context 'when wrong inputs is given' do
      before do
        moves = %w[draw d e2 e4]
        allow(game).to receive(:gets).and_return(*moves)
      end
      it 'reprompt' do
        error_message = 'draw is not valid, please enter a valid move'
        allow(game).to receive(:puts)
        expect(game).to receive(:puts).with(error_message).once
        game.send(:play_round)
      end
    end
  end
  describe '#checkmate?' do
    context 'when white has checkmated black' do
      before do
        moves = %w[e2 e4 e7 e5 f1 c4 b8 c6 d1 h5 g8 f6 h5 f7]
        allow(game).to receive(:gets).and_return(*moves)
        ((moves.length / 2)).times { game.send(:play_round) }
        game.move_logic.board_obj.display_board
      end
      it 'returns true' do
        expect(game.checkmate?).to be true
      end
    end
    context 'when there is king vs king' do
      before do
        game.move_logic.board_obj.clear_board
        game.board[0][0] = King.new(:white, [0, 0])
        game.board[7][7] = King.new(:black, [7, 7])
        game.board[7][6] = Pawn.new(:white, [7, 6])
        moves = %w[g1 g2 h1 g2]
        allow(game).to receive(:gets).and_return(*moves)
        2.times { game.send(:play_round) }
        game.move_logic.board_obj.display_board
      end
      it 'flips draw to true and ends game' do
        expect(game.draw?).to be true
      end
    end
    context 'when there is king and Bishop vs king' do
      before do
        game.move_logic.board_obj.clear_board
        game.board[0][0] = King.new(:white, [0, 0])
        game.board[1][1] = Bishop.new(:white, [1, 1])
        game.board[7][7] = King.new(:black, [7, 7])
        game.board[6][6] = Pawn.new(:black, [6, 6])
        moves = %w[b7 g2]
        game.move_logic.board_obj.display_board
        allow(game).to receive(:gets).and_return(*moves)
        game.send(:play_round)
        game.move_logic.board_obj.display_board
      end
      it 'flips draw to true and ends game' do
        game.move_logic.board_obj.display_board
        expect(game.draw?).to be true
      end
    end
    context 'when there is king and knight vs king' do
      before do
        game.move_logic.board_obj.clear_board
        game.board[0][0] = King.new(:white, [0, 0])
        game.board[4][7] = Knight.new(:white, [4, 7])
        game.board[7][7] = King.new(:black, [7, 7])
        game.board[6][6] = Pawn.new(:black, [6, 6])
        moves = %w[h4 g2]
        game.move_logic.board_obj.display_board
        allow(game).to receive(:gets).and_return(*moves)
        game.send(:play_round)
        game.move_logic.board_obj.display_board
      end
      it 'flips draw to true and ends game' do
        game.move_logic.board_obj.display_board
        expect(game.draw?).to be true
      end
    end
  end

  describe '#play_game' do
    context 'when white has checkmated black' do
      before do
        moves = %w[e2 e4 e7 e5 f1 c4 b8 c6 d1 h5 g8 f6 h5 f7]
        allow(game).to receive(:gets).and_return(*moves)
      end
      it 'returns game over message' do
        game_over_message = 'Game over'
        allow(game).to receive(:puts)
        expect(game).to receive(:puts).with(game_over_message).once
        game.play_game
      end
    end
    context 'when black has checkmated white' do
      before do
        moves = %w[f2 f3 e7 e5 g2 g4 d8 h4]
        allow(game).to receive(:gets).and_return(*moves)
      end
      it 'returns game over message' do
        game_over_message = 'Game over'
        allow(game).to receive(:puts)
        expect(game).to receive(:puts).with(game_over_message).once
        game.play_game
      end
    end
    context 'when white offers a draw and black accepts' do
      before do
        allow(game).to receive(:gets).and_return('draw', 'a')
      end
      it 'exits game' do
        draw_message = 'Game over'
        allow(game).to receive(:puts)
        expect(game).to receive(:puts).with(draw_message).once
        game.play_game
      end
    end
    context 'when white offers draw after a couple of moves' do
      before do
        allow(game).to receive(:gets).and_return('e2', 'e4', 'd7', 'd5', 'draw', 'a')
      end
      it 'exits game' do
        draw_message = 'Game over'
        allow(game).to receive(:puts)
        expect(game).to receive(:puts).with(draw_message).once
        game.play_game
      end
    end
    context 'when threefold repetition occurs' do
      before do
        allow(game).to receive(:gets).and_return('e2', 'e4', 'e7', 'e5', 'e1', 'e2', 'e8', 'e7', 'e2', 'e1', 'e7',
                                                 'e8', 'e1', 'e2', 'e8', 'e7', 'e2', 'e1', 'e7', 'e8')
      end
      it 'exits game' do
        draw_message = 'Game over'
        allow(game).to receive(:puts)
        expect(game).to receive(:puts).with(draw_message).once
        game.play_game
      end
    end
  end
end

