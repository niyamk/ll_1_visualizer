import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── PALETTE ───────────────────────────────────────────────────────────────
  static const primary      = Color(0xFF1A56DB); // strong blue
  static const primaryLight = Color(0xFFEBF0FF);
  static const accent       = Color(0xFF0E9F6E); // green for success
  static const error        = Color(0xFFE02424); // red for errors
  static const warning      = Color(0xFFFF8A00); // orange for conflicts
  static const surface      = Color(0xFFF9FAFB);
  static const cardBg       = Color(0xFFFFFFFF);
  static const border       = Color(0xFFE5E7EB);
  static const textPrimary  = Color(0xFF111928);
  static const textSecond   = Color(0xFF6B7280);
  static const highlight    = Color(0xFFFFF3CD); // yellow for apply steps
  static const matchGreen   = Color(0xFFDEF7EC);
  static const errorRed     = Color(0xFFFDE8E8);
  static const applyBlue    = Color(0xFFEBF0FF);

  // ── THEME ─────────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: surface,
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.jetBrainsMono(
        fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: cardBg,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      surfaceTintColor: Colors.transparent,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primary,
      unselectedLabelColor: textSecond,
      indicatorColor: primary,
      labelStyle: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w500,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: border),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(color: border, thickness: 1),
  );
}