import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Period filter chips for insights (Week / Month / Year / Custom).
class StitchPeriodFilterChips extends StatelessWidget {
  const StitchPeriodFilterChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.customLabel,
    this.isCustomSelected = false,
    this.onCustomTap,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String? customLabel;
  final bool isCustomSelected;
  final VoidCallback? onCustomTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.stitchSpacing.gutter,
        vertical: context.stitchSpacing.xs,
      ),
      child: Wrap(
        spacing: StitchSpacing.sm,
        runSpacing: StitchSpacing.sm,
        children: [
          for (var i = 0; i < labels.length; i++)
            FilterChip(
              label: Text(labels[i]),
              selected: !isCustomSelected && selectedIndex == i,
              onSelected: (_) => onSelected(i),
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
            ),
          if (onCustomTap != null)
            FilterChip(
              label: Text(customLabel ?? 'Custom'),
              selected: isCustomSelected,
              onSelected: (_) => onCustomTap!(),
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
