import 'package:flutter/material.dart';
import 'package:new_spendz/Screens/Balance_Overview.dart';
import '../Data/Expense_data.dart';
import '../Model/Expense_item.dart';
import 'Settings.dart';
import 'addTransactionPage.dart';
import 'package:provider/provider.dart';
import 'package:new_spendz/utils.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  // Month filter variables
  late DateTime selectedMonth;
  late List<DateTime> availableMonths;

  // State variables
  bool isEditMode = false;
  double balance = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeAvailableMonths();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    refreshB();
  }

  void didPopNext() {
    refreshB();
  }

  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseData>(context, listen: false).prepareData();

    // Delay the call to _initializeAvailableMonths until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAvailableMonths();
    });

    refreshB();
  }

  void _initializeAvailableMonths() {
    final expenseList = Provider.of<ExpenseData>(
      context,
      listen: false,
    ).getExpenseList();

    setState(() {
      if (expenseList.isEmpty) {
        availableMonths = [selectedMonth];
      } else {
        // Get earliest and latest months
        DateTime earliest = expenseList.first.dateTime;
        DateTime latest = expenseList.first.dateTime;

        for (var expense in expenseList) {
          if (expense.dateTime.isBefore(earliest)) {
            earliest = expense.dateTime;
          }
          if (expense.dateTime.isAfter(latest)) {
            latest = expense.dateTime;
          }
        }

        // Generate all months between earliest and latest
        List<DateTime> months = [];
        DateTime current = DateTime(earliest.year, earliest.month, 1);
        final lastDay = DateTime(latest.year, latest.month + 1, 0);

        while (current.isBefore(lastDay) || current.isAtSameMomentAs(lastDay)) {
          months.add(current);
          current = DateTime(current.year, current.month + 1, 1);
        }

        // Update state
        availableMonths = months;

        // Find the month closest to today
        DateTime today = DateTime.now();
        DateTime closestMonth = months.reduce((a, b) {
          int aDifference =
              (a.year - today.year).abs() * 12 + (a.month - today.month).abs();
          int bDifference =
              (b.year - today.year).abs() * 12 + (b.month - today.month).abs();
          return aDifference < bDifference ? a : b;
        });

        selectedMonth = closestMonth;
      }
    });
  }

  // Get expenses for the selected month
  List<ExpenseItem> _getExpensesForSelectedMonth(List allExpenses) {
    final filtered = allExpenses.whereType<ExpenseItem>().where((expense) {
      return expense.dateTime.year == selectedMonth.year &&
          expense.dateTime.month == selectedMonth.month;
    }).toList();
    return filtered;
  }

  // Navigate to previous month
  void _previousMonth() {
    final currentIndex = availableMonths.indexOf(selectedMonth);
    if (currentIndex > 0) {
      setState(() {
        selectedMonth = availableMonths[currentIndex - 1];
      });
    }
  }

  // Navigate to next month
  void _nextMonth() {
    final currentIndex = availableMonths.indexOf(selectedMonth);
    if (currentIndex < availableMonths.length - 1) {
      setState(() {
        selectedMonth = availableMonths[currentIndex + 1];
      });
    }
  }

  // Check if we can go to previous month
  bool _canGoPrevious() {
    return availableMonths.indexOf(selectedMonth) > 0;
  }

  // Check if we can go to next month
  bool _canGoNext() {
    return availableMonths.indexOf(selectedMonth) < availableMonths.length - 1;
  }

  // Format month for display
  String _formatMonth(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void refreshB() {
    setState(() {
      balance = Provider.of<ExpenseData>(context, listen: false).getBalance();
    });
  }

  IconData getCategoryIcon(String name) {
    String lowercaseName = name.toLowerCase();
    if (lowercaseName.contains('food') ||
        lowercaseName.contains('juice') ||
        lowercaseName.contains('grocery')) {
      return Icons.fastfood; // Use the food icon
    } else if (lowercaseName.contains('education') ||
        lowercaseName.contains('school') ||
        lowercaseName.contains('college') ||
        lowercaseName.contains('xerox') ||
        lowercaseName.contains('pen')) {
      return Icons.school_outlined; // Use the education icon
    } else if (lowercaseName.contains('netflix') ||
        lowercaseName.contains('spotify') ||
        lowercaseName.contains('prime') ||
        lowercaseName.contains('hotstar') ||
        lowercaseName.contains('ott')) {
      return Icons.subscriptions_rounded; // Use the education icon
    } else {
      return Icons.category_outlined; // Use a default icon for other categories
    }
  }

  Widget buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Left arrow button
          SizedBox(
            width: 40,
            height: 40,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _canGoPrevious() ? _previousMonth : null,
                borderRadius: BorderRadius.circular(8),
                child: Icon(
                  Icons.chevron_left,
                  size: 28,
                  color: _canGoPrevious() ? Colors.blue : Colors.grey[300],
                ),
              ),
            ),
          ),
          // Month display
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xfff2f2f7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  _formatMonth(selectedMonth),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // Right arrow button
          SizedBox(
            width: 40,
            height: 40,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _canGoNext() ? _nextMonth : null,
                borderRadius: BorderRadius.circular(8),
                child: Icon(
                  Icons.chevron_right,
                  size: 28,
                  color: _canGoNext() ? Colors.blue : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onWidgetDidAppear() {
    _initializeAvailableMonths();
    // Add your logic here that should run when the widget becomes visible
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;

    return VisibilityDetector(
      key: const Key('HomeScreenVisibilityKey'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0) {
          _onWidgetDidAppear();
        }
      },
      child: Consumer<ExpenseData>(
        builder: (context, value, child) {
          final balance = value.getBalance();
          final expenseList = value.getExpenseList();

          // Sort the expense list by dateTime descending (latest first)
          final sortedExpenseList = List.from(expenseList)
            ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.settings),
                iconSize: 30,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Settings();
                    },
                  );
                },
              ),
              centerTitle: true,
              title: const Text("SpendZ"),
              actions: [
                IconButton(
                  icon: Icon(
                    sortedExpenseList.isEmpty
                        ? Icons.edit
                        : (isEditMode ? Icons.close : Icons.edit),
                  ),
                  iconSize: 30,
                  tooltip: sortedExpenseList.isEmpty
                      ? 'Edit'
                      : (isEditMode ? 'Done' : 'Edit'),
                  onPressed: sortedExpenseList.isEmpty
                      ? null
                      : () {
                          setState(() {
                            isEditMode = !isEditMode;
                          });
                        },
                ),
              ],
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.black,
            ),
            body: Column(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(
                    16 * fem,
                    10 * fem,
                    16 * fem,
                    16 * fem,
                  ),
                  width: double.infinity,
                  height: 110 * fem,
                  decoration: BoxDecoration(
                    color: const Color(0xfff2f2f7),
                    borderRadius: BorderRadius.circular(13 * fem),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0 * fem,
                        top: 0 * fem,
                        child: Align(
                          child: SizedBox(
                            width: 343 * fem,
                            height: 110 * fem,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12 * fem),
                                color: const Color(0x99007aff),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16 * fem,
                        top: 45 * fem,
                        child: Align(
                          child: SizedBox(
                            width: 140 * fem,
                            height: 42 * fem,
                            child: Text(
                              '$balance',
                              style: SafeGoogleFont(
                                'Inter',
                                fontSize: 34 * ffem,
                                fontWeight: FontWeight.w700,
                                height: 1.2125 * ffem / fem,
                                letterSpacing: -0.3700000048 * fem,
                                color: const Color(0xffffffff),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16 * fem,
                        top: 24 * fem,
                        child: Align(
                          child: SizedBox(
                            width: 83 * fem,
                            height: 20 * fem,
                            child: Text(
                              'My Balance',
                              style: SafeGoogleFont(
                                'Inter',
                                fontSize: 15 * ffem,
                                fontWeight: FontWeight.w400,
                                height: 1.3333333333 * ffem / fem,
                                color: const Color(0xffffffff),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 300 * fem,
                        top: 30 * fem,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BalanceOverview(number: balance.toInt()),
                              ),
                            );
                          },
                          child: Align(
                            child: SizedBox(
                              width: 40 * fem,
                              height: 50 * fem,
                              child: Center(
                                child: Center(
                                  child: Icon(
                                    Icons.navigate_next_rounded,
                                    size: 35 * fem,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Transaction History',
                  style: SafeGoogleFont(
                    'Play',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Month Filter Selector
                buildMonthSelector(),
                const SizedBox(height: 12),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      // Filter expenses by selected month
                      final filteredExpenses = _getExpensesForSelectedMonth(
                        sortedExpenseList,
                      ).toList();
                      filteredExpenses.sort(
                        (a, b) => b.dateTime.compareTo(a.dateTime),
                      );

                      return filteredExpenses.isEmpty
                          ? Center(
                              child: Text(
                                'No transactions in ${_formatMonth(selectedMonth)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              reverse: false,
                              padding: const EdgeInsets.only(bottom: 32),
                              itemCount: filteredExpenses.length,
                              itemBuilder: (BuildContext context, int index) {
                                final item = filteredExpenses[index];
                                // Extract emoji from category if present
                                String? emoji;
                                String? category;
                                if (item.name.contains(' - ')) {
                                  final parts = item.name.split(' - ');
                                  category = parts[0];
                                  // If category has emoji, extract it
                                  if (category.contains(' ')) {
                                    int firstSpace = category.indexOf(' ');
                                    emoji = category.substring(0, firstSpace);
                                    category = category.substring(
                                      firstSpace + 1,
                                    );
                                  }
                                }
                                return ListTile(
                                  onTap: () async {
                                    setState(() {
                                      isEditMode = false;
                                    });
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddTransactionPage(
                                              initialItem: item,
                                              itemIndex: value
                                                  .getExpenseList()
                                                  .indexOf(item),
                                              isEdit: true,
                                            ),
                                      ),
                                    );
                                    setState(() {
                                      isEditMode = false;
                                    });
                                  },
                                  leading: emoji != null && emoji.isNotEmpty
                                      ? Container(
                                          width: 40 * fem,
                                          height: 40 * fem,
                                          alignment: Alignment.center,
                                          color: Colors.transparent,
                                          child: Text(
                                            emoji,
                                            style: TextStyle(
                                              fontSize: 28 * fem,
                                            ),
                                          ),
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.blue,
                                          child: Icon(
                                            getCategoryIcon(item.name),
                                            size: 30 * fem,
                                            color: Colors.white,
                                          ),
                                        ),
                                  title: Text(
                                    // Remove category and emoji from title
                                    item.name.contains(' - ')
                                        ? item.name
                                              .split(' - ')
                                              .sublist(1)
                                              .join(' - ')
                                        : item.name,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.dateTime.hour}:${item.dateTime.minute.toString().padLeft(2, '0')} / '
                                        '${item.dateTime.day}.${item.dateTime.month}.${item.dateTime.year.toString().substring(2)}',
                                      ),
                                      if (category != null &&
                                          category.isNotEmpty)
                                        Text(
                                          category,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: isEditMode
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            Provider.of<ExpenseData>(
                                              context,
                                              listen: false,
                                            ).deleteExpense(item);
                                            setState(() {
                                              _initializeAvailableMonths();
                                            });
                                          },
                                        )
                                      : Text(
                                          '₹${item.amount}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: item.type == "income"
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                );
                              },
                            );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTransactionPage()),
                );
              },
              child: const Icon(Icons.add),
              backgroundColor: Colors.blue,
            ),
          );
        },
      ),
    );
  }
}
