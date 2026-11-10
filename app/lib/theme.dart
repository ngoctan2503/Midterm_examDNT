import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const teal = Color(0xFF0F766E);
  static const emerald = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const tealDark = Color(0xFF0B3B38);
  static const bgLight = Color(0xFFF4FBF9);
  static const bgDark = Color(0xFF0B1715);
  static const surfaceDark = Color(0xFF12241F);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, emerald],
  );
}

class AppTheme {
  static TextStyle? _f(TextStyle? s) => GoogleFonts.nunito(textStyle: s);

  static TextTheme _font(TextTheme t) => TextTheme(
        displayLarge: _f(t.displayLarge),
        displayMedium: _f(t.displayMedium),
        displaySmall: _f(t.displaySmall),
        headlineLarge: _f(t.headlineLarge),
        headlineMedium: _f(t.headlineMedium),
        headlineSmall: _f(t.headlineSmall),
        titleLarge: _f(t.titleLarge),
        titleMedium: _f(t.titleMedium),
        titleSmall: _f(t.titleSmall),
        bodyLarge: _f(t.bodyLarge),
        bodyMedium: _f(t.bodyMedium),
        bodySmall: _f(t.bodySmall),
        labelLarge: _f(t.labelLarge),
        labelMedium: _f(t.labelMedium),
        labelSmall: _f(t.labelSmall),
      );

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      brightness: b,
    ).copyWith(
      primary: dark ? const Color(0xFF5EEAD4) : AppColors.teal,
      onPrimary: dark ? const Color(0xFF042F2E) : Colors.white,
      secondary: AppColors.emerald,
      tertiary: AppColors.amber,
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final text = _font(base.textTheme);
    final surface = dark ? AppColors.surfaceDark : Colors.white;
    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: dark ? AppColors.bgDark : AppColors.bgLight,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge
            ?.copyWith(fontWeight: FontWeight.w800, color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.6))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.primary, width: 1.8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: scheme.primaryContainer,
      ),
    );
  }

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);
}
