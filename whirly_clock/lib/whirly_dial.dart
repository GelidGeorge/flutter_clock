import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

class WhirlyDial extends StatelessWidget {
  WhirlyDial({
    @required this.isNose,
    @required this.lineWidth,
    @required this.handSize,
    @required this.color,
  });

  final bool isNose;
  final double lineWidth;
  final double handSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _DialPainter(
            isNose: isNose,
            lineWidth: lineWidth,
            handSize: handSize,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    @required this.isNose,
    @required this.lineWidth,
    @required this.handSize,
    @required this.color,
  });

  final bool isNose;
  final double lineWidth;
  final double handSize;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final paint2 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * lineWidth
      ..strokeCap = StrokeCap.round;
    final paint3 = Paint()
      ..color = Colors.blueGrey[800]
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * lineWidth / 2
      ..strokeCap = StrokeCap.round;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.shortestSide * 0.5 * handSize,
    );
    final rect2 = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.shortestSide * 0.45 * handSize,
    );
    canvas.drawArc(
      rect,
      radians(270),
      radians(360),
      true,
      paint,
    );
    if (isNose) {
      for (int i = 0; i < 12; i++) {
        canvas.drawArc(
          rect2,
          radians((i * 30).toDouble()),
          radians(2),
          false,
          ((i % 3) == 0) ? paint2 : paint3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) {
    return false;
  }
}
