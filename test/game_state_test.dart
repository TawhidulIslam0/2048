import 'package:flutter_test/flutter_test.dart';
import 'package:tile_2048/models/game_state.dart';

void main() {
  group('2048 game state', () {
    test('starts with two tiles and a zero score', () {
      final game = GameState();
      final tiles = game.board.expand((row) => row).where((v) => v != 0).length;
      expect(tiles, 2);
      expect(game.score, 0);
    });

    test('left move merges equal tiles and adds score', () {
      final game = GameState();
      game.board = [
        [2, 2, 2, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      final result = game.move(MoveDirection.left);
      expect(game.board[0], [4, 4, 0, 0]);
      expect(result.scoreGained, 8);
      expect(game.score, 8);
    });

    test('a tile cannot merge twice in one move', () {
      final game = GameState();
      game.board = [
        [2, 2, 4, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      game.move(MoveDirection.left);
      expect(game.board[0][0], 4);
      expect(game.board[0][1], 4);
    });

    test('undo restores previous board and score', () {
      final game = GameState();
      game.board = [
        [2, 2, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];
      game.score = 0;
      game.move(MoveDirection.left);
      game.undo();
      expect(game.board[0], [2, 2, 0, 0]);
      expect(game.score, 0);
    });
  });
}
