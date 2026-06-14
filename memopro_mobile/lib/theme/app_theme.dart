import 'package:flutter/material.dart';

class AppTheme {
  static const Color accent = Color(0xFF007AFF);
  static const Color accentDark = Color(0xFF0A84FF);
  static const Color danger = Color(0xFFFF3B30);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: accent,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF2F2F7),
          foregroundColor: Color(0xFF1C1C1E),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF1C1C1E),
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF2F2F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(color: Color(0xFFC7C7CC), fontSize: 16),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dividerColor: const Color(0xFFE5E5EA),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: accentDark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000000),
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1C1C1E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentDark,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1C1C1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accentDark, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: const TextStyle(color: Color(0xFF636366), fontSize: 16),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        dividerColor: const Color(0xFF38383A),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );

  // 帮助方法：根据亮暗模式获取颜色
  static Color bg(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color cardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF1C1C1E);

  static Color textMain(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? const Color(0xFF1C1C1E)
          : Colors.white;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? const Color(0xFF8E8E93)
          : const Color(0xFF98989D);

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFE5E5EA)
          : const Color(0xFF38383A);

  static Color accentColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? accent : accentDark;
}
