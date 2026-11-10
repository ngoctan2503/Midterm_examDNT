import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Nền gradient chuyển động nhẹ + vài vòng tròn mờ.
class GradientBackground extends StatefulWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 10))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = Curves.easeInOut.transform(_c.value);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + t, -1),
              end: Alignment(1 - t, 1),
              colors: const [
                Color(0xFF0B4F4A),
                Color(0xFF0F766E),
                Color(0xFF10B981)
              ],
            ),
          ),
          child: Stack(children: [
            Positioned(
                top: -80 + 40 * math.sin(t * math.pi),
                left: -60,
                child: _blob(260, 0.12)),
            Positioned(
                bottom: -100, right: -40 + 50 * t, child: _blob(320, 0.10)),
            child!,
          ]),
        );
      },
      child: widget.child,
    );
  }

  Widget _blob(double s, double a) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.white.withValues(alpha: a)),
      );
}
