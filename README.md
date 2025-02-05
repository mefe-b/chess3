# 🏰 Chess Game (Ruby Edition) ♟️

Welcome! 🎉 This project is a **Chess Game** built with Ruby for the command line. It's a fully functional, turn-based game where two players can compete against each other. With its unique design that mimics a real chessboard and accurate piece movements, it's sure to win the hearts of chess enthusiasts! ❤️

### 🎯 Features

- **Fully Functional Chess Game**: Two players can take turns, move pieces, capture, and the game ends when a checkmate occurs. All powered by Ruby! 💪
- **Unicode Pieces**: White pieces are represented by empty symbols, and black pieces by filled symbols. Pick your pieces! ⚪⚫
- **Standard Chess Rules**: Piece movements, check, checkmate, pawn promotion — everything's in place!
- **Realistic Chessboard Design**: A classic, stylish design with black and white squares. 🏁
- **RSpec Tests**: The core game logic is tested to ensure everything runs smoothly! 🎯

### 🔥 File Structure

Gemfile # Gem dependencies Gemfile.lock # Locked gem versions README.md # Project documentation main.rb # Main file to start the game

lib/ ├── board.rb # Manages the chessboard and piece placement ├── chess_game.rb # Manages the core game logic and flow ├── piece_move.rb # Manages piece movements ├── pieces/ # Folder containing chess pieces │ ├── bishop.rb # Logic for Bishop piece │ ├── king.rb # Logic for King piece │ ├── knight.rb # Logic for Knight piece │ ├── pawn.rb # Logic for Pawn piece │ ├── queen.rb # Logic for Queen piece │ └── rook.rb # Logic for Rook piece

spec/ ├── bishop_spec.rb # Tests for Bishop piece ├── board_spec.rb # Tests for board functionality ├── chess_game_spec.rb # Tests for game logic ├── king_spec.rb # Tests for King piece ├── knight_spec.rb # Tests for Knight piece ├── pawn_spec.rb # Tests for Pawn piece ├── piece_move_spec.rb # Tests for piece movements ├── queen_spec.rb # Tests for Queen piece └── rook_spec.rb # Tests for Rook piece └── spec_helper.rb # RSpec configuration for tests

bash
Kopyala
Düzenle

### 🚀 Installation and Usage

1. **Clone the repository**:

   ```bash
   git clone https://github.com/mefe-b/chess-game.git

2. Navigate to the project directory:

```bash
cd chess-game
Run the game:
````

```bash
ruby main.rb
```

🧪 Running Tests
RSpec is used to test the core game logic. To run the tests, simply use:

```bash
bundle exec rspec
```

🚧 Future Enhancements
Add an AI opponent for single-player mode 🤖
Add a graphical user interface (GUI) support 🖥️
Implement save and load game functionality 💾
🧑‍💻 Developer
This project is developed by Efe. (GitHub: mefe-b)


📝 License
This project is licensed under the MIT License.

```kotlin
Kopyala
Düzenle

Now the README is in English, while keeping the fun and engaging tone. 😊
```