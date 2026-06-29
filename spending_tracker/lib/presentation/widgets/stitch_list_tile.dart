import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Settings-style list row with consistent Stitch styling.
class StitchListTile extends StatelessWidget {
  const StitchListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.leadingIcon,
    this.leadingIconColor,
    this.destructive = false,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final titleColor = destructive ? colors.error : colors.onSurface;

    return ListTile(
      onTap: onTap,
      contentPadding: StitchSpacing.listItemPadding,
      minTileHeight: StitchSpacing.transactionListItemHeight,
      leading: leading ??
          (leadingIcon != null
              ? Icon(
                  leadingIcon,
                  color: leadingIconColor ??
                      (destructive ? colors.error : colors.onSurfaceVariant),
                )
              : null),
      title: Text(
        title,
        style: context.textTheme.bodyLarge?.copyWith(color: titleColor),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing,
    );
  }
}
