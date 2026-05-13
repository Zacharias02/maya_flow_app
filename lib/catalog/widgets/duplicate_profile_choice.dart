import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import '../../core/session/duplicate_account_flow_gate.dart';
import '../maya_catalog_theme.dart';
import '../schemas/duplicate_profile_choice_schema.dart';

final duplicateProfileChoice = CatalogItem(
  name: 'DuplicateProfileChoice',
  dataSchema: duplicateProfileChoiceSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return _DuplicateProfileChoice(itemContext: itemContext, data: data);
  },
);

enum _FlowUi { idle, processing, failed, ticket }

class _DuplicateProfileChoice extends StatefulWidget {
  const _DuplicateProfileChoice({required this.itemContext, required this.data});

  final CatalogItemContext itemContext;
  final Map<String, dynamic> data;

  @override
  State<_DuplicateProfileChoice> createState() => _DuplicateProfileChoiceState();
}

class _DuplicateProfileChoiceState extends State<_DuplicateProfileChoice> {
  String? _chosenId;
  _FlowUi _flowUi = _FlowUi.idle;
  String? _ticketId;

  String get _notifyEmail =>
      (widget.data['notificationEmail'] as String?)?.trim().isNotEmpty == true
          ? (widget.data['notificationEmail'] as String).trim()
          : 'your registered email';

  List<Map<String, String>> _parseChoices() {
    final raw = widget.data['choices'];
    if (raw is! List) return [];
    final out = <Map<String, String>>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      final id = m['id']?.toString() ?? '';
      final title = m['title']?.toString() ?? '';
      if (id.isEmpty || title.isEmpty) continue;
      out.add({
        'id': id,
        'title': title,
        'subtitle': m['subtitle']?.toString() ?? '',
      });
    }
    return out;
  }

  void _select(Map<String, String> choice) {
    if (_chosenId != null) return;
    final id = choice['id']!;
    DuplicateAccountFlowGate.markCompleted();
    setState(() {
      _chosenId = id;
      _flowUi = _FlowUi.processing;
      _ticketId =
          'DUP-${DateTime.now().year}-${(1000 + Random().nextInt(9000)).toString()}';
    });

    widget.itemContext.dispatchEvent(
      UserActionEvent(
        surfaceId: widget.itemContext.surfaceId,
        name: 'DuplicateProfileChoice_selected',
        sourceComponentId: widget.itemContext.id,
        context: {
          'widget': 'DuplicateProfileChoice',
          'choiceId': id,
          'choiceTitle': choice['title'] ?? '',
          'choiceSubtitle': choice['subtitle'] ?? '',
          'question': widget.data['question']?.toString() ?? '',
          'notificationEmail': _notifyEmail,
          'ticketId': _ticketId,
          'summary': 'User selected duplicate profile option "$id" (${choice['title']}).',
        },
      ),
    );

    unawaited(_runOutcomeSequence());
  }

  Future<void> _runOutcomeSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _flowUi = _FlowUi.failed);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() => _flowUi = _FlowUi.ticket);
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.data['question'] as String? ?? '';
    final subtitle = widget.data['subtitle'] as String? ?? '';
    final choices = _parseChoices();

    return MayaCatalogCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (question.isNotEmpty)
            Text(question, style: MayaCatalogTheme.titleStyle(context)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(subtitle, style: MayaCatalogTheme.subtitleStyle(context)),
          ],
          const SizedBox(height: 16),
          if (_flowUi == _FlowUi.idle) ...[
            for (var i = 0; i < choices.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _ChoiceTile(
                choice: choices[i],
                dimmed: _chosenId != null && _chosenId != choices[i]['id'],
                onTap: () => _select(choices[i]),
              ),
            ],
          ] else ...[
            _OutcomePanel(
              phase: _flowUi,
              ticketId: _ticketId ?? 'DUP-${DateTime.now().year}-0000',
              notifyEmail: _notifyEmail,
            ),
          ],
        ],
      ),
    );
  }
}

class _OutcomePanel extends StatelessWidget {
  const _OutcomePanel({
    required this.phase,
    required this.ticketId,
    required this.notifyEmail,
  });

  final _FlowUi phase;
  final String ticketId;
  final String notifyEmail;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case _FlowUi.processing:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(
              minHeight: 3,
              color: MayaCatalogTheme.brandGreen,
              backgroundColor: MayaCatalogTheme.trackGray,
            ),
            const SizedBox(height: 14),
            Text(
              'Removing duplicate profile data…',
              style: MayaCatalogTheme.titleStyle(context).copyWith(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              'This can take a few seconds. Please keep this chat open.',
              style: MayaCatalogTheme.subtitleStyle(context),
            ),
          ],
        );
      case _FlowUi.failed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline_rounded, color: Theme.of(context).colorScheme.error, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Removal could not be completed',
                    style: MayaCatalogTheme.titleStyle(context).copyWith(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'The duplicate cleanup did not finish on our side (connection timeout). Nothing was deleted from your active wallet without specialist review.',
              style: MayaCatalogTheme.subtitleStyle(context),
            ),
          ],
        );
      case _FlowUi.ticket:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.mark_email_read_outlined, color: MayaCatalogTheme.brandGreen, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support ticket created',
                        style: MayaCatalogTheme.titleStyle(context).copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        ticketId,
                        style: TextStyle(
                          fontFamily: MayaCatalogTheme.fontPro,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: MayaCatalogTheme.brandGreenDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'A confirmation with this ticket ID was sent to:',
                        style: MayaCatalogTheme.subtitleStyle(context),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        notifyEmail,
                        style: MayaCatalogTheme.titleStyle(context).copyWith(
                              fontSize: 15,
                              color: const Color(0xFF212121),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      case _FlowUi.idle:
        return const SizedBox.shrink();
    }
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.choice,
    required this.dimmed,
    required this.onTap,
  });

  final Map<String, String> choice;
  final bool dimmed;
  final VoidCallback onTap;

  static ButtonStyle _style() {
    return OutlinedButton.styleFrom(
      foregroundColor: MayaCatalogTheme.brandGreen,
      backgroundColor: MayaCatalogTheme.cardWhite,
      side: const BorderSide(color: MayaCatalogTheme.brandGreen, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      alignment: Alignment.centerLeft,
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = choice['title'] ?? '';
    final sub = choice['subtitle'] ?? '';

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: MayaCatalogTheme.fontPro,
            fontWeight: FontWeight.w700,
            fontSize: 15,
            height: 1.25,
            color: MayaCatalogTheme.brandGreen,
          ),
        ),
        if (sub.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            sub,
            style: TextStyle(
              fontFamily: MayaCatalogTheme.fontBook,
              fontSize: 13,
              height: 1.35,
              color: MayaCatalogTheme.muted,
            ),
          ),
        ],
      ],
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: dimmed ? 0.38 : 1,
      child: OutlinedButton(
        style: _style(),
        onPressed: dimmed ? null : onTap,
        child: content,
      ),
    );
  }
}
