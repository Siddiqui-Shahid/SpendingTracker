import 'package:flutter/material.dart';

/// Stitch / ZenSpend M3 color tokens from the active design project.
abstract final class StitchColors {
  static const Color seed = Color(0xFFD0BCFF);

  // ── Dark scheme (Stitch named colors) ─────────────────────────────────────

  static const Color darkBackground = Color(0xFF141317);
  static const Color darkSurface = Color(0xFF141317);
  static const Color darkSurfaceDim = Color(0xFF141317);
  static const Color darkSurfaceBright = Color(0xFF3A383D);
  static const Color darkSurfaceContainerLowest = Color(0xFF0E0E11);
  static const Color darkSurfaceContainerLow = Color(0xFF1C1B1F);
  static const Color darkSurfaceContainer = Color(0xFF201F23);
  static const Color darkSurfaceContainerHigh = Color(0xFF2B292D);
  static const Color darkSurfaceContainerHighest = Color(0xFF353438);
  static const Color darkSurfaceVariant = Color(0xFF353438);

  static const Color darkPrimary = Color(0xFFE9DDFF);
  static const Color darkOnPrimary = Color(0xFF37265E);
  static const Color darkPrimaryContainer = Color(0xFFD0BCFF);
  static const Color darkOnPrimaryContainer = Color(0xFF594983);

  static const Color darkSecondary = Color(0xFFCCC2DC);
  static const Color darkOnSecondary = Color(0xFF332D41);
  static const Color darkSecondaryContainer = Color(0xFF4A4359);
  static const Color darkOnSecondaryContainer = Color(0xFFBAB1CA);

  static const Color darkTertiary = Color(0xFFC0F0A9);
  static const Color darkOnTertiary = Color(0xFF123806);
  static const Color darkTertiaryContainer = Color(0xFFA5D390);
  static const Color darkOnTertiaryContainer = Color(0xFF345C26);

  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color darkOnSurface = Color(0xFFE5E1E7);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkOutline = Color(0xFF948F9A);
  static const Color darkOutlineVariant = Color(0xFF49454F);

  static const Color darkInverseSurface = Color(0xFFE5E1E7);
  static const Color darkInverseOnSurface = Color(0xFF313034);
  static const Color darkInversePrimary = Color(0xFF665590);
  static const Color darkSurfaceTint = Color(0xFFD0BCFF);

  // ── Light scheme (harmonized with Stitch seed) ────────────────────────────

  static const Color lightBackground = Color(0xFFFFFBFE);
  static const Color lightSurface = Color(0xFFFFFBFE);
  static const Color lightSurfaceDim = Color(0xFFDDD8E5);
  static const Color lightSurfaceBright = Color(0xFFFFFBFE);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF7F2FA);
  static const Color lightSurfaceContainer = Color(0xFFF3EDF7);
  static const Color lightSurfaceContainerHigh = Color(0xFFECE6F0);
  static const Color lightSurfaceContainerHighest = Color(0xFFE6E0E9);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);

  static const Color lightPrimary = Color(0xFF665590);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFE9DDFF);
  static const Color lightOnPrimaryContainer = Color(0xFF4D3D76);

  static const Color lightSecondary = Color(0xFF625B71);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFE8DEF8);
  static const Color lightOnSecondaryContainer = Color(0xFF4A4359);

  static const Color lightTertiary = Color(0xFF386A20);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFC0F0A9);
  static const Color lightOnTertiaryContainer = Color(0xFF29501B);

  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF93000A);

  static const Color lightOnSurface = Color(0xFF1D1B20);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color lightOutline = Color(0xFF79747E);
  static const Color lightOutlineVariant = Color(0xFFCAC4D0);

  static const Color lightInverseSurface = Color(0xFF313034);
  static const Color lightInverseOnSurface = Color(0xFFF4EFF4);
  static const Color lightInversePrimary = Color(0xFFD0BCFF);
  static const Color lightSurfaceTint = Color(0xFF665590);

  /// Semantic colors used across spending screens (income / expense).
  static const Color income = darkTertiary;
  static const Color incomeContainer = darkTertiaryContainer;
  static const Color expense = darkError;
  static const Color expenseContainer = darkErrorContainer;

  static ColorScheme darkColorScheme({ColorScheme? dynamic}) {
    final base = dynamic ?? _staticDarkColorScheme;
    return base.copyWith(
      surface: darkSurface,
      surfaceDim: darkSurfaceDim,
      surfaceBright: darkSurfaceBright,
      surfaceContainerLowest: darkSurfaceContainerLowest,
      surfaceContainerLow: darkSurfaceContainerLow,
      surfaceContainer: darkSurfaceContainer,
      surfaceContainerHigh: darkSurfaceContainerHigh,
      surfaceContainerHighest: darkSurfaceContainerHighest,
      surfaceVariant: darkSurfaceVariant,
      onSurface: darkOnSurface,
      onSurfaceVariant: darkOnSurfaceVariant,
      outline: darkOutline,
      outlineVariant: darkOutlineVariant,
      tertiary: darkTertiary,
      onTertiary: darkOnTertiary,
      tertiaryContainer: darkTertiaryContainer,
      onTertiaryContainer: darkOnTertiaryContainer,
      error: darkError,
      onError: darkOnError,
      errorContainer: darkErrorContainer,
      onErrorContainer: darkOnErrorContainer,
      inverseSurface: darkInverseSurface,
      onInverseSurface: darkInverseOnSurface,
      inversePrimary: darkInversePrimary,
      surfaceTint: dynamic?.primary ?? darkSurfaceTint,
    );
  }

  static ColorScheme lightColorScheme({ColorScheme? dynamic}) {
    final base = dynamic ?? _staticLightColorScheme;
    return base.copyWith(
      surface: lightSurface,
      surfaceDim: lightSurfaceDim,
      surfaceBright: lightSurfaceBright,
      surfaceContainerLowest: lightSurfaceContainerLowest,
      surfaceContainerLow: lightSurfaceContainerLow,
      surfaceContainer: lightSurfaceContainer,
      surfaceContainerHigh: lightSurfaceContainerHigh,
      surfaceContainerHighest: lightSurfaceContainerHighest,
      surfaceVariant: lightSurfaceVariant,
      onSurface: lightOnSurface,
      onSurfaceVariant: lightOnSurfaceVariant,
      outline: lightOutline,
      outlineVariant: lightOutlineVariant,
      tertiary: lightTertiary,
      onTertiary: lightOnTertiary,
      tertiaryContainer: lightTertiaryContainer,
      onTertiaryContainer: lightOnTertiaryContainer,
      error: lightError,
      onError: lightOnError,
      errorContainer: lightErrorContainer,
      onErrorContainer: lightOnErrorContainer,
      inverseSurface: lightInverseSurface,
      onInverseSurface: lightInverseOnSurface,
      inversePrimary: lightInversePrimary,
      surfaceTint: dynamic?.primary ?? lightSurfaceTint,
    );
  }

  static const ColorScheme _staticDarkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    secondary: darkSecondary,
    onSecondary: darkOnSecondary,
    secondaryContainer: darkSecondaryContainer,
    onSecondaryContainer: darkOnSecondaryContainer,
    tertiary: darkTertiary,
    onTertiary: darkOnTertiary,
    tertiaryContainer: darkTertiaryContainer,
    onTertiaryContainer: darkOnTertiaryContainer,
    error: darkError,
    onError: darkOnError,
    errorContainer: darkErrorContainer,
    onErrorContainer: darkOnErrorContainer,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceContainerHighest: darkSurfaceContainerHighest,
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: darkInverseSurface,
    onInverseSurface: darkInverseOnSurface,
    inversePrimary: darkInversePrimary,
    surfaceTint: darkSurfaceTint,
  );

  static const ColorScheme _staticLightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: lightPrimary,
    onPrimary: lightOnPrimary,
    primaryContainer: lightPrimaryContainer,
    onPrimaryContainer: lightOnPrimaryContainer,
    secondary: lightSecondary,
    onSecondary: lightOnSecondary,
    secondaryContainer: lightSecondaryContainer,
    onSecondaryContainer: lightOnSecondaryContainer,
    tertiary: lightTertiary,
    onTertiary: lightOnTertiary,
    tertiaryContainer: lightTertiaryContainer,
    onTertiaryContainer: lightOnTertiaryContainer,
    error: lightError,
    onError: lightOnError,
    errorContainer: lightErrorContainer,
    onErrorContainer: lightOnErrorContainer,
    surface: lightSurface,
    onSurface: lightOnSurface,
    surfaceContainerHighest: lightSurfaceContainerHighest,
    onSurfaceVariant: lightOnSurfaceVariant,
    outline: lightOutline,
    outlineVariant: lightOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: lightInverseSurface,
    onInverseSurface: lightInverseOnSurface,
    inversePrimary: lightInversePrimary,
    surfaceTint: lightSurfaceTint,
  );
}
