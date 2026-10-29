import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';
import '../widgets/game_board.dart';
import '../widgets/score_card.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameState _game;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _game = GameState();
    _loadBestScore();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _game.bestScore = prefs.getInt('best_score') ?? 0);
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('best_score', _game.bestScore);
  }

  void _move(MoveDirection direction) {
    if (_game.isGameOver || _dialogOpen) return;
    HapticFeedback.selectionClick();
    setState(() => _game.move(direction));
    _saveBestScore();
    if (_game.hasWon && !_game.keepPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showWinDialog());
    } else if (_game.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showGameOverDialog());
    }
  }

  void _handleSwipe(Offset velocity) {
    if (velocity.dx.abs() > velocity.dy.abs()) {
      _move(velocity.dx > 0 ? MoveDirection.right : MoveDirection.left);
    } else {
      _move(velocity.dy > 0 ? MoveDirection.down : MoveDirection.up);
    }
  }

  Future<void> _newGame({bool confirm = true}) async {
    if (confirm && _game.score > 0 && !_game.isGameOver) {
      final shouldReset = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Start a new game?'),
          content: const Text('Your current game will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('NEW GAME'),
            ),
          ],
        ),
      );
      if (shouldReset != true || !mounted) return;
    }
    setState(_game.reset);
  }

  void _showWinDialog() {
    if (!mounted || _dialogOpen || !_game.hasWon) return;
    _dialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Amazing! 🎉'),
        content: const Text('You reached 2048. Keep going and chase an even bigger tile?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(_game.continueAfterWin);
            },
            child: const Text('KEEP PLAYING'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _newGame(confirm: false);
            },
            child: const Text('NEW GAME'),
          ),
        ],
      ),
    ).whenComplete(() => _dialogOpen = false);
  }

  void _showGameOverDialog() {
    if (!mounted || _dialogOpen || !_game.isGameOver) return;
    _dialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('No moves left'),
        content: Text('Final score: ${_game.score}. Ready for another round?'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _newGame(confirm: false);
            },
            child: const Text('PLAY AGAIN'),
          ),
        ],
      ),
    ).whenComplete(() => _dialogOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boardSide = (constraints.maxWidth - 36).clamp(260.0, 520.0);
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Text(
                              '2048',
                              style: TextStyle(
                                color: Color(0xFF776E65),
                                fontSize: 54,
                                height: 1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2.5,
                              ),
                            ),
                          ),
                          ScoreCard(label: 'Score', value: _game.score),
                          const SizedBox(width: 8),
                          ScoreCard(label: 'Best', value: _game.bestScore),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Join the numbers, reach 2048.',
                              style: TextStyle(
                                color: Color(0xFF776E65),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _ActionButton(
                            icon: Icons.undo_rounded,
                            label: 'Undo',
                            onTap: _game.canUndo
                                ? () => setState(_game.undo)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            icon: Icons.refresh_rounded,
                            label: 'New',
                            onTap: () => _newGame(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: boardSide,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: GameBoard(
                              board: _game.board,
                              onSwipe: _handleSwipe,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _DirectionPad(onMove: _move),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE7E0D8)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HOW TO PLAY',
                              style: TextStyle(
                                color: Color(0xFF8F7A66),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 7),
                            Text(
                              'Swipe or use the arrows to slide every tile. Matching numbers merge into one and add to your score. Reach the 2048 tile to win!',
                              style: TextStyle(
                                color: Color(0xFF776E65),
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? const Color(0xFFE8E1D9) : const Color(0xFF8F7A66),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 17, color: onTap == null ? const Color(0xFFB5AAA0) : Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: onTap == null ? const Color(0xFFB5AAA0) : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectionPad extends StatelessWidget {
  const _DirectionPad({required this.onMove});

  final ValueChanged<MoveDirection> onMove;

  @override
  Widget build(BuildContext context) {
    Widget keyButton(IconData icon, MoveDirection direction) {
      return SizedBox(
        width: 58,
        height: 48,
        child: FilledButton(
          onPressed: () => onMove(direction),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF8F7A66),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.zero,
          ),
          child: Icon(icon, size: 24),
        ),
      );
    }

    return Column(
      children: [
        keyButton(Icons.keyboard_arrow_up_rounded, MoveDirection.up),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            keyButton(Icons.keyboard_arrow_left_rounded, MoveDirection.left),
            const SizedBox(width: 6),
            keyButton(Icons.keyboard_arrow_down_rounded, MoveDirection.down),
            const SizedBox(width: 6),
            keyButton(Icons.keyboard_arrow_right_rounded, MoveDirection.right),
          ],
        ),
      ],
    );
  }
}
