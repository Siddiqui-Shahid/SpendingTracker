import 'package:flutter/material.dart';

import '../../core/services/legal_service.dart';
import '../../presentation/widgets/widgets.dart';

/// In-app viewer for Privacy Policy or Terms loaded from Firebase Remote Config.
class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    super.key,
    required this.type,
  });

  final LegalDocumentType type;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  bool _loading = true;
  String _body = '';
  String _updated = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await LegalService.refresh();
    if (!mounted) return;
    setState(() {
      _body = LegalService.body(widget.type);
      _updated = LegalService.lastUpdated(widget.type);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = LegalService.title(widget.type);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: StitchLoadingIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(StitchSpacing.md),
                children: [
                  Text(
                    'Last updated: $_updated',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: StitchSpacing.md),
                  SelectableText(
                    _body.trim(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: context.colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: StitchSpacing.xl),
                ],
              ),
            ),
    );
  }
}
