import 'package:flutter/material.dart';

/// Spacing scale. Screens use these instead of number literals.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

/// Corner radii from the Figma file.
class AppRadius {
  static const double card = 16;
  static const double button = 12;
  static const double image = 12;
}

/// Set this to the Figma font family if you added the font as an asset.
/// null = the platform default font.
const String? _fontFamily = null;

ThemeData buildTheme() {
  // TODO: replace with the primary colour from the Figma file.
  const seed = Color(0xFF0F8B7D);

  final scheme = ColorScheme.fromSeed(seedColor: seed);
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: _fontFamily,
  );

  // TODO: replace sizes and weights with the Figma text styles.
  final t = base.textTheme;
  final textTheme = t.copyWith(
    headlineMedium:
        t.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
    titleLarge:
        t.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium:
        t.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
    bodyLarge: t.bodyLarge?.copyWith(fontSize: 16),
    bodyMedium: t.bodyMedium?.copyWith(fontSize: 14),
    bodySmall: t.bodySmall?.copyWith(fontSize: 12),
    labelLarge:
        t.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
  );

  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.button),
  );

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      titleTextStyle:
          textTheme.titleLarge?.copyWith(color: scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: buttonShape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: buttonShape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide.none,
      backgroundColor: scheme.secondaryContainer,
      labelStyle:
          textTheme.labelLarge?.copyWith(color: scheme.onSecondaryContainer),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStatePropertyAll(textTheme.bodySmall),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
    ),
  );
}