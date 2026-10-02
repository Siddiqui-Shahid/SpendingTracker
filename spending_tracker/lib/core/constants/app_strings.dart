/// Centralized branding and copy for the MoneySeer app.
abstract final class AppStrings {
  /// Display name shown in app bars, lock screen, etc.
  static const String appName = 'MoneySeer';

  /// Alternate Stitch project brand name.
  static const String stitchBrandName = 'MoneySeer';

  static const String currencySymbol = '₹';

  static const String lockTitle = '$appName is locked';
  static const String lockSubtitle = 'Use fingerprint or face to unlock';
  static const String lockVerifying = 'Verifying your identity...';
  static const String unlockButton = 'Unlock';

  static const String dashboardBalanceLabel = 'My Balance';
  static const String recentActivity = 'Recent Activity';
  static const String viewAll = 'View All';
  static const String transactionHistory = 'Transaction History';
  static const String addTransaction = 'Add Transaction';
  static const String editTransaction = 'Edit Transaction';
  static const String spendingInsights = 'Spending Insights';
  static const String settings = 'Settings';
  static const String comingSoon = 'Coming Soon';

  static const String aiSavingsCoach = 'AI Savings Coach';
  static const String aiSavingsCoachSubtitle =
      'Private offline RAG over your spending habits. Uses Apple Intelligence on iOS and Gemini Nano on Android when available.';
  static const String aiOfflineBadge = 'Offline';
  static const String aiCoachQuestionHint =
      'Ask anything, e.g. Why is Food high?';
  static const String aiGetPlan = 'Weekly save plan';
  static const String aiAsk = 'Ask';
  static const String aiOnDeviceSource = 'On-device AI';
  static const String aiRulesSource = 'Local habit tips';
  static const String aiShowContext = 'Show retrieved spending context';
  static const String aiHideContext = 'Hide spending context';
}
