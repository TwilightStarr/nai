import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Uygulama logosuyla aynı 4 uçlu "kıvılcım" formunu vektörel olarak çizen
/// widget. Splash ekranı ve uygulama içi başlıklarda kullanılır.
class SparkleLogo extends StatelessWidget {
  const SparkleLogo({super.key, this.size = 72, this.glow = true});

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SparklePainter(glow: glow),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter({required this.glow});
  final bool glow;

  Path _sparklePath(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rOuter = size.shortestSide / 2 * 0.86;
    final rCtrl = rOuter * 0.16;

    final tipAngles = [-math.pi / 2, 0.0, math.pi / 2, math.pi];
    final ctrlAngles = [-math.pi / 4, math.pi / 4, 3 * math.pi / 4, -3 * math.pi / 4];

    Offset pt(double r, double a) => Offset(cx + r * math.cos(a), cy + r * math.sin(a));

    final tips = tipAngles.map((a) => pt(rOuter, a)).toList();
    final ctrls = ctrlAngles.map((a) => pt(rCtrl, a)).toList();

    final path = Path()..moveTo(tips[0].dx, tips[0].dy);
    for (var i = 0; i < tips.length; i++) {
      final next = tips[(i + 1) % tips.length];
      path.quadraticBezierTo(ctrls[i].dx, ctrls[i].dy, next.dx, next.dy);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _sparklePath(size);
    final shader = AppColors.gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    if (glow) {
      final glowPaint = Paint()
        ..shader = shader
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.width * 0.12)
        ..color = Colors.white.withValues(alpha: 0.55);
      canvas.drawPath(path, glowPaint);
    }

    final paint = Paint()..shader = shader;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => false;
}
