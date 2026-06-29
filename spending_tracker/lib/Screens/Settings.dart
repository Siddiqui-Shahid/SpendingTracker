import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:new_spendz/Data/Expense_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Settings/Categories.dart';
import 'Settings/BackupPage.dart';
import 'Settings/AboutPage.dart';
import 'package:provider/provider.dart';
import 'package:simple_icons/simple_icons.dart';
import '../core/config/app_config.dart';
import '../presentation/widgets/widgets.dart';

class Settings extends StatelessWidget {
  const Settings({super.key, this.asTab = false});

  final bool asTab;

  static final Uri _githubRepoUrl = Uri.parse(
    'https://github.com/Siddiqui-Shahid/SpendingTracker/tree/main',
  );

  Future<void> _launchGitHub(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (!await canLaunchUrl(_githubRepoUrl)) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('Could not open GitHub in browser')),
      );
      return;
    }

    try {
      // Dismiss settings on Android before launching so the browser opens in
      // the default app instead of an in-app Custom Tab overlay that can hang.
      if (defaultTargetPlatform == TargetPlatform.android &&
          context.mounted &&
          !asTab) {
        Navigator.of(context).pop();
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }

      final launched = await launchUrl(
        _githubRepoUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        messenger?.showSnackBar(
          const SnackBar(content: Text('Could not open GitHub in browser')),
        );
      }
    } catch (_) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('Could not open GitHub in browser')),
      );
    }
  }

  void handleTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Categories()),
    );
  }

  void handleBackupTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BackupPage()),
    );
  }

  void showAlertDialog(BuildContext context) {
    StitchConfirmationDialog.show(
      context: context,
      title: 'Erase All Data',
      message:
          'All the existing data will be erased and reset to default. This cannot be undone.',
      icon: Icons.phonelink_erase_rounded,
      destructive: true,
      secondaryLabel: 'Cancel',
      primaryLabel: 'ERASE',
      onSecondary: () {},
      onPrimary: () async {
        await Provider.of<ExpenseData>(
          context,
          listen: false,
        ).eraseAndResetAll();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All Data Erased and Reset to Default'),
            ),
          );
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseData>(
      builder: (context, value, child) {
        // Get fingerprint state from provider (savedSettings[2])
        bool fingerprintSwitchVal = value.getFingerprintEnabled();
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: !asTab,
            leading: asTab
                ? null
                : IconButton(
                    icon: const Icon(Icons.navigate_before_rounded),
                    iconSize: 30,
                    onPressed: () => Navigator.pop(context),
                  ),
            title: const Text('Settings'),
            centerTitle: true,
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(StitchSpacing.md),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StitchSectionHeader(
                        title: 'Common',
                        compact: true,
                        padding: EdgeInsets.zero,
                      ),
                      StitchListTile(
                        leadingIcon: Icons.category_rounded,
                        title: 'Categories',
                        subtitle: 'Add or Remove',
                        trailing: const Icon(Icons.keyboard_arrow_right),
                        onTap: () => handleTap(context),
                      ),
                      const StitchSectionHeader(
                        title: 'Security',
                        compact: true,
                        padding: EdgeInsets.zero,
                      ),
                      StitchListTile(
                        leadingIcon: Icons.fingerprint,
                        title: 'Biometric unlock',
                        subtitle:
                            'Require fingerprint or face to open the app',
                        trailing: Switch(
                          value: fingerprintSwitchVal,
                          onChanged: (val) {
                            Provider.of<ExpenseData>(
                              context,
                              listen: false,
                            ).setFingerprintEnabled(val);
                          },
                        ),
                      ),
                      const StitchSectionHeader(
                        title: 'Data',
                        compact: true,
                        padding: EdgeInsets.zero,
                      ),
                      StitchListTile(
                        leadingIcon: Icons.backup,
                        title: 'Backup & Restore',
                        subtitle: 'Backup or restore your data',
                        trailing: const Icon(Icons.keyboard_arrow_right),
                        onTap: () => handleBackupTap(context),
                      ),
                      const Divider(),
                      StitchListTile(
                        leadingIcon: Icons.phonelink_erase_rounded,
                        title: 'Erase all Data',
                        destructive: true,
                        onTap: () => showAlertDialog(context),
                      ),
                      const StitchSectionHeader(
                        title: 'About',
                        compact: true,
                        padding: EdgeInsets.zero,
                      ),
                      StitchListTile(
                        leadingIcon: Icons.info_outline_rounded,
                        title: 'About ${AppConfig.appName}',
                        subtitle: 'Version, support & legal',
                        trailing: const Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutPage(),
                            ),
                          );
                        },
                      ),
                      const StitchSectionHeader(
                        title: 'Social',
                        compact: true,
                        padding: EdgeInsets.zero,
                      ),
                      const Divider(),
                      StitchListTile(
                        leading: const Icon(
                          SimpleIcons.github,
                        ),
                        title: 'GitHub',
                        subtitle: 'Star & Share the Repo',
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => _launchGitHub(context),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
