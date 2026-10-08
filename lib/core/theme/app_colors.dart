import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand & Fintech Core
  static const primary = Color(0xFF0A2540); // Deep Trust Navy
  static const primaryDark = Color(0xFF38BDF8); // Electric Sky
  static const primaryEmerald = Color(0xFF059669); // Growth Emerald
  static const accentGold = Color(0xFFD97706); // Platinum/Gold Tier

  // Semantic Status
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF2563EB);

  // Scanner Viewfinder
  static const scannerBackground = Color(0xFF050811);
  static const scannerForeground = Color(0xFFFFFFFF);
  static const scannerOverlay = Color(0xAA000000);

  // Financial Analytics Palette
  static const chartPalette = <Color>[
    Color(0xFF059669), // Emerald
    Color(0xFF2563EB), // Blue
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
  ];

  // Category Pastel Containers (Light mode)
  static const categoryFoodBg = Color(0xFFFFF7ED);
  static const categoryFoodIcon = Color(0xFFEA580C);
  static const categoryStudyBg = Color(0xFFEFF6FF);
  static const categoryStudyIcon = Color(0xFF2563EB);
  static const categoryTravelBg = Color(0xFFF0FDF4);
  static const categoryTravelIcon = Color(0xFF059669);
  static const categoryGearBg = Color(0xFFF5F3FF);
  static const categoryGearIcon = Color(0xFF7C3AED);
  static const categoryEntertainmentBg = Color(0xFFFDF2F8);
  static const categoryEntertainmentIcon = Color(0xFFDB2777);

  // Light Banking Surfaces
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF0F172A);
  static const lightMuted = Color(0xFF64748B);
  static const lightOutline = Color(0xFFE2E8F0);
  static const lightSubtle = Color(0xFFF1F5F9);

  // Dark Banking Surfaces (Obsidian Midnight)
  static const darkBackground = Color(0xFF080C15);
  static const darkSurface = Color(0xFF111827);
  static const darkCard = Color(0xFF151F32);
  static const darkText = Color(0xFFF8FAFC);
  static const darkMuted = Color(0xFF94A3B8);
  static const darkOutline = Color(0xFF1E293B);
  static const darkSubtle = Color(0xFF1E293B);

  // Hero Card Gradients
  static const bankCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A192F),
      Color(0xFF1E3A8A),
      Color(0xFF0F172A),
    ],
  );

  static const bankCardGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1F2937),
      Color(0xFF374151),
    ],
  );
}
