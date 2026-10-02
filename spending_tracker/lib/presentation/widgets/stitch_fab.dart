import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Primary FAB with Stitch rounded-square shape and minimal shadow.
class StitchFab extends StatelessWidget {
  const StitchFab({
    super.key,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.tooltip = 'Add transaction',
    this.heroTag,
    this.label,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;
  final Object? heroTag;

  /// When set, renders an extended FAB with [label] beside the icon.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: context.stitchShapes.borderRadiusXxl,
    );

    if (label != null) {
      return Semantics(
        button: true,
        label: tooltip,
        child: FloatingActionButton.extended(
          heroTag: heroTag ?? 'stitch_fab_extended',
          onPressed: onPressed,
          tooltip: tooltip,
          elevation: 1,
          highlightElevation: 2,
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          shape: shape,
          icon: Icon(icon, size: 24),
          label: Text(label!),
        ),
      );
    }

    return Semantics(
      button: true,
      label: tooltip,
      child: FloatingActionButton(
        heroTag: heroTag ?? 'stitch_fab',
        onPressed: onPressed,
        tooltip: tooltip,
        elevation: 1,
        highlightElevation: 2,
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        shape: shape,
        child: Icon(icon, size: 28),
      ),
    );
  }
}
