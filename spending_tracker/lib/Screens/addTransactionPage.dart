import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_spendz/Data/Expense_data.dart';
import 'package:new_spendz/Model/Expense_item.dart';
import 'package:new_spendz/Screens/Settings/Categories.dart';
import '../core/constants/app_strings.dart';
import '../presentation/widgets/widgets.dart';

enum TypeEI { expense, income }

class AddTransactionPage extends StatefulWidget {
  final ExpenseItem? initialItem;
  final int? itemIndex;
  final bool isEdit;

  const AddTransactionPage({
    super.key,
    this.initialItem,
    this.itemIndex,
    this.isEdit = false,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  Set<TypeEI> selectedAccessories = <TypeEI>{TypeEI.expense};
  TypeEI selectedIndex = TypeEI.expense;
  String? title;
  String _amountText = '';
  String? selectedCategory;
  DateTime? dateTime = DateTime.now();
  final TextEditingController _titleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int? _value;

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

  @override
  void initState() {
    super.initState();
    _ensureCategories();
    if (widget.isEdit && widget.initialItem != null) {
      final parsed = CategoryUtils.parseExpenseName(widget.initialItem!.name);
      selectedCategory = parsed.emoji != null && parsed.category != null
          ? '${parsed.emoji} ${parsed.category}'
          : parsed.category;
      title = parsed.title;
      _titleController.text = title ?? '';
      _amountText = widget.initialItem!.amount;
      dateTime = widget.initialItem!.dateTime;
      selectedIndex = widget.initialItem!.type == 'income'
          ? TypeEI.income
          : TypeEI.expense;
      selectedAccessories = {selectedIndex};
      if (selectedCategory != null) {
        _value = avlC.indexWhere((c) => c == selectedCategory);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _ensureCategories() {
    avlC = hive.getCategory();
    if (avlC.isEmpty) {
      hive.setCategory(defaultCategories);
      avlC = List<String>.from(defaultCategories);
    }
  }

  void _appendDigit(String digit) {
    setState(() {
      if (digit == '.' && _amountText.contains('.')) return;
      if (_amountText == '0' && digit != '.') {
        _amountText = digit;
      } else {
        _amountText += digit;
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_amountText.isEmpty) return;
      _amountText = _amountText.substring(0, _amountText.length - 1);
    });
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: dateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: dateTime != null
          ? TimeOfDay(hour: dateTime!.hour, minute: dateTime!.minute)
          : TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (pickedTime == null) return;

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

  void _submitForm() async {
    if (_amountText.isEmpty || double.tryParse(_amountText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    dateTime ??= DateTime.now();
    final type = selectedIndex == TypeEI.expense ? 'expense' : 'income';
    final amt = double.parse(_amountText);
    var displayName = _titleController.text.trim();
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      displayName = '${selectedCategory!} - $displayName';
    }

    final newItem = ExpenseItem(
      name: displayName,
      dateTime: dateTime!,
      amount: amt.toString(),
      type: type,
    );

    final provider = Provider.of<ExpenseData>(context, listen: false);
    if (widget.isEdit && widget.initialItem != null) {
      final updated = provider.updateExpenseItem(widget.initialItem!, newItem);
      if (!updated) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find transaction to update')),
        );
        return;
      }
    } else {
      provider.addExpense(newItem);
    }

    if (!mounted) return;
    await StitchConfirmationDialog.show(
      context: context,
      title: widget.isEdit
          ? 'Transaction Edited'
          : (type == 'expense' ? 'Expense Submitted' : 'Income Submitted'),
      icon: Icons.check_rounded,
      primaryLabel: 'OK',
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit
              ? AppStrings.editTransaction
              : AppStrings.addTransaction,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + StitchSpacing.md,
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.stitchSpacing.gutter,
              ),
              child: SegmentedButton<TypeEI>(
              segments: const [
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
              onSelectionChanged: (selection) {
                setState(() {
                  selectedAccessories = selection;
                  selectedIndex = selection.first;
                });
              },
              ),
            ),
            const SizedBox(height: StitchSpacing.md),
            StitchAmountDisplay(
              amountText: _amountText.isEmpty ? '0' : _amountText,
              label: selectedIndex == TypeEI.expense ? 'Expense' : 'Income',
              isExpense: selectedIndex == TypeEI.expense,
            ),
            StitchNumericKeypad(
              onDigit: _appendDigit,
              onBackspace: _backspace,
              onDecimal: () => _appendDigit('.'),
            ),
            const SizedBox(height: StitchSpacing.md),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.stitchSpacing.gutter,
              ),
              child: StitchAppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: StitchSpacing.md,
                  vertical: StitchSpacing.sm,
                ),
                borderRadius: context.stitchShapes.borderRadiusMd,
                onTap: () => _pickDateTime(context),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: colors.primary),
                    const SizedBox(width: StitchSpacing.md),
                    Expanded(
                      child: Text(
                        dateTime == null
                            ? 'Select date and time'
                            : CategoryUtils.formatDateTime12Hour(dateTime!),
                        style: textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: StitchSpacing.md),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.stitchSpacing.gutter,
              ),
              child: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'What was this for?',
                ),
                textInputAction: TextInputAction.done,
                onChanged: (value) => title = value,
              ),
            ),
            const SizedBox(height: StitchSpacing.md),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.stitchSpacing.gutter,
              ),
              child: Wrap(
                spacing: StitchSpacing.sm,
                runSpacing: StitchSpacing.sm,
                children: List.generate(avlC.length, (index) {
                  final label = avlC[index];
                  var emoji = '';
                  var text = label;
                  if (label.contains(' ')) {
                    final firstSpace = label.indexOf(' ');
                    emoji = label.substring(0, firstSpace);
                    text = label.substring(firstSpace + 1);
                  }
                  return StitchCategoryCard.chip(
                    label: text,
                    emoji: emoji.isNotEmpty ? emoji : null,
                    selected: _value == index,
                    onSelected: (selected) {
                      setState(() {
                        _value = selected ? index : null;
                        selectedCategory = selected ? avlC[index] : null;
                      });
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: StitchSpacing.xl),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.stitchSpacing.gutter,
              ),
              child: StitchPrimaryButton(
                label: widget.isEdit
                    ? AppStrings.editTransaction
                    : AppStrings.addTransaction,
                onPressed: _submitForm,
                expand: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
