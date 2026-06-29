import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../Data/Expense_data.dart';
import '../core/constants/app_strings.dart';
import '../presentation/widgets/widgets.dart';
import 'Analysis_Screen.dart';
import 'Balance_Overview.dart';
import 'Settings.dart';
import 'addTransactionPage.dart';
import 'dashboard_screen.dart';
import 'transaction_history_screen.dart';

class TabsManager extends StatefulWidget {
  const TabsManager({super.key});

  @override
  State<TabsManager> createState() => _TabsManager();
}

Route<void> _createAddTransactionRoute() {
  return PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const AddTransactionPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.5);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;
      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: curve),
      );
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

class _TabsManager extends State<TabsManager> {
  bool _locked = false;
  bool _unlocked = false;
  bool _authInProgress = false;
  int _attempts = 0;
  final int _maxAttempts = 3;
  final LocalAuthentication _auth = LocalAuthentication();
  int _selectedIndex = 0;
  bool _didAuthCheck = false;

  bool _isBiometricEnabled() {
    return Provider.of<ExpenseData>(
      context,
      listen: false,
    ).getFingerprintEnabled();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didAuthCheck) {
      _didAuthCheck = true;
      if (_isBiometricEnabled()) {
        Future<void>.delayed(Duration.zero, _checkFingerprint);
      } else {
        _unlocked = true;
      }
    }
  }

  Future<void> _checkFingerprint() async {
    if (_authInProgress || _unlocked || _locked) return;

    setState(() => _authInProgress = true);

    final canCheckBiometrics = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();

    if (!canCheckBiometrics || !isDeviceSupported) {
      if (mounted) {
        setState(() {
          _authInProgress = false;
          _unlocked = true;
        });
        await StitchConfirmationDialog.show(
          context: context,
          title: 'Biometrics not available',
          message:
              'No biometrics enrolled or device not supported. Unlocking without biometric.',
          icon: Icons.fingerprint_rounded,
        );
      }
      return;
    }

    var authenticated = false;
    while (_attempts < _maxAttempts && !authenticated && mounted) {
      try {
        authenticated = await _auth.authenticate(
          localizedReason: 'Authenticate to unlock ${AppStrings.appName}',
        );
      } catch (e) {
        debugPrint('Biometric error: $e');
        authenticated = false;
      }
      if (!authenticated) {
        _attempts++;
      }
    }

    if (!mounted) return;

    if (authenticated) {
      setState(() {
        _unlocked = true;
        _authInProgress = false;
        _attempts = 0;
      });
    } else {
      setState(() {
        _locked = true;
        _authInProgress = false;
      });
    }
  }

  void _openAddTransaction() {
    Navigator.of(context).push(_createAddTransactionRoute());
  }

  void _openBalanceOverview(double balance) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BalanceOverview(number: balance.round()),
      ),
    );
  }

  Widget _buildLockScreen() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: StitchSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fingerprint_rounded,
                  size: 96,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: StitchSpacing.lg),
                Text(
                  AppStrings.lockTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: StitchSpacing.sm),
                Text(
                  _authInProgress
                      ? AppStrings.lockVerifying
                      : AppStrings.lockSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: StitchSpacing.xl),
                if (!_authInProgress)
                  StitchPrimaryButton(
                    label: AppStrings.unlockButton,
                    icon: Icons.fingerprint_rounded,
                    onPressed: _checkFingerprint,
                    padding: const EdgeInsets.symmetric(
                      horizontal: StitchSpacing.xl,
                      vertical: StitchSpacing.md,
                    ),
                  ),
                if (_authInProgress)
                  const StitchLoadingIndicator(
                    message: AppStrings.lockVerifying,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainShell() {
    return Consumer<ExpenseData>(
      builder: (context, expenseData, _) {
        final balance = expenseData.getBalance();

        return StitchNavigationShell(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: [
            StitchNavDestination(
              label: 'Home',
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              body: DashboardScreen(
                onViewAll: () => setState(() => _selectedIndex = 1),
                onBalanceLongPress: () => _openBalanceOverview(balance),
                onAddTransaction: _openAddTransaction,
              ),
            ),
            const StitchNavDestination(
              label: 'History',
              icon: Icons.receipt_long_outlined,
              selectedIcon: Icons.receipt_long_rounded,
              body: TransactionHistoryScreen(),
            ),
            const StitchNavDestination(
              label: 'Insights',
              icon: Icons.bar_chart_outlined,
              selectedIcon: Icons.bar_chart_rounded,
              body: AnalysisScreen(),
            ),
            StitchNavDestination(
              label: AppStrings.settings,
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings_rounded,
              body: Settings(asTab: true),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) {
      return Scaffold(
        body: StitchErrorState(
          title: 'App locked',
          message: 'App locked due to failed fingerprint attempts.',
          icon: Icons.lock_outline_rounded,
          onRetry: () {
            setState(() {
              _locked = false;
              _attempts = 0;
            });
            _checkFingerprint();
          },
        ),
      );
    }

    if (_isBiometricEnabled() && !_unlocked) {
      return _buildLockScreen();
    }

    return _buildMainShell();
  }
}
