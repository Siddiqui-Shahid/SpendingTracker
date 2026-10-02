/// Application entry point for MoneySeer
///
/// Shows the splash immediately, then bootstraps Hive/Firebase/Ads in parallel.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:new_spendz/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'Data/Expense_data.dart';
import 'Screens/app_root.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/bootstrap/app_bootstrap_service.dart';
import 'core/config/app_config.dart';
import 'core/theme/theme.dart';
import 'utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<void> _bootstrap = AppBootstrapService.initialize();
  bool _loadedPrefsAfterBootstrap = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseData()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          final themeMode = themeController.themeMode;
          return StitchThemedApp(
            themeMode: themeMode,
            builder: (context, lightTheme, darkTheme) {
              return MaterialApp(
                title: '${AppConfig.appName} - Expense Tracker',
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeMode,
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
                home: FutureBuilder<void>(
                  future: _bootstrap,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const AppSplashScreen();
                    }
                    if (!_loadedPrefsAfterBootstrap) {
                      _loadedPrefsAfterBootstrap = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.read<ExpenseData>().prepareData();
                        context.read<ThemeController>().load();
                      });
                    }
                    return const AppRoot();
                  },
                ),
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}
