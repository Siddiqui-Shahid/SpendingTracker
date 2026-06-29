import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Grid tile for the Categories screen (Stitch 2-column layout).
class StitchCategoryGridCard extends StatelessWidget {
  const StitchCategoryGridCard({
    super.key,
    required this.label,
    required this.emoji,
    required this.transactionCount,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  final String label;
  final String emoji;
  final int transactionCount;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Gap between emoji container bottom and category title.
  static const double emojiToTextSpacing = 20;

  static const double emojiBoxSize = 44;
  static const double cardPadding = StitchSpacing.md;
  static const int maxLabelLines = 3;

  /// Row height sized for [maxLabelLines] title lines so every tile in a row
  /// matches the tallest possible content.
  static double tileHeight(TextTheme textTheme) {
    final labelStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final labelLineHeight =
        (labelStyle?.fontSize ?? 16) * (labelStyle?.height ?? 1.25);
    final labelBlockHeight = labelLineHeight * maxLabelLines;

    final subStyle = textTheme.bodySmall;
    final subHeight =
        (subStyle?.fontSize ?? 12) * (subStyle?.height ?? 1.33);

    return cardPadding * 2 +
        emojiBoxSize +
        emojiToTextSpacing +
        labelBlockHeight +
        StitchSpacing.xs +
        subHeight;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Semantics(
      label: '$label, $transactionCount transactions',
      button: true,
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: context.stitchShapes.borderRadiusXl,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: context.stitchShapes.borderRadiusXl,
              border: Border.all(
                color: selected ? colors.primary : colors.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.all(cardPadding),
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: emojiBoxSize,
                    height: emojiBoxSize,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: context.stitchShapes.borderRadiusMd,
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(height: emojiToTextSpacing),
                  Text(
                    label,
                    maxLines: maxLabelLines,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: StitchSpacing.xs),
                  Text(
                    '$transactionCount Transaction${transactionCount == 1 ? '' : 's'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
