/// Application entry point for Spending Tracker (Spendz)
///
/// This file initializes the Flutter application with:
/// - Hive local database setup
/// - Provider state management configuration
/// - Material Design theme configuration
///
/// The app implements a modern expense tracking system with biometric
/// authentication and local data persistence.

import 'package:flutter/material.dart';
import 'Data/Expense_data.dart';
import 'Screens/tabs_manager.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Main entry point for the application
///
/// Initializes Hive local database before running the app.
/// Hive is used for persistent local storage of expenses and app settings.
///
/// Usage:
/// ```dart
/// void main() async {
///   await Hive.initFlutter();
///   await Hive.openBox("expense_database");
///   runApp(const MyApp());
/// }
/// ```
void main() async {
  // Initialize Hive for Flutter
  await Hive.initFlutter();

  // Open the main database box for storing expenses
  await Hive.openBox("expense_database");

  // Run the app
  runApp(const MyApp());
}

/// Root widget of the application
///
/// [MyApp] is the main application widget that:
/// - Provides [ExpenseData] state via Provider pattern
/// - Configures Material Design theme
/// - Sets up the home screen as [TabsManager]
/// - Disables debug banner for clean UI
///
/// State Management:
/// - Uses Provider package with ChangeNotifier pattern
/// - [ExpenseData] manages all expense-related state
/// - Real-time updates to all listening widgets
///
/// Theme:
/// - Material Design 3 compatible
/// - Light theme configured (dark theme available)
///
/// Example:
/// ```dart
/// return ChangeNotifierProvider(
///   create: (context) => ExpenseData(),
///   builder: (context, child) => MaterialApp(
///     title: 'Spendz',
///     home: const TabsManager(),
///   ),
/// );
/// ```
class MyApp extends StatelessWidget {
  /// Creates a [MyApp] widget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      /// Create and provide ExpenseData instance to entire widget tree
      create: (context) => ExpenseData(),
      builder: (context, child) => MaterialApp(
        /// App title shown in system UI
        title: 'Spendz - Expense Tracker',

        /// Home screen - TabsManager handles navigation and auth
        home: const TabsManager(),

        /// Hide debug banner in top right corner
        debugShowCheckedModeBanner: false,

        /// Configure light theme
        /// Dark theme can be enabled by uncommenting darkTheme
        theme: ThemeData().copyWith(),

        // Optional: Uncomment to add dark theme support
        // darkTheme: ThemeData.dark().copyWith(useMaterial3: true),
      ),
    );
  }
}
