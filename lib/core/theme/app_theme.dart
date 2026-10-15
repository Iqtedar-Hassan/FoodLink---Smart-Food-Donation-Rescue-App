import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Central theme: spacing scale, corner radii, a complete typographic scale,
/// responsive breakpoints, and shared component styling.
///
/// All screens read their spacing, radii, colors, and text styles from here so
/// the whole app feels like one product.
class AppTheme {
  AppTheme._();

  // --- Spacing scale (use these instead of arbitrary per-screen margins) ---
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 20;
  static const double space2xl = 24;
  static const double space3xl = 32;

  // Retained aliases used across existing screens.
  static const double pagePadding = spaceXl;
  static const double cardPadding = spaceLg;
  static const double cardRadius = 16;
  static const double compactRadius = 12;
  static const double sectionGap = space2xl;
  static const double itemGap = spaceMd;

  static const double buttonHeight = 52;
  static const double fieldMinHeight = 56;

  // --- Responsive breakpoints (logical width based, not device names) ---
  static const double compactPhoneMax = 360;
  static const double tabletMin = 600;
  static const double largeTabletMin = 900;

  /// The maximum content width that body screens constrain themselves to so
  /// forms and text never stretch across a large tablet.
  static double contentMaxWidth(double width) =>
      width < tabletMin ? width : 640;

  /// Maximum width for authentication forms. Phones use nearly the full width
  /// with a comfortable margin; tablets keep a readable centered column.
  static double authFormMaxWidth(double width) {
    final margin = horizontalMargin(width);
    final available = width - margin * 2;
    return available < 460 ? available : 460;
  }

  /// Horizontal page margin. Comfortable but not wasteful on very narrow
  /// phones (kept at 16 from ~320px up).
  static double horizontalMargin(double width) => width < 360 ? 16 : 20;

  /// Number of dashboard summary columns for a given available width.
  static int summaryColumns(double width) {
    if (width < compactPhoneMax) return 2;
    if (width < tabletMin) return 2;
    if (width < largeTabletMin) return 4;
    return 4;
  }

  static bool isPhoneWidth(double width) => width < tabletMin;

  // Legacy helpers kept for compatibility.
  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletMin;

  static double maxContentWidth(BuildContext context) =>
      contentMaxWidth(MediaQuery.sizeOf(context).width);

  static const TextTheme _textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 30,
      height: 1.2,
      fontWeight: FontWeight.w800,
      color: AppColors.primaryText,
    ),
    headlineMedium: TextStyle(
      fontSize: 25,
      height: 1.25,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryText,
    ),
    headlineSmall: TextStyle(
      fontSize: 21,
      height: 1.3,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryText,
    ),
    titleLarge: TextStyle(
      fontSize: 19,
      height: 1.3,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryText,
    ),
    titleMedium: TextStyle(
      fontSize: 16.5,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryText,
    ),
    titleSmall: TextStyle(
      fontSize: 14.5,
      height: 1.35,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryText,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
      color: AppColors.primaryText,
    ),
    bodyMedium: TextStyle(
      fontSize: 14.5,
      height: 1.5,
      color: AppColors.primaryText,
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      height: 1.45,
      color: AppColors.secondaryText,
    ),
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryText,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryText,
    ),
    labelSmall: TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      color: AppColors.secondaryText,
    ),
  );

  static ThemeData get lightTheme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          secondary: AppColors.darkGreen,
          surface: AppColors.white,
          brightness: Brightness.light,
        ).copyWith(
          secondaryContainer: AppColors.lightGreen,
          onSecondaryContainer: AppColors.darkGreen,
          error: AppColors.errorRed,
        );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.warmBackground,
      colorScheme: colorScheme,
      textTheme: _textTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.warmBackground,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceLg,
          vertical: spaceLg,
        ),
        labelStyle: const TextStyle(
          color: AppColors.secondaryText,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.darkGreen,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: AppColors.secondaryText),
        helperStyle: const TextStyle(
          color: AppColors.secondaryText,
          height: 1.3,
        ),
        errorStyle: const TextStyle(
          color: AppColors.errorRed,
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compactRadius),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compactRadius),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compactRadius),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compactRadius),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compactRadius),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compactRadius),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.lightGreen,
          disabledForegroundColor: AppColors.secondaryText,
          minimumSize: const Size.fromHeight(buttonHeight),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(compactRadius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
          minimumSize: const Size.fromHeight(buttonHeight),
          side: const BorderSide(color: AppColors.border, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(compactRadius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkGreen,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.lightGreen,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.darkGreen : AppColors.secondaryText,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? AppColors.darkGreen : AppColors.secondaryText,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.white,
        selectedColor: AppColors.lightGreen,
        side: const BorderSide(color: AppColors.border),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
        secondaryLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreen,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 15,
          height: 1.45,
          color: AppColors.primaryText,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryText,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: AppColors.lightGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(compactRadius),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGreen;
          }
          return AppColors.white;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: const BorderSide(color: AppColors.border, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryGreen,
      ),
    );
  }
}
