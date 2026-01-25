import 'package:flutter/material.dart';

class MilitaryTheme {
  // =====================================================
  // 🎖 Official Military Sand Theme (سكري رسمي)
  // =====================================================

  /// الخلفية الرئيسية
  static const Color sand = Color(0xFFD8C9A3);

  /// درجة أغمق للسكري (AppBar + NavBar)
  static const Color sandDark = Color(0xFFC2B48A);

  /// لون الكروت (بطاقات سكري فاتح)
  static const Color card = Color(0xFFE6D9B8);

  /// لون الحدود
  static const Color border = Color(0xFF6B5E3B);

  /// اللون الأساسي (أخضر عسكري)
  static const Color accent = Color(0xFF4CAF50);

  // =====================================================
  // ✅ Global ThemeData
  // =====================================================
  static final ThemeData theme = ThemeData(
    useMaterial3: true,

    // ✅ خط عربي احترافي
    fontFamily: "Cairo",

    scaffoldBackgroundColor: sand,

    // ================= AppBar =================
    appBarTheme: const AppBarTheme(
      backgroundColor: sandDark,
      foregroundColor: Colors.black,
      centerTitle: true,
      elevation: 4,
    ),

    // ================= Bottom Navigation =================
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: sandDark,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
    ),

    // ================= Cards =================
    cardTheme: CardThemeData(
      color: card,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    // ================= Buttons =================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 18,
        ),
      ),
    ),

    // ================= Inputs =================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: border.withValues(alpha: 0.4),
        ),
      ),
    ),

    // ================= Text Theme =================
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontSize: 15,
        color: Colors.black,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  );
}
