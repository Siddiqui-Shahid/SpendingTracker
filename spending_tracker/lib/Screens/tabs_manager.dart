import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../Data/Expense_data.dart';
import 'Home_Screen.dart';
import 'Login_Page.dart';
import 'addTransactionPage.dart';

class TabsManager extends StatefulWidget {
  const TabsManager({super.key});
  @override
  State<TabsManager> createState() => _TabsManager();
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        AddTransactionPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.5);
      const end = Offset.zero;
      const curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

class _TabsManager extends State<TabsManager> {
  bool _locked = false;
  int _attempts = 0;
  final int _maxAttempts = 3;
  final LocalAuthentication auth = LocalAuthentication();
  int currentPageIndex = 0;
  var _selectedIndex = 0;
  final List<Widget> _screens = [const HomeScreen(), const LoginScreen()];
  bool _didAuthCheck = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didAuthCheck) {
      _didAuthCheck = true;
      Future.delayed(Duration.zero, _checkFingerprint);
    }
  }

  Future<void> _checkFingerprint() async {
    final enabled = Provider.of<ExpenseData>(
      context,
      listen: false,
    ).getFingerprintEnabled();
    debugPrint('Fingerprint setting enabled: $enabled');
    if (!enabled) return;
    final canCheckBiometrics = await auth.canCheckBiometrics;
    final isDeviceSupported = await auth.isDeviceSupported();
    debugPrint(
      'Can check biometrics: $canCheckBiometrics, Device supported: $isDeviceSupported',
    );
    if (!canCheckBiometrics || !isDeviceSupported) {
      // Show fallback dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Biometrics not available'),
            content: const Text(
              'No biometrics enrolled or device not supported.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }
    bool authenticated = false;
    while (_attempts < _maxAttempts && !authenticated) {
      try {
        authenticated = await auth.authenticate(
          localizedReason: 'Authenticate to access the app',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
      } catch (e) {
        debugPrint('Biometric error: $e');
        authenticated = false;
      }
      if (!authenticated) {
        _attempts++;
        debugPrint('Fingerprint attempt $_attempts failed');
      }
    }
    if (!authenticated) {
      setState(() {
        _locked = true;
      });
    }
  }

  void _onTappedItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_locked) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'App locked due to failed fingerprint attempts.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Exit'),
              ),
            ],
          ),
        ),
      );
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(body: _screens[_selectedIndex]),
    );
  }
}
