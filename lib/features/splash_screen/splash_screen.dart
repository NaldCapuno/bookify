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
    duration: const Duration(milliseconds: 2500),
  );

  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacementNamed('/home');
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
        child: CustomPaint(
          painter: TsekBooksPainter(_animation),
          size: const Size(300, 250),
        ),
        ),
      ),
    );
  }
}

class TsekBooksPainter extends CustomPainter {
  TsekBooksPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final double p = animation.value;

    // Animation phases
    final double barsP = (p / 0.45).clamp(0.0, 1.0);
    final double lineP = ((p - 0.35) / 0.40).clamp(
      0.0,
      1.0,
    ); // Now controls the checkmark
    final double textP = ((p - 0.65) / 0.35).clamp(0.0, 1.0);

    final Color barColor = const Color(0xFF2DD4BF);
    final Color accentColor = const Color(0xFFFBBF24);
    final Color textColor = Colors.white;

    // --- Text Configuration ---
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: 'Tsek',
      style: TextStyle(
        fontSize: 46,
        fontWeight: FontWeight.w800,
        color: textColor.withValues(alpha: textP),
        letterSpacing: -1.5,
        fontFamily: 'sans-serif',
      ),
      children: [
        TextSpan(
          text: 'Books',
          style: TextStyle(color: accentColor.withValues(alpha: textP)),
        ),
      ],
    );
    textPainter.layout();

    final double totalWidth = max(180.0, textPainter.size.width);
    const double chartHeight = 120.0;
    const double totalHeight = chartHeight + 60.0;

    // Center the whole drawing
    canvas.translate(
      (size.width - totalWidth) / 2,
      (size.height - totalHeight) / 2,
    );

    // --- Bar Chart (The "Books") ---
    final List<double> targetHeights = [40.0, 75.0, 100.0];
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

    // --- Checkmark (The "Tsek") ---
    if (lineP > 0) {
      final Paint checkPaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            8.0 // Thicker stroke for a bold checkmark
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Define the three points of the checkmark
      final Offset p0 = Offset(chartStartX - 5, chartHeight - 55); // Left start
      final Offset p1 = Offset(
        chartStartX + barWidth + spacing / 2,
        chartHeight - 10,
      ); // Bottom dip
      final Offset p2 = Offset(
        chartStartX + barWidth * 3 + spacing * 2 + 5,
        chartHeight - 110,
      ); // Top right finish

      final Path animatedPath = Path();
      animatedPath.moveTo(p0.dx, p0.dy);

      if (lineP <= 0.35) {
        // Draw the short, downward stroke of the checkmark
        final double segmentP = lineP / 0.35;
        animatedPath.lineTo(
          p0.dx + (p1.dx - p0.dx) * segmentP,
          p0.dy + (p1.dy - p0.dy) * segmentP,
        );
      } else {
        // Finish the short stroke, then draw the long, upward stroke
        animatedPath.lineTo(p1.dx, p1.dy);
        final double segmentP = (lineP - 0.35) / 0.65;
        animatedPath.lineTo(
          p1.dx + (p2.dx - p1.dx) * segmentP,
          p1.dy + (p2.dy - p1.dy) * segmentP,
        );
      }

      canvas.drawPath(animatedPath, checkPaint);
    }

    // --- Title Text ---
    if (textP > 0) {
      final double textX = (totalWidth - textPainter.size.width) / 2;
      final double textY = chartHeight + 25.0 + (15.0 * (1 - textP));
      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
