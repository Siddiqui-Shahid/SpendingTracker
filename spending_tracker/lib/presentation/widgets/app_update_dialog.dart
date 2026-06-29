import 'package:flutter/material.dart';

import '../../core/services/app_update_service.dart';
import '../../core/theme/stitch_spacing.dart';

/// Shows optional or forced update prompts from Firebase Remote Config.
class AppUpdateDialog extends StatelessWidget {
  const AppUpdateDialog({
    super.key,
    required this.info,
    this.onDismiss,
  });

  final AppUpdateInfo info;
  final VoidCallback? onDismiss;

  static Future<void> showIfNeeded(
    BuildContext context,
    AppUpdateInfo info,
  ) async {
    if (!info.shouldShow || !context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: !info.isForced,
      builder: (_) => AppUpdateDialog(info: info),
    );
  }

  @override
  Widget build(BuildContext context) {
    final forced = info.isForced;

    return PopScope(
      canPop: !forced,
      child: AlertDialog(
        icon: Icon(
          forced ? Icons.system_update_alt_rounded : Icons.new_releases_outlined,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(forced ? 'Update required' : 'Update available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (info.message != null) Text(info.message!),
            if (info.latestVersion != null) ...[
              const SizedBox(height: StitchSpacing.sm),
              Text(
                'Latest version: ${info.latestVersion}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!forced)
            TextButton(
              onPressed: () {
                onDismiss?.call();
                Navigator.of(context).pop();
              },
              child: const Text('Later'),
            ),
          FilledButton(
            onPressed: () async {
              await AppUpdateService.openStore(info.storeUrl);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
