import 'dart:async';

import 'package:flutter/material.dart';

import '../core/services/app_update_service.dart';
import '../core/services/ad_service.dart';
import '../presentation/widgets/app_update_dialog.dart';
import 'onboarding_screen.dart';
import 'tabs_manager.dart';
import '../core/services/onboarding_service.dart';
import '../Data/hive_database.dart';

/// Decides between onboarding and the main app, then checks for updates.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  bool _onboardingComplete = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Existing installs before onboarding: skip the wizard.
    if (!OnboardingService.isComplete()) {
      final existing = HiveDataBase().readData();
      if (existing.isNotEmpty) {
        await OnboardingService.markComplete();
      }
    }

    if (!mounted) return;
    setState(() {
      _onboardingComplete = OnboardingService.isComplete();
      _ready = true;
    });
  }

  Future<void> _onMainShellReady(BuildContext context) async {
    // Splash ad runs over the main UI — does not block first paint.
    unawaited(AdService.showSplashAdIfNeeded());

    final info = await AppUpdateService.checkForUpdate();
    if (!context.mounted) return;
    await AppUpdateDialog.showIfNeeded(context, info);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox.shrink();
    }

    if (!_onboardingComplete) {
      return const OnboardingScreen();
    }

    return _MainShellGate(
      onReady: _onMainShellReady,
      child: const TabsManager(),
    );
  }
}

class _MainShellGate extends StatefulWidget {
  const _MainShellGate({
    required this.onReady,
    required this.child,
  });

  final Future<void> Function(BuildContext context) onReady;
  final Widget child;

  @override
  State<_MainShellGate> createState() => _MainShellGateState();
}

class _MainShellGateState extends State<_MainShellGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onReady(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
