import 'package:flutter/material.dart';

/// Central FoodLink color palette.
///
/// Colors are chosen so that text and meaningful UI meet WCAG AA contrast
/// ratios (>= 4.5:1 for normal text, >= 3:1 for large text / components):
/// - `primaryGreen` as a button fill pairs with white text at ~5:1, and as
///   text on light surfaces it also clears 4.5:1.
/// - `secondaryText` is dark enough to stay readable on both `white` and
///   `warmBackground` (never a pale gray on white).
/// - `warningAmber` and `errorRed` are deep enough to be used as text and
///   icons, never relying on color alone (callers also show text labels).
class AppColors {
  static const Color primaryGreen = Color(0xFF15803D);
  static const Color darkGreen = Color(0xFF0F5C2E);
  static const Color lightGreen = Color(0xFFE8F5EC);
  static const Color warmBackground = Color(0xFFF6F8F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF1E2620);
  static const Color secondaryText = Color(0xFF566057);
  static const Color border = Color(0xFFE1E8E1);
  static const Color warningAmber = Color(0xFFB45309);
  static const Color lightAmber = Color(0xFFFDF3E6);
  static const Color softBlue = Color(0xFFEAF2FB);
  static const Color softRed = Color(0xFFFBE9E7);
  static const Color errorRed = Color(0xFFC0392B);
}
