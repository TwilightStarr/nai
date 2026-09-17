import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../theme/app_theme.dart';
import '../widgets/sparkle_logo.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    Future.delayed(const Duration(milliseconds: 1900), () {
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

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _version = 'v${info.version}');
    } catch (_) {
      // Versiyon okunamazsa sessizce yok say; sadece kozmetik bir bilgi.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SparkleLogo(size: 92)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(
                        begin: 0.95,
                        end: 1.05,
                        duration: 1500.ms,
                        curve: Curves.easeInOut,
                      )
                      .animate()
                      .fadeIn(duration: 550.ms)
                      .scaleXY(begin: 0.7, end: 1, duration: 650.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (bounds) => AppColors.gradient.createShader(bounds),
                    child: Text(
                      'NAI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5,
                        height: 1,
                        color: Colors.white,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 220.ms, duration: 550.ms)
                      .slideY(begin: 0.2, end: 0, delay: 220.ms, duration: 550.ms, curve: Curves.easeOutCubic),
                  const SizedBox(height: 6),
                  Text(
                    'Nevzat Ayaz Anadolu Lisesi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 380.ms, duration: 550.ms)
                      .slideY(begin: 0.2, end: 0, delay: 380.ms, duration: 550.ms, curve: Curves.easeOutCubic),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        height: 3,
                        color: AppColors.border,
                        alignment: Alignment.centerLeft,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 1300),
                          curve: Curves.easeInOutCubic,
                          builder: (context, value, _) => FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              decoration: const BoxDecoration(gradient: AppColors.gradient),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                ],
              ),
            ),
            if (_version.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Center(
                  child: Text(
                    _version,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
