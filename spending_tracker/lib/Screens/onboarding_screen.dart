import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../Data/Expense_data.dart';
import '../Data/hive_database.dart';
import '../Data/seed_data.dart';
import '../core/config/app_config.dart';
import '../core/services/onboarding_service.dart';
import '../core/utils/balance_utils.dart';
import '../presentation/widgets/widgets.dart';
import 'tabs_manager.dart';

/// First-run onboarding — replaces automatic demo seeding.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _localAuth = LocalAuthentication();
  int _page = 0;
  bool _loading = false;
  bool _biometricEnabled = false;
  bool _biometricChecking = false;

  List<({IconData icon, String title, String body})> get _pages => [
    (
      icon: Icons.account_balance_wallet_rounded,
      title: 'Welcome to ${AppConfig.appName}',
      body: 'Track income and expenses in one place. Simple, fast, and private.',
    ),
    (
      icon: Icons.fingerprint_rounded,
      title: 'Protect with biometrics',
      body:
          'Lock ${AppConfig.appName} with fingerprint or face recognition so only you can open your finances.',
    ),
    (
      icon: Icons.insights_rounded,
      title: 'Ready to start?',
      body:
          'Begin with a clean slate or explore the app with sample transactions.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleBiometric(bool enable) async {
    if (_biometricChecking) return;

    if (!enable) {
      setState(() => _biometricEnabled = false);
      return;
    }

    setState(() => _biometricChecking = true);

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();

      if (!canCheck || !supported) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Biometrics not available on this device. You can skip this step.',
            ),
          ),
        );
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Confirm biometrics for ${AppStrings.appName}',
      );

      if (!mounted) return;

      if (authenticated) {
        setState(() => _biometricEnabled = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric setup cancelled.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not enable biometrics.')),
      );
    } finally {
      if (mounted) setState(() => _biometricChecking = false);
    }
  }

  Future<void> _finish({required bool withDemoData}) async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final hive = HiveDataBase();
      if (withDemoData) {
        final sample = generateSampleTransactions(
          endDate: DateTime.now(),
          monthCount: 3,
        );
        hive.saveData(sample);
        hive.saveBalance(calculateBalance(sample));
      } else {
        await hive.eraseAndReset();
      }

      if (!mounted) return;
      Provider.of<ExpenseData>(
        context,
        listen: false,
      ).setFingerprintEnabled(_biometricEnabled);

      await OnboardingService.markComplete();

      if (!mounted) return;
      Provider.of<ExpenseData>(context, listen: false).prepareData();

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TabsManager()),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildPageContent(int index) {
    final page = _pages[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: StitchSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: StitchSpacing.lg),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: StitchSpacing.md),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (index == 1) ...[
            const SizedBox(height: StitchSpacing.xl),
            StitchAppCard(
              padding: EdgeInsets.zero,
              child: StitchListTile(
                leadingIcon: Icons.fingerprint_rounded,
                title: 'Enable biometric unlock',
                subtitle: _biometricChecking
                    ? 'Checking…'
                    : 'Require fingerprint or face to open the app',
                trailing: Switch(
                  value: _biometricEnabled,
                  onChanged: _biometricChecking ? null : _toggleBiometric,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _loading ? null : () => _finish(withDemoData: false),
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) => _buildPageContent(index),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: StitchSpacing.lg),
            Padding(
              padding: const EdgeInsets.all(StitchSpacing.md),
              child: Column(
                children: [
                  if (_page == _pages.length - 1) ...[
                    StitchPrimaryButton(
                      label: 'Get started',
                      icon: Icons.check_rounded,
                      expand: true,
                      onPressed: _loading
                          ? null
                          : () => _finish(withDemoData: false),
                    ),
                    const SizedBox(height: StitchSpacing.sm),
                    StitchSecondaryButton(
                      label: 'Try with sample data',
                      expand: true,
                      onPressed: _loading
                          ? null
                          : () => _finish(withDemoData: true),
                    ),
                  ] else
                    StitchPrimaryButton(
                      label: 'Continue',
                      expand: true,
                      onPressed: _loading
                          ? null
                          : () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            ),
                    ),
                  const SizedBox(height: StitchSpacing.sm),
                  Text(
                    AppConfig.appName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
