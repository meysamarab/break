import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameConstants {
  static TextStyle get neonTextFont => GoogleFonts.outfit(fontWeight: FontWeight.bold);

  // Theme Colors
  static const Color bgDeepPurple = Color(0xFF1A0033);
  static const Color bgNebula = Color(0xFF2D1B4A);
  
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonMagenta = Color(0xFFFF00FF);
  static const Color neonBlue = Color(0xFF0000FF);
  static const Color neonLime = Color(0xFF32CD32);
  static const Color neonOrange = Color(0xFFFF8C00);
  static const Color neonGold = Color(0xFFFFD700);

  // Gameplay Settings
  static const double ballRadius = 0.6;
  static const double paddleWidth = 5.0;
  static const double paddleHeight = 0.8;
  static const double brickWidth = 3.5;
  static const double brickHeight = 1.2;
  static const double brickPadding = 0.2;

  // Physics
  static const double ballSpeedCap = 120.0;
  static const double ballInitialSpeed = 60.0;
}
