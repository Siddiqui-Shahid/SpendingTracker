import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/services/legal_service.dart';
import '../../presentation/widgets/widgets.dart';
import 'legal_document_screen.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _packageInfo = info);
  }

  void _openLegal(BuildContext context, LegalDocumentType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LegalDocumentScreen(type: type)),
    );
  }

  Future<void> _emailSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConfig.supportEmail,
      queryParameters: {
        'subject': '${AppConfig.appName} support',
      },
    );
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email us at ${AppConfig.supportEmail}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final version = _packageInfo?.version ?? '…';
    final build = _packageInfo?.buildNumber ?? '…';

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(StitchSpacing.md),
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: StitchSpacing.sm),
                Text(
                  AppConfig.appName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: StitchSpacing.xs),
                Text(
                  'Version $version ($build)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: StitchSpacing.lg),
          const StitchSectionHeader(
            title: 'Support',
            compact: true,
            padding: EdgeInsets.zero,
          ),
          StitchListTile(
            leadingIcon: Icons.mail_outline_rounded,
            title: 'Contact support',
            subtitle: AppConfig.supportEmail,
            onTap: () => _emailSupport(context),
          ),
          const StitchSectionHeader(
            title: 'Legal',
            compact: true,
            padding: EdgeInsets.zero,
          ),
          StitchListTile(
            leadingIcon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Loaded from Firebase',
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () => _openLegal(context, LegalDocumentType.privacyPolicy),
          ),
          StitchListTile(
            leadingIcon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Loaded from Firebase',
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () => _openLegal(context, LegalDocumentType.termsOfService),
          ),
          const SizedBox(height: StitchSpacing.md),
          Text(
            'Legal documents are hosted in Firebase Remote Config and can be '
            'updated without releasing a new app version. A bundled copy is '
            'used when offline.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
