import 'package:new_spendz/Data/hive_database.dart';
import 'package:new_spendz/Model/Expense_item.dart';
import 'package:new_spendz/Data/Expense_data.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});
  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.navigate_before_rounded),
          iconSize: 30,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Backup & Restore'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.backup, color: Colors.blue),
                title: const Text('Backup Data'),
                subtitle: const Text('Export your data to a backup file'),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  _showBackupDialog(context);
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.restore, color: Colors.green),
                title: const Text('Restore Data'),
                subtitle: const Text('Import data from a backup file'),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  _showRestoreDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text(
          'This will export your data to a backup file. You can restore your data on any device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) _performBackup(context);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Backup'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text(
          'This will replace all your current data with the data from the backup file. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) restoreBackup(context);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Select Backup File'),
          ),
        ],
      ),
    );
  }

  Future<void> _performBackup(BuildContext context) async {
    final hive = HiveDataBase();
    final expenseProvider = Provider.of<ExpenseData>(context, listen: false);
    final List<ExpenseItem> expenses = hive.readData();
    final List<Map<String, dynamic>> expensesJson = expenses
        .map(
          (e) => {
            'name': e.name,
            'amount': e.amount,
            'date': e.dateTime.toIso8601String(),
            'type': e.type,
          },
        )
        .toList();
    final List<String> categories = hive.getCategory();
    final double balance = hive.readBalance();
    final Map<String, dynamic> backupData = {
      'expenses': expensesJson,
      'categories': categories,
      'balance': balance,
      // Add other fields as needed
    };

    final bytes = utf8.encode(jsonEncode(backupData));
    final fileName =
        'spending_tracker_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Select location to save backup',
      fileName: fileName,
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (savePath == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup cancelled or failed.')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Backup created at:\n$savePath')),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Future<void> restoreBackup(BuildContext context) async {
    final hive = HiveDataBase();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final file = result.files.first;
      final fileBytes = file.bytes;
      if (fileBytes == null) {
        return;
      }
      final jsonString = utf8.decode(fileBytes);
      final decoded = jsonDecode(jsonString);

      // Update balance in provider if present in backup
      final expenseProvider = Provider.of<ExpenseData>(context, listen: false);
      if (decoded['balance'] != null) {
        try {
          final double restoredBalance = decoded['balance'] is num
              ? (decoded['balance'] as num).toDouble()
              : double.tryParse(decoded['balance'].toString()) ?? 0.0;
          debugPrint(
            '[BackupPage] Restoring balance from backup: '
            '\u001b[33m$restoredBalance\u001b[0m',
          );
          expenseProvider.setBalance(restoredBalance);
        } catch (e) {
          debugPrint('Failed to set restored balance: $e');
        }
      }

      // Restore categories
      if (decoded['categories'] != null && decoded['categories'] is List) {
        final List<String> categories = List<String>.from(
          decoded['categories'],
        );
        try {
          hive.setCategory(categories);
        } catch (e) {
          debugPrint('Failed to set categories: $e');
        }
      }

      // Restore expenses
      if (decoded['expenses'] != null && decoded['expenses'] is List) {
        List<ExpenseItem> expenses = [];
        for (var e in decoded['expenses']) {
          try {
            expenses.add(
              ExpenseItem(
                name: e['name'] ?? e['category'] ?? '',
                amount: e['amount'].toString(),
                dateTime:
                    DateTime.tryParse(e['date'] ?? e['dateTime'] ?? '') ??
                    DateTime.now(),
                type: e['type'] ?? 'expense',
              ),
            );
          } catch (err) {
            debugPrint('Failed to parse expense: $err');
          }
        }
        try {
          hive.saveData(expenses);
        } catch (e) {
          debugPrint('Failed to save expenses to Hive: $e');
        }
      }

      // Notify expense provider to refresh data
      expenseProvider.prepareData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restored successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to restore backup.')),
      );
    }
  }
}
