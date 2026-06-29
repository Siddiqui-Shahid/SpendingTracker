import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'stitch_colors.dart';
import 'stitch_component_themes.dart';
import 'stitch_semantic_colors.dart';
import 'stitch_shapes.dart';
import 'stitch_spacing.dart';
import 'stitch_typography.dart';

export 'stitch_colors.dart';
export 'stitch_component_themes.dart';
export 'stitch_context_extensions.dart';
export 'stitch_semantic_colors.dart';
export 'stitch_shapes.dart';
export 'stitch_spacing.dart';
export 'stitch_typography.dart';

/// Global Stitch / ZenSpend theme built from the active design system.
abstract final class StitchTheme {
  static const Color seedColor = StitchColors.seed;

  /// Light theme with optional Material You [dynamicScheme].
  static ThemeData light({ColorScheme? dynamicScheme}) {
    return _build(
      colorScheme: StitchColors.lightColorScheme(dynamic: dynamicScheme),
    );
  }

  /// Dark theme with optional Material You [dynamicScheme].
  static ThemeData dark({ColorScheme? dynamicScheme}) {
    return _build(
      colorScheme: StitchColors.darkColorScheme(dynamic: dynamicScheme),
    );
  }

  static ThemeData _build({required ColorScheme colorScheme}) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final textTheme = StitchTypography.textTheme(colorScheme);

    return StitchComponentThemes.build(
      colorScheme: colorScheme,
      textTheme: textTheme,
      isDark: isDark,
    ).copyWith(
      extensions: <ThemeExtension<dynamic>>[
        StitchSpacingTheme.standard,
        StitchShapesTheme.standard,
        StitchSemanticColors.from(colorScheme),
      ],
    );
  }

  /// System UI overlay style aligned with the current brightness.
  static SystemUiOverlayStyle systemOverlay(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark
          ? StitchColors.darkSurfaceContainerLow
          : StitchColors.lightSurfaceContainerLow,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    );
  }
}

/// Root widget that resolves dynamic color on supported platforms.
class StitchThemedApp extends StatelessWidget {
  const StitchThemedApp({
    super.key,
    required this.builder,
    this.themeMode = ThemeMode.system,
  });

  final Widget Function(
    BuildContext context,
    ThemeData lightTheme,
    ThemeData darkTheme,
  ) builder;

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightTheme = StitchTheme.light(dynamicScheme: lightDynamic);
        final darkTheme = StitchTheme.dark(dynamicScheme: darkDynamic);

        return Builder(
          builder: (context) => builder(context, lightTheme, darkTheme),
        );
      },
    );
  }
}

/// Syncs status bar and navigation bar colors with the active theme.
class StitchSystemUi extends StatelessWidget {
  const StitchSystemUi({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: StitchTheme.systemOverlay(Theme.of(context).brightness),
      child: child,
    );
  }
}

/// Cupertino theme derived from the active Stitch [ThemeData].
CupertinoThemeData stitchCupertinoTheme(BuildContext context) {
  return StitchComponentThemes.cupertino(Theme.of(context).colorScheme);
}
