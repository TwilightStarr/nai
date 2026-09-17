import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Uygulamanın özgün "N" (Nevzat) monogram logosunu vektörel olarak çizen
/// widget. Splash ekranı, ana ekran başlığı ve boş liste durumunda kullanılır.
///
/// Not: Önceki sürümde burada Google Gemini ikonuna çok benzeyen 4 uçlu bir
/// "kıvılcım" şekli vardı; marka karışıklığını önlemek için okulun adından
/// gelen özgün bir harf monogramıyla değiştirildi (bkz. tools/make_icon.py).
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
        painter: _NMarkPainter(glow: glow),
      ),
    );
  }
}

class _NMarkPainter extends CustomPainter {
  _NMarkPainter({required this.glow});
  final bool glow;

  Path _nMarkPath(Size size) {
    final boxH = size.shortestSide * 0.64;
    final boxW = boxH * 0.82;
    final x0 = (size.width - boxW) / 2;
    final y0 = (size.height - boxH) / 2;
    final barW = boxW * 0.34;
    final radius = barW * 0.30;

    final bars = Path()
      ..addRRect(
        RRect.fromLTRBR(x0, y0, x0 + barW, y0 + boxH, Radius.circular(radius)),
      )
      ..addRRect(
        RRect.fromLTRBR(
          x0 + boxW - barW,
          y0,
          x0 + boxW,
          y0 + boxH,
          Radius.circular(radius),
        ),
      );

    // Sol gövdenin tepesinden sağ gövdenin tabanına inen diyagonal kesit.
    final top = Offset(x0 + barW / 2, y0);
    final bottom = Offset(x0 + boxW - barW / 2, y0 + boxH);
    final dir = bottom - top;
    final perp = Offset(-dir.dy, dir.dx) / dir.distance;
    final half = barW * 0.94 / 2;
    final diagonal = Path()
      ..moveTo(top.dx + perp.dx * half, top.dy + perp.dy * half)
      ..lineTo(top.dx - perp.dx * half, top.dy - perp.dy * half)
      ..lineTo(bottom.dx - perp.dx * half, bottom.dy - perp.dy * half)
      ..lineTo(bottom.dx + perp.dx * half, bottom.dy + perp.dy * half)
      ..close();

    // Döndürülmüş diyagonalin köşeleri harfin kutusunun az dışına taşabilir;
    // temiz bir kenar için harfin sınır kutusuyla kesişimini al.
    final bounds = Path()..addRect(Rect.fromLTWH(x0, y0, boxW, boxH));
    final clippedDiagonal =
        Path.combine(PathOperation.intersect, diagonal, bounds);

    return Path.combine(PathOperation.union, bars, clippedDiagonal);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _nMarkPath(size);
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
  bool shouldRepaint(covariant _NMarkPainter oldDelegate) => false;
}
