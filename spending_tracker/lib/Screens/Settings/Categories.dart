import 'package:flutter/material.dart';
import 'package:new_spendz/Data/hive_database.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});
  @override
  State<Categories> createState() => _Categories();
}

final hive = HiveDataBase();
List<String> avlC = [
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
String newCategory = '';
String newCategoryEmoji = '';

void setData(aC) async {
  hive.setCategory(aC);
  //print('List saved to Hive.');
}

void getData() async {
  List<String> aC = hive.getCategory();
  if (aC.isEmpty) {
    setData(avlC);
    aC = List<String>.from(avlC);
  }
  avlC = aC;
}

void resetNewCategoryInputs() {
  newCategory = '';
  newCategoryEmoji = '';
}

int value = 27;

class _Categories extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Categories"),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              setData(avlC);
              getData();
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
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: (value == index) ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                selected: value == index,
                onSelected: (bool selected) {
                  setState(() {
                    value = selected ? index : 27;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4.0,
              );
            }, childCount: avlC.length),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showDialog(
                        context: context,
                        builder: (BuildContext) {
                          resetNewCategoryInputs();
                          return AlertDialog(
                            title: const Text('Add New Category'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    hintText: "Enter category name",
                                  ),
                                  onChanged: (value) {
                                    newCategory = value;
                                  },
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  decoration: const InputDecoration(
                                    hintText: "Enter emoji (optional)",
                                  ),
                                  onChanged: (value) {
                                    newCategoryEmoji = value;
                                  },
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('ADD'),
                                onPressed: () {
                                  setState(() {
                                    if (newCategory.isNotEmpty) {
                                      String cat = newCategory.trim();
                                      if (newCategoryEmoji.isNotEmpty) {
                                        cat =
                                            newCategoryEmoji.trim() + ' ' + cat;
                                      }
                                      avlC.add(cat);
                                    }
                                    Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
                      setData(avlC);
                      getData();
                    });
                  },
                  child: const Text('ADD CATEGORY'),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                // child: Visibility(
                //   visible: (value!=69),
                child: ElevatedButton(
                  onPressed: (value != 69 && avlC.isNotEmpty)
                      ? () {
                          if (avlC.length <= 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "At least 4 Categories are Required",
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40.0),
                                ),
                                backgroundColor: Colors.black45,
                              ),
                            );
                          } else {
                            setState(() {
                              avlC.remove(avlC[value]);
                              setData(avlC);
                              getData();
                            });
                          }
                        }
                      : null,
                  child: Text(
                    'REMOVE',
                    style: TextStyle(
                      color: (value != 69 && avlC.isNotEmpty)
                          ? Colors.red
                          : null,
                    ),
                  ),
                ),
              ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
