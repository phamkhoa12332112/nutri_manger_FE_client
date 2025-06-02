import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:vector_math/vector_math_64.dart' as math;

class RadioProgress extends StatelessWidget {
  final double number;
  final double height;
  final double width;
  final double progress;

  const RadioProgress({
    super.key,
    required this.height,
    required this.width,
    required this.progress,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadialPainter(progress: progress),
      child: Container(
        height: height,
        width: width,
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$number',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF200087),
                  ),
                ),
                TextSpan(text: '\n'),
                TextSpan(
                  text: 'kcal left',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF200087),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadialPainter extends CustomPainter {
  final double progress;

  _RadialPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeWidth = 10
          ..color = progress >= 1 ? Colors.red : Colors.green
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;
    double relativeProgress = 360 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.radians(-90),
      math.radians(-relativeProgress),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
