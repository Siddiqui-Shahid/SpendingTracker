/// Default legal copy bundled with the app when Remote Config is unavailable.
abstract final class LegalDocuments {
  static const String privacyPolicyUpdated = 'October 2, 2026';
  static const String termsUpdated = 'October 2, 2026';

  static const String privacyPolicy = '''
MoneySeer Privacy Policy

Last updated: October 2, 2026
Contact: hello@cyfur.in

1. Introduction

MoneySeer ("we", "our", "us") is a personal expense tracking application published by Cyfur. This Privacy Policy explains how we handle information when you use the MoneySeer mobile application ("the App").

2. Information we collect

2.1 Data stored on your device
MoneySeer stores the following data locally on your device unless you choose to export it:
• Transaction descriptions, amounts, dates, and types (income or expense)
• Custom categories and app preferences
• Biometric unlock preference (enabled or disabled)
• Backup files you create manually

We do not upload your transaction data to our servers by default.

2.2 On-device AI (optional)
The AI Savings Coach builds a local index of your spending habits on your device (retrieval-augmented generation). When Apple Intelligence (iOS) or Gemini Nano (Android) is available, advice is generated on-device. If the on-device model is unavailable, MoneySeer shows rule-based tips computed from the same local data. Financial details used for coaching are not sent to Cyfur servers or to cloud AI APIs operated by us.

2.3 Data sent to third-party services
To keep the App reliable and up to date, we use Google Firebase:
• Crashlytics: anonymous crash reports (device model, OS version, app version, stack traces). Your transaction details are not intentionally included.
• Remote Config: fetches app settings such as minimum supported version, update messages, ad settings, and legal document text. No personal financial data is sent.

2.4 Advertising (Android)
On Android, MoneySeer may show ads through Google AdMob. Google may collect and use your device's advertising identifier (Advertising ID), IP address, device information, and ad interaction data to deliver, measure, and improve ads. We do not share your transaction data with advertisers. Ad display may be controlled remotely via Firebase Remote Config. Learn more about how Google uses data: https://policies.google.com/privacy. You can manage ad personalization at https://adssettings.google.com/.

2.5 Support communications
If you email hello@cyfur.in, we receive the information you include in your message (such as your email address and message content) solely to respond to your request.

3. How we use information

We use collected information to:
• Provide core app functionality on your device
• Generate private savings tips from local spending context (on-device AI or rules)
• Diagnose and fix crashes
• Deliver app updates and legal notices
• Display and measure ads on Android (via Google AdMob)
• Respond to support requests

We do not sell your personal information.

4. Permissions

• Biometric authentication: to lock the App (optional)
• Storage / files: to export and restore backup files
• Internet: for Crashlytics, Remote Config, AdMob, and support links

5. Data retention and deletion

Transaction data remains on your device until you delete it or uninstall the App. You can erase all data at any time from Settings → Erase all Data. Crash reports are retained by Google Firebase according to Google's policies.

6. Security

We recommend enabling biometric unlock and keeping your device OS up to date. You are responsible for securing exported backup files.

7. Children's privacy

MoneySeer is not directed to children under 13. We do not knowingly collect information from children.

8. International users

Your data is primarily stored on your device. Firebase services may process technical data on servers operated by Google in various regions.

9. Changes to this policy

We may update this Privacy Policy. Updated text may be delivered through the App via Firebase Remote Config. Continued use after changes constitutes acceptance.

10. Contact

Questions about this policy: hello@cyfur.in
''';

  static const String termsOfService = '''
MoneySeer Terms of Service

Last updated: October 2, 2026
Contact: hello@cyfur.in

1. Agreement

By downloading, installing, or using MoneySeer ("the App"), you agree to these Terms of Service ("Terms"). If you do not agree, do not use the App.

2. Description of service

MoneySeer is a personal finance tracking tool that helps you record income and expenses on your device. MoneySeer is not a bank, payment processor, financial advisor, accountant, or tax preparation service.

3. Eligibility

You must be at least 13 years old (or the minimum age required in your jurisdiction) to use the App.

4. Your account and device

MoneySeer does not require a user account. You are responsible for:
• The accuracy of information you enter
• Securing your device and any backup files
• Compliance with applicable laws

5. Acceptable use

You agree not to:
• Use the App for unlawful purposes
• Attempt to reverse engineer or disrupt the App
• Misuse support channels or submit false reports

6. Financial disclaimer

All balances, charts, and summaries are based on data you enter. They are for personal reference only and do not constitute financial, investment, legal, or tax advice. Consult qualified professionals for financial decisions.

7. Data and backups

Your data is stored locally on your device. We are not responsible for loss of data due to device failure, theft, uninstallation, or failure to maintain backups. Use Settings → Backup & Restore regularly.

8. Biometric lock

If you enable biometric unlock, authentication is handled by your device's operating system. We do not store your fingerprint or face data.

9. App updates

We may release updates that add, modify, or remove features. Some updates may be required to continue using the App, as indicated through in-app update prompts powered by Firebase Remote Config.

10. Third-party services

The App uses Google Firebase (Crashlytics, Remote Config) and Google AdMob (Android advertising). Your use of those services is also subject to Google's terms and privacy policies.

11. Disclaimer of warranties

THE APP IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.

12. Limitation of liability

TO THE MAXIMUM EXTENT PERMITTED BY LAW, CYFUR AND ITS AFFILIATES SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR ANY LOSS OF DATA, PROFITS, OR REVENUE, ARISING FROM YOUR USE OF THE APP.

13. Termination

You may stop using the App at any time by uninstalling it. We may discontinue or modify the App at any time.

14. Governing law

These Terms are governed by the laws of India, without regard to conflict-of-law principles, except where mandatory local consumer laws apply.

15. Changes to these Terms

We may update these Terms. Updated text may be delivered through the App via Firebase Remote Config. The "Last updated" date will reflect the latest version.

16. Contact

For questions about these Terms: hello@cyfur.in
''';
}
// debugPrint(privacyPolicy.replaceAll('\n', r'\n'));