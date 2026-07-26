import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/theme.dart';

/// Branded splash shown while the app bootstraps in the background.
class AppSplashScreen extends StatelessWidget {
  const AppSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 72,
              color: colors.primary,
            ),
            const SizedBox(height: StitchSpacing.md),
            Text(
              AppConfig.appName,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: StitchSpacing.lg),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
