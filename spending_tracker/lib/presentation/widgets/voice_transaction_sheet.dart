import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/constants/app_strings.dart';
import '../../core/services/voice_tutorial_service.dart';
import '../../core/theme/theme.dart';
import '../../core/utils/category_utils.dart';
import '../../core/voice/voice_input_log.dart';
import '../../core/voice/voice_transaction_parser.dart';
import 'stitch_confirmation_dialog.dart';
import 'stitch_primary_button.dart';
import 'stitch_secondary_button.dart';

/// Voice form sheet — fills add-transaction fields as the user speaks.
class VoiceTransactionSheet extends StatefulWidget {
  const VoiceTransactionSheet({
    super.key,
    required this.knownCategories,
  });

  final List<String> knownCategories;

  static Future<VoiceTransactionDraft?> show(
    BuildContext context, {
    required List<String> knownCategories,
  }) {
    VoiceInputLog.d('sheet.open', {
      'knownCategories': knownCategories.length,
      'listenForSec': _VoiceTransactionSheetState._listenFor.inSeconds,
      'pauseForSec': _VoiceTransactionSheetState._pauseFor.inSeconds,
    });
    return showModalBottomSheet<VoiceTransactionDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => VoiceTransactionSheet(
        knownCategories: knownCategories,
      ),
    );
  }

  @override
  State<VoiceTransactionSheet> createState() => _VoiceTransactionSheetState();
}

enum _VoiceActiveField { none, type, amount, title, date, category }

class _VoiceTransactionSheetState extends State<VoiceTransactionSheet>
    with TickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  late final AnimationController _pulse;
  late final AnimationController _hintFade;

  bool _ready = false;
  bool _listening = false;
  bool _userStopped = false;
  bool _showTutorial = false;
  bool _confirmOpen = false;
  String _status = 'Preparing microphone…';
  /// Stable transcript kept across empty partials / new listen sessions.
  String _committedTranscript = '';
  /// Current engine utterance (can be wiped by Android — we don't trust empties).
  String _liveUtterance = '';
  String? _error;
  VoiceTransactionDraft _draft = const VoiceTransactionDraft();
  _VoiceActiveField _activeField = _VoiceActiveField.none;

  static const _listenFor = Duration(minutes: 3);
  static const _pauseFor = Duration(seconds: 7);

  static _VoiceActiveField _detectActiveField(String utterance) {
    final t = utterance.toLowerCase();
    if (RegExp(r'\b(title|label|for)\b').hasMatch(t)) {
      return _VoiceActiveField.title;
    }
    if (RegExp(r'\b(amount|rupees?|rs|inr|dollars?)\b').hasMatch(t)) {
      return _VoiceActiveField.amount;
    }
    if (RegExp(r'\b(date|today|yesterday)\b').hasMatch(t) ||
        RegExp(
          r'\b\d{1,2}(?:st|nd|rd|th)?\s+(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)',
          caseSensitive: false,
        ).hasMatch(t)) {
      return _VoiceActiveField.date;
    }
    if (RegExp(r'\b(category|cat|no\s+category)\b').hasMatch(t)) {
      return _VoiceActiveField.category;
    }
    if (RegExp(r'\b(expense|income|spent|spend)\b').hasMatch(t)) {
      return _VoiceActiveField.type;
    }
    return _VoiceActiveField.none;
  }

  String get _displayTranscript {
    final live = _liveUtterance.trim();
    final committed = _committedTranscript.trim();
    if (committed.isEmpty) return live;
    if (live.isEmpty) return committed;
    if (committed.endsWith(live) || committed.contains(live)) return committed;
    return '$committed $live'.trim();
  }

  @override
  void initState() {
    super.initState();
    final seen = VoiceTutorialService.hasSeen();
    _showTutorial = !seen;
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _hintFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: _showTutorial ? 1 : 0,
    );
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    VoiceInputLog.d('bootstrap.start');
    final sw = Stopwatch()..start();
    try {
      final available = await _speech.initialize(
        onError: (error) {
          VoiceInputLog.warn(
            'speech.onError',
            '${error.errorMsg} permanent=${error.permanent}',
          );
          if (!mounted) return;
          setState(() {
            _error = error.errorMsg;
            _listening = false;
            _status = 'Tap mic to try again';
          });
        },
        onStatus: (status) {
          if (!mounted) return;
          VoiceInputLog.d('speech.onStatus', {
            'status': status,
            'listening': _listening,
            'userStopped': _userStopped,
            'committedLen': _committedTranscript.length,
            'liveLen': _liveUtterance.length,
          });
          if (status == 'done' || status == 'notListening') {
            final wasListening = _listening;
            _commitLiveUtterance();
            setState(() {
              _listening = false;
              _liveUtterance = '';
              _status = _draft.hasAnyField
                  ? 'Still with you — keep talking or tap Done'
                  : 'Listening for transaction details…';
            });
            if (wasListening && !_userStopped && _ready && !_confirmOpen) {
              VoiceInputLog.d('speech.autoResume.scheduled', {'delayMs': 250});
              Future<void>.delayed(const Duration(milliseconds: 250), () {
                if (mounted &&
                    !_userStopped &&
                    !_listening &&
                    _ready &&
                    !_confirmOpen) {
                  VoiceInputLog.d('speech.autoResume.firing');
                  unawaited(_startListening(restart: true));
                }
              });
            }
          }
        },
      );
      if (!mounted) return;
      VoiceInputLog.d('bootstrap.initialize', {
        'available': available,
        'elapsedMs': sw.elapsedMilliseconds,
      });
      if (!available) {
        setState(() {
          _ready = false;
          _error = 'Speech recognition is not available on this device.';
          _status = 'Unavailable';
        });
        VoiceInputLog.warn('bootstrap.unavailable');
        return;
      }
      setState(() {
        _ready = true;
        _status = 'Listening — fill the form by voice';
      });
      await _startListening();
    } catch (e, st) {
      VoiceInputLog.warn('bootstrap.exception $e\n$st');
      if (!mounted) return;
      setState(() {
        _ready = false;
        _error = 'Could not start voice input.';
        _status = 'Unavailable';
      });
    }
  }

  void _commitLiveUtterance() {
    final live = _liveUtterance.trim();
    if (live.isEmpty) return;
    if (VoiceTransactionParser.isFinishCommand(live)) return;
    final committed = _committedTranscript.trim();
    if (committed.isEmpty) {
      _committedTranscript = live;
    } else if (live.startsWith(committed) || committed.startsWith(live)) {
      _committedTranscript =
          live.length >= committed.length ? live : committed;
    } else if (!committed.contains(live)) {
      _committedTranscript = '$committed $live';
    }
    VoiceInputLog.d('transcript.commit', {
      'committed': _committedTranscript,
    });
  }

  void _ingestSpeech(String words, {required bool isFinal}) {
    final trimmed = words.trim();
    if (trimmed.isEmpty) {
      VoiceInputLog.d('speech.onResult.ignoredEmpty', {'final': isFinal});
      return;
    }

    // Saying "done" finishes entry — never treat it as a title.
    if (VoiceTransactionParser.isFinishCommand(trimmed)) {
      VoiceInputLog.d('speech.finishCommand', {'words': trimmed});
      unawaited(_done());
      return;
    }

    final prevLive = _liveUtterance.trim();
    final lower = trimmed.toLowerCase();
    final prevLower = prevLive.toLowerCase();

    if (prevLive.isEmpty) {
      _liveUtterance = trimmed;
    } else if (lower.startsWith(prevLower) || prevLower.startsWith(lower)) {
      _liveUtterance = trimmed.length >= prevLive.length ? trimmed : prevLive;
    } else {
      _commitLiveUtterance();
      _liveUtterance = trimmed;
      VoiceInputLog.d('speech.newSegment', {'prev': prevLive, 'next': trimmed});
    }

    // Keep committed in sync while Android rarely sends final=true.
    final liveNow = _liveUtterance.trim();
    final committed = _committedTranscript.trim();
    if (committed.isEmpty ||
        liveNow.startsWith(committed) ||
        committed.startsWith(liveNow)) {
      if (liveNow.length >= committed.length) {
        _committedTranscript = liveNow;
      }
    }

    // Parse current segment only, then sticky-merge (protects title).
    final incoming = VoiceTransactionParser.parse(
      _liveUtterance,
      knownCategories: widget.knownCategories,
    );
    final merged = _draft.merge(incoming);
    var active = _detectActiveField(_liveUtterance);
    if (active == _VoiceActiveField.none) {
      if (incoming.titleFromKeyword ||
          (incoming.title != null &&
              incoming.title!.trim().isNotEmpty &&
              incoming.title != _draft.title)) {
        active = _VoiceActiveField.title;
      } else if (incoming.amount != null && incoming.amount != _draft.amount) {
        active = _VoiceActiveField.amount;
      } else if (incoming.date != null && incoming.date != _draft.date) {
        active = _VoiceActiveField.date;
      } else if ((incoming.hasCategory || incoming.noCategory) &&
          (incoming.category != _draft.category ||
              incoming.noCategory != _draft.noCategory)) {
        active = _VoiceActiveField.category;
      } else if (incoming.type != null && incoming.type != _draft.type) {
        active = _VoiceActiveField.type;
      }
    }
    VoiceInputLog.d('speech.onResult', {
      'final': isFinal,
      'words': trimmed,
      'live': _liveUtterance,
      'committed': _committedTranscript,
      'activeField': active.name,
    });
    VoiceInputLog.draft('parse.merged', merged);

    setState(() {
      _draft = merged;
      _activeField = active;
      _error = null;
      _status =
          isFinal ? 'Got it — keep talking or tap Done' : 'Listening…';
    });

    if (isFinal) {
      _commitLiveUtterance();
      setState(() => _liveUtterance = '');
    }
  }

  Future<void> _startListening({bool restart = false}) async {
    if (!_ready || _listening) {
      VoiceInputLog.d('listen.skip', {
        'ready': _ready,
        'listening': _listening,
        'restart': restart,
      });
      return;
    }
    VoiceInputLog.d('listen.start', {
      'restart': restart,
      'listenForSec': _listenFor.inSeconds,
      'pauseForSec': _pauseFor.inSeconds,
      'committedLen': _committedTranscript.length,
    });
    setState(() {
      _error = null;
      _userStopped = false;
      _listening = true;
      _status = restart ? 'Still listening…' : 'Listening…';
    });

    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        _ingestSpeech(result.recognizedWords, isFinal: result.finalResult);
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
        listenFor: _listenFor,
        pauseFor: _pauseFor,
        localeId: 'en_US',
      ),
    );
    VoiceInputLog.d('listen.callReturned', {
      'listening': _listening,
      'isListeningPlugin': _speech.isListening,
    });
  }

  Future<void> _stopListening({bool pauseOnly = false}) async {
    VoiceInputLog.d('listen.stop', {
      'pauseOnly': pauseOnly,
      'committedLen': _committedTranscript.length,
    });
    if (!pauseOnly) _userStopped = true;
    _commitLiveUtterance();
    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _listening = false;
      _liveUtterance = '';
      _status = _draft.hasAnyField
          ? 'Paused — tap mic to continue or Done to apply'
          : 'Tap the mic and speak';
    });
  }

  Future<void> _toggleMic() async {
    VoiceInputLog.d('mic.toggle', {
      'ready': _ready,
      'listening': _listening,
    });
    if (!_ready) return;
    if (_listening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _done() async {
    if (_confirmOpen) return;
    _userStopped = true;
    _confirmOpen = true;
    await _speech.stop();
    _commitLiveUtterance();

    var draft = _draft;
    final committed = _committedTranscript.trim();
    if (committed.isNotEmpty &&
        !VoiceTransactionParser.isFinishCommand(committed)) {
      draft = draft.merge(
        VoiceTransactionParser.parse(
          committed,
          knownCategories: widget.knownCategories,
        ),
      );
    }
    setState(() {
      _draft = draft;
      _listening = false;
      _liveUtterance = '';
    });

    VoiceInputLog.d('done.tap', {
      'committed': committed,
      'preview': draft.previewSummary(),
      'missing': draft.missingRequired.join(','),
    });
    VoiceInputLog.draft('done.draft', draft);

    final missing = draft.missingRequired;
    if (missing.isNotEmpty) {
      final label = missing
          .map((m) => switch (m) {
                'type' => 'type (expense/income)',
                'amount' => 'amount',
                'title' => 'title',
                _ => m,
              })
          .join(', ');
      VoiceInputLog.warn('done.rejected.missing=$label');
      if (!mounted) return;
      setState(() {
        _error = 'Need $label before finishing. Keep speaking, then say done.';
        _confirmOpen = false;
        _userStopped = false;
        _status = 'Missing required fields';
      });
      unawaited(_startListening(restart: true));
      return;
    }

    final resolved = draft.hasCategory || draft.noCategory
        ? draft
        : VoiceTransactionDraft(
            type: draft.type,
            amount: draft.amount,
            title: draft.title,
            date: draft.date,
            category: null,
            noCategory: true,
            titleFromKeyword: draft.titleFromKeyword,
          );

    if (!mounted) return;
    var applied = false;
    await StitchConfirmationDialog.show(
      context: context,
      title: 'Use this transaction?',
      message: resolved.previewSummary(),
      icon: Icons.check_circle_outline_rounded,
      primaryLabel: 'Yes',
      secondaryLabel: 'Keep talking',
      onPrimary: () {
        applied = true;
        _confirmOpen = false;
        VoiceInputLog.draft('done.pop', resolved);
        Navigator.of(context).pop(resolved);
      },
      onSecondary: () {
        VoiceInputLog.d('done.keepTalking');
        if (!mounted) return;
        setState(() {
          _confirmOpen = false;
          _userStopped = false;
          _error = null;
          _status = 'Listening…';
        });
        unawaited(_startListening(restart: true));
      },
    );
    // Barrier dismiss without Yes / Keep talking.
    if (mounted && !applied && _confirmOpen) {
      setState(() {
        _confirmOpen = false;
        _userStopped = false;
      });
      unawaited(_startListening(restart: true));
    }
  }

  @override
  void dispose() {
    VoiceInputLog.d('sheet.dispose', {
      'committedLen': _committedTranscript.length,
      'listening': _listening,
    });
    _userStopped = true;
    unawaited(_speech.cancel());
    _pulse.dispose();
    _hintFade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final height = MediaQuery.sizeOf(context).height;

    return Container(
      height: height * 0.94,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.surfaceContainerLow,
            colors.surface,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: StitchSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                StitchSpacing.lg,
                StitchSpacing.md,
                StitchSpacing.sm,
                StitchSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fill with voice',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Speak the fields — watch the form fill in',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: _showTutorial ? 'Hide tips' : 'Show tips',
                    onPressed: () {
                      setState(() {
                        _showTutorial = !_showTutorial;
                        if (_showTutorial) {
                          _hintFade.forward();
                        } else {
                          _hintFade.reverse();
                          unawaited(VoiceTutorialService.markSeen());
                        }
                      });
                    },
                    icon: Icon(
                      _showTutorial
                          ? Icons.lightbulb_rounded
                          : Icons.lightbulb_outline_rounded,
                      color: colors.primary,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  StitchSpacing.lg,
                  0,
                  StitchSpacing.lg,
                  bottom + StitchSpacing.md,
                ),
                children: [
                  SizeTransition(
                    sizeFactor: _hintFade,
                    axisAlignment: -1,
                    child: FadeTransition(
                      opacity: _hintFade,
                      child: _VoiceTutorialCard(
                        onDismiss: () {
                          setState(() => _showTutorial = false);
                          _hintFade.reverse();
                          unawaited(VoiceTutorialService.markSeen());
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: StitchSpacing.md),
                  _LiveVoiceFormCard(
                    draft: _draft,
                    knownCategories: widget.knownCategories,
                    activeField: _activeField,
                  ),
                  const SizedBox(height: StitchSpacing.md),
                  _TransactionGuessCard(draft: _draft),
                  const SizedBox(height: StitchSpacing.lg),
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        final t = _listening ? _pulse.value : 0.0;
                        return SizedBox(
                          width: 200,
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              for (var i = 0; i < 3; i++)
                                _PulseRing(
                                  progress: (t + i * 0.22) % 1.0,
                                  color: colors.primary.withValues(
                                    alpha: _listening ? 0.28 - i * 0.07 : 0,
                                  ),
                                ),
                              child!,
                            ],
                          ),
                        );
                      },
                      child: Material(
                        color: _listening
                            ? colors.primary
                            : colors.secondaryContainer,
                        shape: const CircleBorder(),
                        elevation: _listening ? 10 : 2,
                        shadowColor: colors.primary.withValues(alpha: 0.45),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _ready ? _toggleMic : null,
                          child: SizedBox(
                            width: 96,
                            height: 96,
                            child: Icon(
                              _listening
                                  ? Icons.pause_rounded
                                  : Icons.mic_rounded,
                              size: 40,
                              color: _listening
                                  ? colors.onPrimary
                                  : colors.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    _status,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: StitchSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(StitchSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.55,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Text(
                      _displayTranscript.isEmpty
                          ? 'Your speech appears here…'
                          : _displayTranscript,
                      style: textTheme.bodyLarge?.copyWith(
                        color: _displayTranscript.isEmpty
                            ? colors.onSurfaceVariant
                            : colors.onSurface,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: StitchSpacing.sm),
                    Text(
                      _error!,
                      style: textTheme.bodySmall?.copyWith(color: colors.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: StitchSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: StitchSecondaryButton(
                          label: 'Cancel',
                          onPressed: () {
                            _userStopped = true;
                            unawaited(_speech.cancel());
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const SizedBox(width: StitchSpacing.md),
                      Expanded(
                        child: StitchPrimaryButton(
                          label: 'Done',
                          icon: Icons.check_rounded,
                          onPressed: _draft.hasAnyField ? _done : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionGuessCard extends StatelessWidget {
  const _TransactionGuessCard({required this.draft});

  final VoiceTransactionDraft draft;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final summary = draft.previewSummary();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(StitchSpacing.md),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: colors.onTertiaryContainer,
            size: 22,
          ),
          const SizedBox(width: StitchSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.hasAnyField
                      ? 'This might be your transaction'
                      : 'Transaction guess',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onTertiaryContainer,
                  ),
                ),
                const SizedBox(height: StitchSpacing.xs),
                Text(
                  summary,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onTertiaryContainer,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceTutorialCard extends StatelessWidget {
  const _VoiceTutorialCard({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(StitchSpacing.md),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_rounded, color: colors.primary, size: 22),
              const SizedBox(width: StitchSpacing.sm),
              Expanded(
                child: Text(
                  'Quick tutorial',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              TextButton(
                onPressed: onDismiss,
                child: const Text('Got it'),
              ),
            ],
          ),
          const SizedBox(height: StitchSpacing.sm),
          Text(
            'Say each field like filling a form:',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: StitchSpacing.sm),
          const _TutorialStep(
            number: '1',
            text: 'Type — “expense” or “income”',
          ),
          const _TutorialStep(
            number: '2',
            text: 'Amount — “amount 250”',
          ),
          const _TutorialStep(
            number: '3',
            text: 'Title — “title lunch” or just say the name after amount',
          ),
          const _TutorialStep(
            number: '4',
            text: 'Date — “today”, “yesterday”, or “date 15/03”',
          ),
          const _TutorialStep(
            number: '5',
            text: 'Category — “category Food” or “no category”',
          ),
          const SizedBox(height: StitchSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(StitchSpacing.sm),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Example: expense 250 title lunch date today category Food\nAlso works: expense 200 Vada Pav today Food',
              style: textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialStep extends StatelessWidget {
  const _TutorialStep({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: StitchSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: StitchSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveVoiceFormCard extends StatelessWidget {
  const _LiveVoiceFormCard({
    required this.draft,
    required this.knownCategories,
    required this.activeField,
  });

  final VoiceTransactionDraft draft;
  final List<String> knownCategories;
  final _VoiceActiveField activeField;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final dateFormat = DateFormat('d MMM yyyy');
    final typeActive = activeField == _VoiceActiveField.type;

    final amountValue = draft.amount == null
        ? '—'
        : '${AppStrings.currencySymbol}${draft.amount == draft.amount!.roundToDouble() ? draft.amount!.toInt() : draft.amount}';

    final titleValue =
        (draft.title == null || draft.title!.trim().isEmpty) ? '—' : draft.title!;

    final dateValue =
        draft.date == null ? '—' : dateFormat.format(draft.date!);

    String categoryValue;
    if (draft.noCategory ||
        draft.category == null ||
        draft.category!.trim().isEmpty) {
      categoryValue = 'No category';
    } else {
      categoryValue = draft.category!;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(StitchSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: typeActive ? colors.primary : colors.outlineVariant,
          width: typeActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: colors.primary),
              const SizedBox(width: StitchSpacing.sm),
              Text(
                'Transaction form',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: StitchSpacing.md),
          Text(
            'Type',
            style: textTheme.labelLarge?.copyWith(
              color: typeActive ? colors.primary : colors.onSurfaceVariant,
              fontWeight: typeActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: StitchSpacing.xs),
          Row(
            children: [
              Expanded(
                child: _TypeSelectChip(
                  label: 'Expense',
                  icon: Icons.remove_circle_outline,
                  selected: draft.type == VoiceTransactionType.expense,
                  active: typeActive &&
                      draft.type == VoiceTransactionType.expense,
                ),
              ),
              const SizedBox(width: StitchSpacing.sm),
              Expanded(
                child: _TypeSelectChip(
                  label: 'Income',
                  icon: Icons.add_circle_outline,
                  selected: draft.type == VoiceTransactionType.income,
                  active: typeActive &&
                      draft.type == VoiceTransactionType.income,
                ),
              ),
            ],
          ),
          const SizedBox(height: StitchSpacing.sm),
          _FormFieldRow(
            icon: Icons.payments_outlined,
            label: 'Amount',
            value: amountValue,
            filled: draft.amount != null,
            active: activeField == _VoiceActiveField.amount,
          ),
          _FormFieldRow(
            icon: Icons.title_rounded,
            label: 'Title',
            value: titleValue,
            filled: draft.title != null && draft.title!.trim().isNotEmpty,
            active: activeField == _VoiceActiveField.title ||
                draft.titleFromKeyword,
          ),
          _FormFieldRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date',
            value: dateValue,
            filled: draft.date != null,
            active: activeField == _VoiceActiveField.date,
          ),
          _FormFieldRow(
            icon: Icons.category_outlined,
            label: 'Category',
            value: categoryValue,
            filled: draft.hasCategory || draft.noCategory,
            active: activeField == _VoiceActiveField.category,
            muted: !draft.hasCategory,
          ),
          if (knownCategories.isNotEmpty) ...[
            const SizedBox(height: StitchSpacing.xs),
            Wrap(
              spacing: StitchSpacing.sm,
              runSpacing: StitchSpacing.sm,
              children: [
                for (final stored in knownCategories.take(8))
                  Builder(
                    builder: (context) {
                      final parsed =
                          CategoryUtils.parseCategoryStorage(stored);
                      final selected = draft.hasCategory &&
                          (draft.category == stored ||
                              CategoryUtils.parseCategoryStorage(
                                    draft.category!,
                                  ).name ==
                                  parsed.name);
                      return FilterChip(
                        avatar: parsed.emoji != null
                            ? Text(parsed.emoji!)
                            : null,
                        label: Text(parsed.name),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) {},
                        visualDensity: VisualDensity.compact,
                      );
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TypeSelectChip extends StatelessWidget {
  const _TypeSelectChip({
    required this.label,
    required this.icon,
    required this.selected,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final emphasized = selected || active;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: StitchSpacing.md,
        vertical: StitchSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: emphasized
            ? colors.primaryContainer
            : colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: emphasized ? colors.primary : colors.outlineVariant,
          width: emphasized ? (active ? 2 : 1.5) : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: emphasized ? colors.primary : colors.onSurfaceVariant,
          ),
          const SizedBox(width: StitchSpacing.xs),
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
              color: emphasized ? colors.onPrimaryContainer : colors.onSurface,
            ),
          ),
          if (selected) ...[
            const SizedBox(width: StitchSpacing.xs),
            Icon(Icons.check_rounded, size: 16, color: colors.primary),
          ],
        ],
      ),
    );
  }
}

class _FormFieldRow extends StatelessWidget {
  const _FormFieldRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.filled,
    this.active = false,
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool filled;
  final bool active;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final emphasized = active || filled;

    return Padding(
      padding: const EdgeInsets.only(bottom: StitchSpacing.sm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: StitchSpacing.md,
          vertical: StitchSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: active
              ? colors.primaryContainer
              : filled
                  ? colors.secondaryContainer.withValues(alpha: 0.55)
                  : colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? colors.primary
                : filled
                    ? colors.primary.withValues(alpha: 0.35)
                    : colors.outlineVariant,
            width: active ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: emphasized ? colors.primary : colors.onSurfaceVariant,
            ),
            const SizedBox(width: StitchSpacing.sm),
            SizedBox(
              width: 72,
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: active ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
                  color: muted
                      ? colors.onSurfaceVariant
                      : colors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (filled)
              Icon(Icons.check_circle_rounded, size: 18, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = 96 + progress * 100;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: color.a * (1 - progress)),
          width: 2.5,
        ),
      ),
    );
  }
}
