import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// NAI uygulamasının koyu tema paleti. Gemini uygulamasına benzer şekilde
/// derin lacivert/siyah zemin üzerine mor -> mavi -> camgöbeği gradyanlı
/// vurgular kullanılır.
class AppColors {
  static const background = Color(0xFF0B0F19);
  static const surfaceSolid = Color(0xFF121826);
  static const surfaceElevated = Color(0xFF1A2233);
  static const border = Color(0xFF262E42);

  static const textPrimary = Color(0xFFF2F4FA);
  static const textSecondary = Color(0xFFA6AEC4);
  static const textTertiary = Color(0xFF6B7488);

  static const purple = Color(0xFF8A5CF6);
  static const blue = Color(0xFF4F8CFF);
  static const cyan = Color(0xFF38D6D1);

  static const success = Color(0xFF3ED598);
  static const danger = Color(0xFFFF6B6B);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, blue, cyan],
  );

  static const gradientSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x338A5CF6), Color(0x334F8CFF), Color(0x3338D6D1)],
  );
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
        .apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: AppColors.blue,
        secondary: AppColors.cyan,
        tertiary: AppColors.purple,
        surface: AppColors.surfaceSolid,
        error: AppColors.danger,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceSolid,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceSolid,
        indicatorColor: AppColors.blue.withValues(alpha: 0.22),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.textPrimary : AppColors.textTertiary,
          );
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.blue;
          return AppColors.border;
        }),
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
