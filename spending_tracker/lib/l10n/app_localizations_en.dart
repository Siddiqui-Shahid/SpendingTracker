// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ZenSpend';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get updateRequired => 'Update required';

  @override
  String get updateAvailable => 'Update available';

  @override
  String get updateLater => 'Later';

  @override
  String get updateNow => 'Update';

  @override
  String get onboardingWelcomeTitle => 'Welcome to ZenSpend';

  @override
  String get onboardingWelcomeBody =>
      'Track income and expenses in one place. Simple, fast, and private.';

  @override
  String get onboardingBiometricTitle => 'Protect with biometrics';

  @override
  String get onboardingBiometricBody =>
      'Lock ZenSpend with fingerprint or face recognition so only you can open your finances.';

  @override
  String get getStarted => 'Get started';
}
