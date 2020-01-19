// Copyright 2020 George Levin D'souza. All rights reserved.
// Use of this source code is governed by a Apache-2.0 license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WhirlyHand extends StatelessWidget {
  WhirlyHand({
    @required this.handSize,
    @required this.lineWidth,
    @required this.startAngle,
    @required this.sweepAngle,
    @required this.color,
  });

  final double handSize;
  final double lineWidth;
  final double startAngle;
  final double sweepAngle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _WhirlyPainter(
            color: color,
            startAngle: startAngle,
            sweepAngle: sweepAngle,
            handSize: handSize,
            lineWidth: lineWidth,
          ),
        ),
      ),
    );
  }
}

class _WhirlyPainter extends CustomPainter {
  _WhirlyPainter({
    @required this.handSize,
    @required this.lineWidth,
    @required this.startAngle,
    @required this.sweepAngle,
    @required this.color,
  });

  double handSize;
  double lineWidth;
  double startAngle;
  double sweepAngle;
  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeCap;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.shortestSide * 0.5 * handSize,
    );
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(_WhirlyPainter oldDelegate) {
    return oldDelegate.handSize != handSize ||
        oldDelegate.lineWidth != lineWidth ||
        oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.color != color;
  }
}
