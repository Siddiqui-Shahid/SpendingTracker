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
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
        shape: RoundedRectangleBorder(
          borderRadius: context.stitchShapes.borderRadiusXxl,
        ),
        child: Icon(icon, size: 28),
      ),
    );
  }
}
