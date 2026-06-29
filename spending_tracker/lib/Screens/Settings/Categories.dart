import 'package:flutter/material.dart';
import 'package:new_spendz/Data/hive_database.dart';
import 'package:provider/provider.dart';
import 'package:new_spendz/Data/Expense_data.dart';
import '../../presentation/widgets/widgets.dart';

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

void setData(List<String> categories) {
  hive.setCategory(categories);
}

void getData() {
  final stored = hive.getCategory();
  if (stored.isEmpty) {
    setData(avlC);
    avlC = List<String>.from(avlC);
  } else {
    avlC = List<String>.from(stored);
  }
}

const _pickerEmojis = [
  '🎓',
  '🍔',
  '✈️',
  '📦',
  '💊',
  '🛍️',
  '💡',
  '🎬',
  '🛒',
  '🎁',
  '🚌',
  '🏠',
  '💰',
  '🎮',
  '☕',
  '🏋️',
  '🚗',
  '📱',
  '🐾',
  '✨',
  '🧾',
  '👕',
  '🎵',
  '🏥',
  '📚',
];

const _maxCategoryNameLength = 200;

const _blockedSpecialChars = {
  '.',
  ',',
  '!',
  '?',
  "'",
  '"',
  '-',
  '@',
  '#',
  r'$',
  '%',
  '&',
  '*',
  '(',
  ')',
  '_',
  '=',
  '+',
  '/',
};

String _sanitizeEmojiFieldInput(String raw) {
  for (final grapheme in raw.characters) {
    if (!_isBlockedInputGrapheme(grapheme)) {
      return grapheme;
    }
  }
  return '';
}

bool _isBlockedInputGrapheme(String grapheme) {
  if (grapheme.length == 1 && _blockedSpecialChars.contains(grapheme)) {
    return true;
  }
  for (final unit in grapheme.runes) {
    if ((unit >= 0x41 && unit <= 0x5A) ||
        (unit >= 0x61 && unit <= 0x7A) ||
        (unit >= 0x30 && unit <= 0x39)) {
      return true;
    }
    final ch = String.fromCharCode(unit);
    if (_blockedSpecialChars.contains(ch)) return true;
  }
  return false;
}

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    getData();
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredCategories {
    if (_searchQuery.isEmpty) return avlC;
    return avlC.where((c) {
      final parsed = CategoryUtils.parseCategoryStorage(c);
      return parsed.name.toLowerCase().contains(_searchQuery) ||
          (parsed.emoji?.contains(_searchQuery) ?? false);
    }).toList();
  }

  void _showAddCategorySheet() {
    final nameController = TextEditingController();
    final customEmojiController = TextEditingController();
    String? selectedEmoji;
    final formKey = GlobalKey<FormState>();
    final emojiFocusNode = FocusNode();
    final nameFocusNode = FocusNode();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
            final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
            final colors = context.colors;

            void focusCategoryName() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (nameFocusNode.canRequestFocus) {
                  nameFocusNode.requestFocus();
                }
              });
            }

            void applyEmoji(String? emoji, {bool moveToName = false}) {
              setSheetState(() {
                selectedEmoji = emoji;
                if (emoji == null) {
                  customEmojiController.clear();
                } else {
                  customEmojiController.text = emoji;
                  customEmojiController.selection = TextSelection.collapsed(
                    offset: emoji.characters.length,
                  );
                }
              });
              if (moveToName && emoji != null) {
                focusCategoryName();
              }
            }

            void selectSuggested(String emoji) {
              applyEmoji(emoji, moveToName: true);
            }

            void updateCustomEmoji(String value) {
              final sanitized = _sanitizeEmojiFieldInput(value);
              final hadEmoji = selectedEmoji != null;

              if (sanitized != value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!emojiFocusNode.hasFocus) return;
                  customEmojiController.value = TextEditingValue(
                    text: sanitized,
                    selection: TextSelection.collapsed(
                      offset: sanitized.characters.length,
                    ),
                  );
                });
              }

              setSheetState(() {
                selectedEmoji = sanitized.isEmpty ? null : sanitized;
              });

              if (sanitized.isNotEmpty && !hadEmoji) {
                focusCategoryName();
              }
            }

            Widget emojiTile(String emoji) {
              final isSelected = selectedEmoji == emoji;
              return InkWell(
                onTap: () => selectSuggested(emoji),
                borderRadius: context.stitchShapes.borderRadiusMd,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primaryContainer
                        : colors.surfaceContainerHigh,
                    borderRadius: context.stitchShapes.borderRadiusMd,
                    border: Border.all(
                      color: isSelected
                          ? colors.primary
                          : colors.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: StitchSpacing.md,
                right: StitchSpacing.md,
                bottom: bottomInset + StitchSpacing.md,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Add Category',
                          style: context.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: StitchSpacing.md),
                        Text(
                          'Choose an emoji *',
                          style: context.textTheme.labelLarge,
                        ),
                        const SizedBox(height: StitchSpacing.sm),
                        Wrap(
                          spacing: StitchSpacing.sm,
                          runSpacing: StitchSpacing.sm,
                          children: [
                            for (final emoji in _pickerEmojis) emojiTile(emoji),
                          ],
                        ),
                        const SizedBox(height: StitchSpacing.md),
                        Text(
                          'Or use a custom emoji',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: StitchSpacing.sm),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 88,
                              child: TextFormField(
                                controller: customEmojiController,
                                focusNode: emojiFocusNode,
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleLarge,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'Emoji *',
                                  hintText: '🙂',
                                  hintStyle: context.textTheme.titleLarge
                                      ?.copyWith(
                                        color: colors.onSurfaceVariant
                                            .withValues(alpha: 0.45),
                                      ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: StitchSpacing.md,
                                    vertical: StitchSpacing.md,
                                  ),
                                ),
                                onChanged: updateCustomEmoji,
                                onFieldSubmitted: (_) => focusCategoryName(),
                              ),
                            ),
                            const SizedBox(width: StitchSpacing.sm),
                            Expanded(
                              child: TextFormField(
                                controller: nameController,
                                focusNode: nameFocusNode,
                                maxLength: _maxCategoryNameLength,
                                decoration: const InputDecoration(
                                  labelText: 'Category name *',
                                  hintText: 'e.g. Transport',
                                  counterText: '',
                                ),
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter a category name';
                                  }
                                  if (value.trim().length >
                                      _maxCategoryNameLength) {
                                    return 'Max $_maxCategoryNameLength characters';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        if (selectedEmoji == null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: StitchSpacing.xs,
                            ),
                            child: Text(
                              'Pick a suggested emoji or enter one custom emoji',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        const SizedBox(height: StitchSpacing.md),
                        StitchPrimaryButton(
                          label: 'Add Category',
                          icon: Icons.add_rounded,
                          expand: true,
                          onPressed: () {
                            if (selectedEmoji == null ||
                                selectedEmoji!.trim().isEmpty) {
                              setSheetState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please select or enter an emoji',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (!formKey.currentState!.validate()) return;

                            final name = nameController.text.trim();
                            final entry = '$selectedEmoji $name';
                            if (avlC.any(
                              (c) => c.toLowerCase() == entry.toLowerCase(),
                            )) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Category already exists'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              avlC.add(entry);
                              setData(avlC);
                            });
                            Navigator.of(sheetContext).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      customEmojiController.dispose();
      emojiFocusNode.dispose();
      nameFocusNode.dispose();
    });
  }

  void _confirmDeleteCategory(int index) {
    if (avlC.length <= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 4 categories are required')),
      );
      return;
    }

    final parsed = CategoryUtils.parseCategoryStorage(avlC[index]);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(StitchSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Delete ${parsed.name}?', style: context.textTheme.titleLarge),
            const SizedBox(height: StitchSpacing.sm),
            Text(
              'This removes the category from your list. Existing transactions are not deleted.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: StitchSpacing.lg),
            StitchPrimaryButton(
              label: 'Delete',
              expand: true,
              onPressed: () {
                setState(() {
                  avlC.removeAt(index);
                  setData(avlC);
                  _selectedIndex = null;
                });
                Navigator.of(sheetContext).pop();
              },
            ),
            const SizedBox(height: StitchSpacing.sm),
            StitchSecondaryButton(
              label: 'Cancel',
              expand: true,
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final filtered = _filteredCategories;

    return Consumer<ExpenseData>(
      builder: (context, expenseData, _) {
        final expenses = expenseData.getExpenseList();

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Categories'),
            centerTitle: true,
            actions: [
              if (_selectedIndex != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Delete category',
                  onPressed: () => _confirmDeleteCategory(_selectedIndex!),
                ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.stitchSpacing.gutter,
                    StitchSpacing.sm,
                    context.stitchSpacing.gutter,
                    StitchSpacing.md,
                  ),
                  child: Material(
                    color: colors.primaryContainer,
                    borderRadius: context.stitchShapes.borderRadiusXxl,
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(StitchSpacing.lg),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Categories',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: colors.onPrimaryContainer.withValues(
                                      alpha: 0.85,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: StitchSpacing.xs),
                                Text(
                                  '${avlC.length} Active',
                                  style: textTheme.displayMedium?.copyWith(
                                    color: colors.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: colors.onPrimaryContainer.withValues(
                                alpha: 0.12,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.category_rounded,
                              size: 28,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: StitchSearchField(
                  controller: _searchController,
                  hintText: 'Search categories',
                  onChanged: (_) {},
                ),
              ),
              if (filtered.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: StitchEmptyState(
                    message: 'No categories match your search',
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.stitchSpacing.gutter,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: StitchSpacing.md,
                      crossAxisSpacing: StitchSpacing.md,
                      mainAxisExtent: StitchCategoryGridCard.tileHeight(
                        Theme.of(context).textTheme,
                      ),
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final stored = filtered[index];
                      final globalIndex = avlC.indexOf(stored);
                      final parsed = CategoryUtils.parseCategoryStorage(stored);
                      final emoji = parsed.emoji ?? '📁';
                      final txCount = CategoryUtils.transactionCountForCategory(
                        stored,
                        expenses,
                      );

                      return StitchCategoryGridCard(
                        label: parsed.name,
                        emoji: emoji,
                        transactionCount: txCount,
                        selected: _selectedIndex == globalIndex,
                        onTap: () {
                          setState(() {
                            _selectedIndex = _selectedIndex == globalIndex
                                ? null
                                : globalIndex;
                          });
                        },
                        onLongPress: () => _confirmDeleteCategory(globalIndex),
                      );
                    }, childCount: filtered.length),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddCategorySheet,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Category'),
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.onPrimaryContainer,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: context.stitchShapes.borderRadiusPill,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}
