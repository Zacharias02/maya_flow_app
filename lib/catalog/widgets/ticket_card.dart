import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import '../../core/mock/mock_data.dart';
import '../../features/chat/chat_theme.dart';
import '../../shared/chat_scope.dart';
import '../schemas/ticket_card_schema.dart';

final ticketCard = CatalogItem(
  name: 'TicketCard',
  dataSchema: ticketCardSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return _TicketCard(data: data, surfaceId: itemContext.surfaceId);
  },
);

class _TicketCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String surfaceId;
  const _TicketCard({required this.data, required this.surfaceId});

  @override
  State<_TicketCard> createState() => _TicketCardState();
}

enum _CardState { form, done }

class _TicketCardState extends State<_TicketCard> {
  _CardState _state = _CardState.form;
  bool _isSubmitting = false;
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final String _ticketNumber;
  void Function(String)? _addBotMessage;
  void Function(String)? _clearSurfaceForm;

  @override
  void initState() {
    super.initState();
    final prefillTitle = widget.data['prefillTitle'] as String? ?? '';
    _titleController = TextEditingController(text: prefillTitle);
    _descController = TextEditingController();
    final predefined = mockTicketNumberFor(prefillTitle);
    if (predefined.isNotEmpty) {
      _ticketNumber = predefined;
    } else {
      final rand = Random();
      _ticketNumber = List.generate(8, (_) => rand.nextInt(10)).join();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _state == _CardState.form) {
        ChatScope.maybeOf(context)?.markSurfaceAsForm(widget.surfaceId);
      }
    });
  }

  @override
  void dispose() {
    _clearSurfaceForm?.call(widget.surfaceId);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) return;
    final clearForm = _clearSurfaceForm;
    setState(() => _isSubmitting = true);
    clearForm?.call(widget.surfaceId);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() { _isSubmitting = false; _state = _CardState.done; });
    _addBotMessage?.call(
      '✅ Your ticket has been submitted! Our support team is already working on your request '
      'and will get back to you within **3–5 business working days** via your registered email.\n\n'
      'Is there anything else I can help you with today? 😊',
    );
  }

  @override
  Widget build(BuildContext context) {
    _addBotMessage = ChatScope.maybeOf(context)?.addBotMessage;
    _clearSurfaceForm = ChatScope.maybeOf(context)?.clearSurfaceForm;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: switch (_state) {
        _CardState.done => _TicketStatusView(
            key: const ValueKey('status'),
            title: _titleController.text.trim(),
            ticketNumber: _ticketNumber,
          ),
        _CardState.form => _TicketFormView(
            key: const ValueKey('form'),
            titleController: _titleController,
            descController: _descController,
            reasons: ((widget.data['reasons'] as List?) ?? []).cast<String>(),
            isLoading: _isSubmitting,
            onSubmit: () => _submit(),
          ),
      },
    );
  }
}

// ── Form ─────────────────────────────────────────────────────────────────────

class _TicketFormView extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final List<String> reasons;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _TicketFormView({
    super.key,
    required this.titleController,
    required this.descController,
    required this.reasons,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<_TicketFormView> createState() => _TicketFormViewState();
}

class _TicketFormViewState extends State<_TicketFormView> {
  String? _selectedReason;

  @override
  void initState() {
    super.initState();
    widget.titleController.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.titleController.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  bool get _hasReasons => widget.reasons.isNotEmpty;

  bool get _canSubmit =>
      widget.titleController.text.trim().isNotEmpty &&
      (!_hasReasons || _selectedReason != null);

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF9E9E9E),
      letterSpacing: 0.4,
    );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF9F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: MayaChatTheme.inputFieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: MayaChatTheme.inputFieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: MayaChatTheme.brandGreen, width: 1.5),
      ),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Submit a Ticket',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          const Text('CONCERN', style: labelStyle),
          const SizedBox(height: 6),
          TextField(
            controller: widget.titleController,
            textInputAction: TextInputAction.next,
            style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
            decoration: inputDecoration.copyWith(hintText: 'Brief title of your concern'),
          ),
          if (_hasReasons) ...[
            const SizedBox(height: 14),
            const Text('REASON', style: labelStyle),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedReason,
              hint: const Text(
                'Select a reason',
                style: TextStyle(fontSize: 14, color: MayaChatTheme.hintAndSubtitle, fontFamily: 'Jeko'),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: MayaChatTheme.hintAndSubtitle),
              style: const TextStyle(fontSize: 14, color: Color(0xFF212121), fontFamily: 'Jeko'),
              decoration: inputDecoration,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              items: widget.reasons
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r, style: const TextStyle(fontFamily: 'Jeko')),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedReason = v),
            ),
          ],
          const SizedBox(height: 14),
          const Text('DESCRIPTION', style: labelStyle),
          const SizedBox(height: 6),
          TextField(
            controller: widget.descController,
            minLines: 3,
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
            decoration: inputDecoration.copyWith(hintText: 'Describe your concern in detail'),
          ),
          const SizedBox(height: 16),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: (!widget.isLoading && _canSubmit) ? 1.0 : 0.45,
            child: GestureDetector(
              onTap: (!widget.isLoading && _canSubmit) ? widget.onSubmit : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: MayaChatTheme.brandGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status card ───────────────────────────────────────────────────────────────

class _TicketStatusView extends StatelessWidget {
  final String title;
  final String ticketNumber;

  const _TicketStatusView({
    super.key,
    required this.title,
    required this.ticketNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section header
          Container(
            color: const Color(0xFFEDF7F1),
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
            child: const Text(
              '⏳  In progress',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
          ),
          // Ticket row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Ticket #$ticketNumber',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        children: categoriesForConcern(title)
                            .map((c) => _StatusChip(c))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFBDBDBD),
                  size: 22,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF616161)),
      ),
    );
  }
}
