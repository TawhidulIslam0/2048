import 'package:flutter/material.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({
    super.key,
    required this.board,
    required this.onSwipe,
  });

  final List<List<int>> board;
  final ValueChanged<Offset> onSwipe;

  static const _tileColors = <int, Color>{
    0: Color(0xFFCDC1B4),
    2: Color(0xFFEEE4DA),
    4: Color(0xFFEDE0C8),
    8: Color(0xFFF2B179),
    16: Color(0xFFF59563),
    32: Color(0xFFF67C5F),
    64: Color(0xFFF65E3B),
    128: Color(0xFFEDCF72),
    256: Color(0xFFEDCC61),
    512: Color(0xFFEDC850),
    1024: Color(0xFFEDC53F),
    2048: Color(0xFFEDC22E),
  };

  Color _colorFor(int value) {
    if (_tileColors.containsKey(value)) return _tileColors[value]!;
    return const Color(0xFF3C3A32);
  }

  Color _textColor(int value) =>
      value <= 4 ? const Color(0xFF776E65) : Colors.white;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth;
        final gap = side * 0.025;
        final inset = side * 0.025;
        return GestureDetector(
          onPanEnd: (details) {
            final velocity = details.velocity.pixelsPerSecond;
            if (velocity.distance < 100) return;
            onSwipe(Offset(velocity.dx, velocity.dy));
          },
          child: Container(
            width: side,
            height: side,
            padding: EdgeInsets.all(inset),
            decoration: BoxDecoration(
              color: const Color(0xFFBBADA0),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F776E65),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: List.generate(4, (r) {
                return Expanded(
                  child: Row(
                    children: List.generate(4, (c) {
                      final value = board[r][c];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(gap / 2),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 125),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              color: _colorFor(value),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 100),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(scale: animation, child: child),
                                child: value == 0
                                    ? const SizedBox.expand()
                                    : FittedBox(
                                        key: ValueKey('$r-$c-$value'),
                                        fit: BoxFit.scaleDown,
                                        child: Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: Text(
                                            '$value',
                                            style: TextStyle(
                                              color: _textColor(value),
                                              fontSize: value >= 1024 ? 25 : value >= 128 ? 29 : 34,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
