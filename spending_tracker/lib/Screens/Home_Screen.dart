import 'package:flutter/material.dart';
import 'package:new_spendz/Screens/Balance_Overview.dart';
import '../Data/Expense_data.dart';
import 'Settings.dart';
import 'addTransactionPage.dart';
import 'package:provider/provider.dart';
import 'package:new_spendz/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshB();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    refreshB();
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen via Navigator
    refreshB();
  }

  bool isEditMode = false;
  double balance = 0;
  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseData>(context, listen: false).prepareData();
    refreshB();
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

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return Consumer<ExpenseData>(
      builder: (context, value, child) {
        final balance = value.getBalance();
        debugPrint('[HomeScreen] Consumer rebuilt. Current balance: $balance');
        final expenseList = value.getExpenseList();
        debugPrint('[HomeScreen] Expense list length: ${expenseList.length}');
        // Sort the expense list by dateTime descending (latest first)
        final sortedExpenseList = List.from(expenseList)
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
        if (sortedExpenseList.isNotEmpty) {
          debugPrint(
            '[HomeScreen] First expense: ${sortedExpenseList.first.name}, amount: ${sortedExpenseList.first.amount}, date: ${sortedExpenseList.first.dateTime}',
          );
        }
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
              Expanded(
                child: sortedExpenseList.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        reverse: false,
                        padding: const EdgeInsets.only(bottom: 32),
                        itemCount: sortedExpenseList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = sortedExpenseList[index];
                          // Extract emoji from category if present
                          String? emoji;
                          String? category;
                          if (item.name.contains(' - ')) {
                            final parts = item.name.split(' - ');
                            category = parts[0];
                            // If category has emoji, extract it
                            if (category != null && category.contains(' ')) {
                              int firstSpace = category.indexOf(' ');
                              emoji = category.substring(0, firstSpace);
                              category = category.substring(firstSpace + 1);
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
                                  builder: (context) => AddTransactionPage(
                                    initialItem: item,
                                    itemIndex: value.getExpenseList().indexOf(
                                      item,
                                    ),
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
                                      style: TextStyle(fontSize: 28 * fem),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.dateTime.hour}:${item.dateTime.minute.toString().padLeft(2, '0')} / '
                                  '${item.dateTime.day}.${item.dateTime.month}.${item.dateTime.year.toString().substring(2)}',
                                ),
                                if (category != null && category.isNotEmpty)
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
    );
  }
}
