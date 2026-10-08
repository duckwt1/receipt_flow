import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const _family = 'Roboto';

  static const textTheme = TextTheme(
    headlineMedium: TextStyle(fontFamily: _family, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.8),
    headlineSmall: TextStyle(fontFamily: _family, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
    titleLarge: TextStyle(fontFamily: _family, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.2),
    titleMedium: TextStyle(fontFamily: _family, fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontFamily: _family, fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontFamily: _family, fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(fontFamily: _family, fontSize: 12, fontWeight: FontWeight.w500),
  );
}
