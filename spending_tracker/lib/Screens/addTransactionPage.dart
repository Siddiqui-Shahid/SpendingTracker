import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_spendz/Data/Expense_data.dart';
import 'package:new_spendz/Model/Expense_item.dart';
import 'package:new_spendz/utils.dart';
import 'package:new_spendz/Screens/Settings/Categories.dart';

enum TypeEI { expense, income }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: AddTransactionPage());
  }
}

class AddTransactionPage extends StatefulWidget {
  final ExpenseItem? initialItem;
  final int? itemIndex;
  final bool isEdit;
  const AddTransactionPage({
    Key? key,
    this.initialItem,
    this.itemIndex,
    this.isEdit = false,
  }) : super(key: key);

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  Set<TypeEI> selectedAccessories = <TypeEI>{TypeEI.expense};
  TypeEI selectedIndex = TypeEI.expense;
  // Variables to store transaction details
  String? title;
  double? amount;
  String? selectedCategory; // Selected category
  DateTime? dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.initialItem != null) {
      // Parse category and title from name
      String name = widget.initialItem!.name;
      if (name.contains(' - ')) {
        final parts = name.split(' - ');
        selectedCategory = parts[0];
        title = parts.sublist(1).join(' - ');
      } else {
        title = name;
      }
      _titleController.text = title ?? '';
      _amountController.text = widget.initialItem!.amount;
      dateTime = widget.initialItem!.dateTime;
      selectedIndex = widget.initialItem!.type == 'income'
          ? TypeEI.income
          : TypeEI.expense;
      selectedAccessories = {selectedIndex};
      // Set _value for category chip
      avlC = hive.getCategory();
      if (selectedCategory != null) {
        _value = avlC.indexWhere((c) => c == selectedCategory);
      }
      amount = double.tryParse(widget.initialItem!.amount);
    }
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: dateTime != null
            ? TimeOfDay(hour: dateTime!.hour, minute: dateTime!.minute)
            : TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          dateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // Create text editing controllers for the input fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int? _value;
  // 10 default categories
  final List<String> defaultCategories = [
    '🎓 Education',
    '🍔 Food',
    '✈️ Travel',
    '📦 Miscellaneous',
    '💊 Health',
    '🛍️ Shopping',
    '💡 Bills',
    '🎬 Entertainment',
    '🛒 Groceries',
    '🎁 Gifts',
  ];
  var avlC = <String>[];
  // Ensure categories are initialized in Hive
  void _ensureCategories() {
    avlC = hive.getCategory();
    if (avlC.isEmpty) {
      hive.setCategory(defaultCategories);
      avlC = List<String>.from(defaultCategories);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      dateTime = dateTime ?? DateTime.now();
      String type = selectedIndex == TypeEI.expense ? "expense" : "income";
      double amt = amount ?? 0.0;
      String displayName = title.toString();
      if (selectedCategory != null && selectedCategory!.isNotEmpty) {
        displayName = '${selectedCategory!} - $displayName';
      }
      ExpenseItem newItem = ExpenseItem(
        name: displayName,
        dateTime: dateTime!,
        amount: amt.toString(),
        type: type,
      );
      final provider = Provider.of<ExpenseData>(context, listen: false);
      if (widget.isEdit &&
          widget.itemIndex != null &&
          widget.initialItem != null) {
        // Edit mode: update the item in provider and update balance
        double oldAmount = double.tryParse(widget.initialItem!.amount) ?? 0.0;
        double newAmount = amt;
        double balance = provider.getBalance();
        // Remove old transaction's effect
        if (widget.initialItem!.type == 'expense') {
          balance += oldAmount;
        } else {
          balance -= oldAmount;
        }
        // Add new transaction's effect
        if (type == 'expense') {
          balance -= newAmount;
        } else {
          balance += newAmount;
        }
        provider.setBalance(balance);
        provider.updateExpense(widget.itemIndex!, newItem);
      } else {
        // Add mode
        double balance = provider.getBalance();
        if (type == 'expense') {
          balance -= amt;
        } else {
          balance += amt;
        }
        provider.setBalance(balance);
        provider.addExpense(newItem);
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(0),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.check, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.isEdit
                        ? 'Transaction Edited'
                        : (type == "expense"
                              ? 'Expense Submitted'
                              : 'Income Submitted'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    child: const Text('OK', style: TextStyle(fontSize: 20)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureCategories();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              SegmentedButton<TypeEI>(
                segments: const <ButtonSegment<TypeEI>>[
                  ButtonSegment<TypeEI>(
                    value: TypeEI.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  ButtonSegment<TypeEI>(
                    value: TypeEI.income,
                    label: Text('Income'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
                selected: selectedAccessories,
                onSelectionChanged: (Set<TypeEI> newSelection) {
                  setState(() {
                    selectedAccessories = newSelection;
                    selectedIndex = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateTime == null
                            ? 'Select date and time'
                            : '${dateTime!.day}/${dateTime!.month}/${dateTime!.year} '
                                  '${dateTime!.hour.toString().padLeft(2, '0')}:${dateTime!.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _pickDateTime(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  filled: true,
                  labelText: selectedIndex == TypeEI.expense
                      ? 'Expense'
                      : 'Income',
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    amount = double.tryParse(value);
                  });
                },
              ),
              const SizedBox(height: 10),
              Wrap(
                children: <Widget>[
                  const SizedBox(height: 10.0),
                  Wrap(
                    spacing: 3.0,
                    children: List<Widget>.generate(avlC.length, (int index) {
                      // Split emoji and text for display
                      String label = avlC[index];
                      String emoji = '';
                      String text = label;
                      if (label.contains(' ')) {
                        int firstSpace = label.indexOf(' ');
                        emoji = label.substring(0, firstSpace);
                        text = label.substring(firstSpace + 1);
                      }
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (emoji.isNotEmpty) Text(emoji),
                            if (emoji.isNotEmpty) const SizedBox(width: 4),
                            Text(text),
                          ],
                        ),
                        labelStyle: TextStyle(
                          color: _value == index ? Colors.white : Colors.black,
                        ),
                        selected: _value == index,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSelected: (bool selected) {
                          setState(() {
                            _value = selected ? index : null;
                            selectedCategory = selected ? avlC[index] : null;
                          });
                        },
                        backgroundColor: Colors.blue.shade50,
                      );
                    }).toList(),
                  ),
                ],
              ),
              if (selectedCategory != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Selected Category: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(selectedCategory!),
                    ],
                  ),
                ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ButtonStyle(
                    alignment: Alignment.center,
                    side: WidgetStateProperty.all(
                      const BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  child: Text(
                    widget.isEdit ? 'Edit Transaction' : 'Add Transaction',
                    style: SafeGoogleFont('Encode Sans SC', fontSize: 18),
                    textScaleFactor: 1.1,
                    selectionColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
