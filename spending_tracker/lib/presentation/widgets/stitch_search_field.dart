import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Search bar for transaction history (Stitch Transaction History screen).
class StitchSearchField extends StatefulWidget {
  const StitchSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Search transactions',
    this.onChanged,
    this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  State<StitchSearchField> createState() => _StitchSearchFieldState();
}

class _StitchSearchFieldState extends State<StitchSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(StitchSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.stitchSpacing.gutter,
        vertical: context.stitchSpacing.sm,
      ),
      child: Semantics(
        textField: true,
        label: widget.hintText,
        child: SearchBar(
          controller: widget.controller,
          hintText: widget.hintText,
          leading: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
          trailing: [
            if (widget.controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Clear search',
                onPressed: () {
                  widget.controller.clear();
                  widget.onClear?.call();
                  widget.onChanged?.call('');
                },
              ),
          ],
          onChanged: widget.onChanged,
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(colors.surfaceContainerHigh),
          side: WidgetStatePropertyAll(
            BorderSide(color: colors.outlineVariant),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: context.stitchShapes.borderRadiusMd,
            ),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: StitchSpacing.sm),
          ),
        ),
      ),
    );
  }
}
