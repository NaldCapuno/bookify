import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2500), // DURATION
  );

  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacementNamed('/home'); // REDIRECT
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _controller.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BookeepayPainter(_animation),
      size: const Size(300, 250),
    );
  }
}

class BookeepayPainter extends CustomPainter {
  BookeepayPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final double p = animation.value;

    final double barsP = (p / 0.45).clamp(0.0, 1.0);
    final double lineP = ((p - 0.35) / 0.40).clamp(0.0, 1.0);
    final double textP = ((p - 0.65) / 0.35).clamp(0.0, 1.0);

    final Color barColor = const Color(0xFF2DD4BF);
    final Color accentColor = const Color(0xFFFBBF24);
    final Color textColor = Colors.white;

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: 'bookee',
      style: TextStyle(
        fontSize: 46,
        fontWeight: FontWeight.w800,
        color: textColor.withValues(alpha: textP),
        letterSpacing: -1.5,
        fontFamily: 'sans-serif',
      ),
      children: [
        TextSpan(
          text: 'pay',
          style: TextStyle(color: accentColor.withValues(alpha: textP)),
        ),
      ],
    );
    textPainter.layout();

    final double totalWidth = max(180.0, textPainter.size.width);
    const double chartHeight = 120.0;
    const double totalHeight = chartHeight + 60.0;

    canvas.translate(
      (size.width - totalWidth) / 2,
      (size.height - totalHeight) / 2,
    );

    final List<double> targetHeights = [40.0, 75.0, 120.0];
    const double barWidth = 35.0;
    const double spacing = 20.0;
    final double chartStartX = (totalWidth - (barWidth * 3 + spacing * 2)) / 2;

    final Paint barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final double staggerStart = i * 0.2;
      final double individualP = ((barsP - staggerStart) / 0.6).clamp(0.0, 1.0);
      final double easeP = Curves.easeOutBack.transform(individualP);

      final double x = chartStartX + i * (barWidth + spacing);
      final double height = targetHeights[i] * easeP;

      if (height > 0) {
        final RRect barRect = RRect.fromLTRBR(
          x,
          chartHeight - height,
          x + barWidth,
          chartHeight,
          const Radius.circular(8),
        );
        canvas.drawRRect(barRect, barPaint);
      }
    }

    if (lineP > 0) {
      final Paint linePaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final List<Offset> points = [];
      for (int i = 0; i < 3; i++) {
        final double x = chartStartX + i * (barWidth + spacing) + barWidth / 2;
        final double y = chartHeight - targetHeights[i] - 15.0;
        points.add(Offset(x, y));
      }

      final Path animatedPath = Path();
      animatedPath.moveTo(points[0].dx, points[0].dy);

      if (lineP <= 0.5) {
        final double segmentP = lineP / 0.5;
        final double currentX =
            points[0].dx + (points[1].dx - points[0].dx) * segmentP;
        final double currentY =
            points[0].dy + (points[1].dy - points[0].dy) * segmentP;
        animatedPath.lineTo(currentX, currentY);
      } else {
        animatedPath.lineTo(points[1].dx, points[1].dy);
        final double segmentP = (lineP - 0.5) / 0.5;
        final double currentX =
            points[1].dx + (points[2].dx - points[1].dx) * segmentP;
        final double currentY =
            points[1].dy + (points[2].dy - points[1].dy) * segmentP;
        animatedPath.lineTo(currentX, currentY);

        if (lineP > 0.8) {
          final double arrowP = ((lineP - 0.8) / 0.2).clamp(0.0, 1.0);
          final double angle = atan2(
            points[2].dy - points[1].dy,
            points[2].dx - points[1].dx,
          );
          final double arrowLength = 14.0 * arrowP;
          const double arrowAngle = pi / 5;

          final Path arrowPath = Path()
            ..moveTo(currentX, currentY)
            ..lineTo(
              currentX - arrowLength * cos(angle - arrowAngle),
              currentY - arrowLength * sin(angle - arrowAngle),
            )
            ..moveTo(currentX, currentY)
            ..lineTo(
              currentX - arrowLength * cos(angle + arrowAngle),
              currentY - arrowLength * sin(angle + arrowAngle),
            );
          canvas.drawPath(arrowPath, linePaint);
        }
      }
      canvas.drawPath(animatedPath, linePaint);
    }

    if (textP > 0) {
      final double textX = (totalWidth - textPainter.size.width) / 2;
      final double textY = chartHeight + 25.0 + (15.0 * (1 - textP));
      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
