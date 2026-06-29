/// Application entry point for SpendZ
///
/// Initializes Hive, Firebase (Crashlytics + Remote Config), and Provider.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:new_spendz/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'Data/Expense_data.dart';
import 'Screens/app_root.dart';
import 'core/config/app_config.dart';
import 'core/services/firebase_service.dart';
import 'core/services/onboarding_service.dart';
import 'core/theme/theme.dart';
import 'utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('expense_database');
  await OnboardingService.ensureInitialized();

  try {
    await FirebaseService.initialize();
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('Firebase initialization skipped or failed: $e');
    }
    // App remains usable offline if Firebase fails on first launch.
    debugPrintStack(stackTrace: stack);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExpenseData(),
      child: StitchThemedApp(
        themeMode: ThemeMode.system,
        builder: (context, lightTheme, darkTheme) {
          return MaterialApp(
            title: '${AppConfig.appName} - Expense Tracker',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            scrollBehavior: MyCustomScrollBehavior(),
            builder: (context, child) {
              return StitchSystemUi(
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const AppRoot(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
