import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';
import '../widgets/sparkle_logo.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, anim, __) => FadeTransition(
            opacity: anim,
            child: const HomeScreen(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SparkleLogo(size: 96)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 0.94,
                  end: 1.06,
                  duration: 1400.ms,
                  curve: Curves.easeInOut,
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .scaleXY(begin: 0.7, end: 1, duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 22),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.gradient.createShader(bounds),
              child: const Text(
                'NAI',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
            const SizedBox(height: 8),
            const Text(
              'Nevzat Ayaz Anadolu Lisesi',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 350.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
