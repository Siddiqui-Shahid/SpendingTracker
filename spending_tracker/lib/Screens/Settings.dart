import 'package:flutter/material.dart';
import 'package:new_spendz/Data/Expense_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Settings/Categories.dart';
import 'Settings/BackupPage.dart';
import 'package:provider/provider.dart';
import 'package:simple_icons/simple_icons.dart';

class Settings extends StatelessWidget {
  Settings({super.key});

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

  SimpleDialog CurencyHandler(
    BuildContext context,
    int selectedCurrency,
    List<String> currency,
    List<int> cur,
  ) {
    return SimpleDialog(
      title: const Text('Select Currency'),
      children: cur
          .map(
            (r) => RadioListTile(
              title: Text(currency[r]),
              groupValue: selectedCurrency,
              selected: r == selectedCurrency,
              value: r,
              onChanged: (dynamic val) {
                selectedCurrency = val;
                Provider.of<ExpenseData>(
                  context,
                  listen: false,
                ).addSettings(0, r);
                Navigator.of(context).pop();
              },
            ),
          )
          .toList(),
    );
  }

  void showAlertDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Erase All Data'),
        content: const Text(
          'All the existing data will be erased and reset to default. This cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<ExpenseData>(
                context,
                listen: false,
              ).eraseAndResetAll();
              Navigator.pop(context, 'ERASE');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All Data Erased and Reset to Default'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              );
            },
            child: const Text('ERASE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  bool lockAppSwitchVal = true;
  bool changePassSwitchVal = true;

  @override
  Widget build(BuildContext context) {
    List<String> currency = ["None", "Rupee - ₹", "Dollar - \$ ", "Euro - €"];
    List<int> cur = [0, 1, 2, 3];
    final toLaunch = Uri.parse('https://github.com/gautham2k3/SpendZ');
    // Move mutable fields to local variables
    return Consumer<ExpenseData>(
      builder: (context, value, child) {
        // Get fingerprint state from provider (savedSettings[2])
        bool fingerprintSwitchVal = value.getFingerprintEnabled();
        int selectedCurrency = value.getSavedSettings(1);
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.navigate_before_rounded),
              iconSize: 30,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text('Settings'),
            centerTitle: true,
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [Text("Common")],
                      ),
                      ListTile(
                        leading: const Icon(Icons.currency_exchange),
                        title: const Text("Currency"),
                        subtitle: Text(currency[selectedCurrency]),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CurencyHandler(
                                context,
                                selectedCurrency,
                                currency,
                                cur,
                              );
                            },
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.category_rounded),
                        title: const Text("Categories"),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                        subtitle: const Text("Add or Remove"),
                        onTap: () => handleTap(context),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [Text("Security")],
                      ),
                      ListTile(
                        leading: const Icon(Icons.fingerprint),
                        title: const Text("Use fingerprint"),
                        trailing: Switch(
                          value: fingerprintSwitchVal,
                          activeColor: Colors.blueAccent,
                          onChanged: (val) {
                            Provider.of<ExpenseData>(
                              context,
                              listen: false,
                            ).setFingerprintEnabled(val);
                          },
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text("Change Password"),
                        trailing: Switch(
                          value: changePassSwitchVal,
                          activeColor: Colors.blueAccent,
                          onChanged: (val) {},
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [Text("Data")],
                      ),
                      ListTile(
                        leading: const Icon(Icons.backup, color: Colors.blue),
                        title: const Text("Backup & Restore"),
                        subtitle: const Text("Backup or restore your data"),
                        trailing: const Icon(Icons.keyboard_arrow_right),
                        onTap: () => handleBackupTap(context),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.phonelink_erase_rounded,
                          color: Colors.red,
                        ),
                        title: const Text(
                          "Erase all Data",
                          selectionColor: Colors.red,
                        ),
                        onTap: () => showAlertDialog(context),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [Text("Social")],
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          SimpleIcons.github,
                          color: Colors.black,
                        ),
                        title: const Text("GitHub"),
                        subtitle: const Text('Star & Share the Repo'),
                        trailing: IconButton(
                          icon: const Icon(Icons.open_in_new),
                          tooltip: 'Open Link in Browser',
                          onPressed: () {
                            launchUrl(
                              toLaunch,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                        ),
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
