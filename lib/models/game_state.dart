import 'dart:math';

enum MoveDirection { up, down, left, right }

class MoveResult {
  const MoveResult({
    required this.board,
    required this.scoreGained,
    required this.changed,
  });

  final List<List<int>> board;
  final int scoreGained;
  final bool changed;
}

class GameState {
  GameState({Random? random}) : _random = random ?? Random() {
    reset();
  }

  final Random _random;
  late List<List<int>> board;
  int score = 0;
  int bestScore = 0;
  bool hasWon = false;
  bool keepPlaying = false;
  bool isGameOver = false;
  List<List<int>>? _previousBoard;
  int? _previousScore;

  void reset() {
    board = List.generate(4, (_) => List.filled(4, 0));
    score = 0;
    hasWon = false;
    keepPlaying = false;
    isGameOver = false;
    _previousBoard = null;
    _previousScore = null;
    _addRandomTile();
    _addRandomTile();
  }

  List<List<int>> _copyBoard(List<List<int>> source) =>
      source.map((row) => List<int>.from(row)).toList();

  bool get canUndo => _previousBoard != null;

  void undo() {
    if (_previousBoard == null) return;
    board = _copyBoard(_previousBoard!);
    score = _previousScore ?? score;
    _previousBoard = null;
    _previousScore = null;
    isGameOver = false;
  }

  MoveResult move(MoveDirection direction) {
    final before = _copyBoard(board);
    final next = _copyBoard(board);
    var gained = 0;

    for (var line = 0; line < 4; line++) {
      final values = <int>[];
      for (var offset = 0; offset < 4; offset++) {
        final r = direction == MoveDirection.up
            ? offset
            : direction == MoveDirection.down
                ? 3 - offset
                : line;
        final c = direction == MoveDirection.left
            ? offset
            : direction == MoveDirection.right
                ? 3 - offset
                : line;
        final value = board[r][c];
        if (value != 0) values.add(value);
      }

      final merged = <int>[];
      var i = 0;
      while (i < values.length) {
        if (i + 1 < values.length && values[i] == values[i + 1]) {
          final value = values[i] * 2;
          merged.add(value);
          gained += value;
          i += 2;
        } else {
          merged.add(values[i]);
          i++;
        }
      }
      while (merged.length < 4) {
        merged.add(0);
      }

      for (var offset = 0; offset < 4; offset++) {
        final r = direction == MoveDirection.up
            ? offset
            : direction == MoveDirection.down
                ? 3 - offset
                : line;
        final c = direction == MoveDirection.left
            ? offset
            : direction == MoveDirection.right
                ? 3 - offset
                : line;
        next[r][c] = merged[offset];
      }
    }

    var changed = false;
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        if (before[r][c] != next[r][c]) changed = true;
      }
    }

    if (changed) {
      _previousBoard = before;
      _previousScore = score;
      board = next;
      score += gained;
      if (score > bestScore) bestScore = score;
      _addRandomTile();
      if (board.expand((row) => row).contains(2048)) hasWon = true;
      isGameOver = !_hasMoves();
    }
    return MoveResult(board: _copyBoard(board), scoreGained: gained, changed: changed);
  }

  void continueAfterWin() {
    keepPlaying = true;
    hasWon = false;
  }

  void _addRandomTile() {
    final empty = <({int r, int c})>[];
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        if (board[r][c] == 0) empty.add((r: r, c: c));
      }
    }
    if (empty.isEmpty) return;
    final spot = empty[_random.nextInt(empty.length)];
    board[spot.r][spot.c] = _random.nextInt(10) == 0 ? 4 : 2;
  }

  bool _hasMoves() {
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        if (board[r][c] == 0) return true;
        if (r < 3 && board[r][c] == board[r + 1][c]) return true;
        if (c < 3 && board[r][c] == board[r][c + 1]) return true;
      }
    }
    return false;
  }
}
