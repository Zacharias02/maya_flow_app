import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import '../../core/mock/mock_data.dart';
import '../../features/chat/chat_theme.dart';
import '../../shared/chat_scope.dart';
import '../schemas/ticket_lookup_card_schema.dart';

final ticketLookupCard = CatalogItem(
  name: 'TicketLookupCard',
  dataSchema: ticketLookupCardSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return _TicketLookupCard(data: data, surfaceId: itemContext.surfaceId);
  },
);

enum _LookupState { form, result, notFound }

class _TicketLookupCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String surfaceId;
  const _TicketLookupCard({required this.data, required this.surfaceId});

  @override
  State<_TicketLookupCard> createState() => _TicketLookupCardState();
}

class _TicketLookupCardState extends State<_TicketLookupCard> {
  late _LookupState _state;
  bool _isLooking = false;
  late final TextEditingController _numberController;
  late String _resolvedNumber;
  String _resolvedConcern = '';
  void Function(String)? _clearSurfaceForm;
  void Function(String)? _addBotMessage;

  @override
  void initState() {
    super.initState();
    final prefill = widget.data['prefillNumber'] as String?;
    _numberController = TextEditingController();
    _numberController.addListener(() => setState(() {}));

    if (prefill != null && prefill.trim().isNotEmpty) {
      _resolvedNumber = prefill.trim();
      _resolvedConcern = mockConcernForTicket(_resolvedNumber) ?? 'Support Request';
      _state = _LookupState.result;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ChatScope.maybeOf(context)?.addBotMessage(
            'Here\'s the latest status of your ticket. Is there anything else I can help you with today? 😊',
          );
        }
      });
    } else {
      _resolvedNumber = '';
      _state = _LookupState.form;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ChatScope.maybeOf(context)?.markSurfaceAsForm(widget.surfaceId);
        }
      });
    }
  }

  @override
  void dispose() {
    _clearSurfaceForm?.call(widget.surfaceId);
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    if (_numberController.text.trim().isEmpty) return;
    _resolvedNumber = _numberController.text.trim();
    final clearForm = _clearSurfaceForm;
    final addBotMessage = _addBotMessage;
    setState(() => _isLooking = true);
    clearForm?.call(widget.surfaceId);
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    final concern = mockConcernForTicket(_resolvedNumber);
    if (concern != null) {
      _resolvedConcern = concern;
      setState(() { _isLooking = false; _state = _LookupState.result; });
      addBotMessage?.call(
        'Here\'s the latest status of your ticket. Is there anything else I can help you with today? 😊',
      );
    } else {
      setState(() { _isLooking = false; _state = _LookupState.notFound; });
      addBotMessage?.call(
        'Is there anything else I can help you with today? 😊',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _clearSurfaceForm = ChatScope.maybeOf(context)?.clearSurfaceForm;
    _addBotMessage = ChatScope.maybeOf(context)?.addBotMessage;
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
        _LookupState.result => _LookupResultView(
            key: const ValueKey('result'),
            ticketNumber: _resolvedNumber,
            concern: _resolvedConcern,
          ),
        _LookupState.notFound => _LookupNotFoundView(
            key: const ValueKey('notFound'),
            ticketNumber: _resolvedNumber,
            onTryAgain: () {
              _numberController.clear();
              setState(() => _state = _LookupState.form);
            },
          ),
        _LookupState.form => _LookupFormView(
            key: const ValueKey('form'),
            controller: _numberController,
            canSubmit: _numberController.text.trim().isNotEmpty,
            isLoading: _isLooking,
            onLookup: () => _lookup(),
          ),
      },
    );
  }
}

// ── Form ─────────────────────────────────────────────────────────────────────

class _LookupFormView extends StatelessWidget {
  final TextEditingController controller;
  final bool canSubmit;
  final bool isLoading;
  final VoidCallback onLookup;

  const _LookupFormView({
    super.key,
    required this.controller,
    required this.canSubmit,
    required this.isLoading,
    required this.onLookup,
  });

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
            'Check Ticket Status',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter your ticket number to see the latest update.',
            style: TextStyle(fontSize: 12, color: MayaChatTheme.hintAndSubtitle),
          ),
          const SizedBox(height: 16),
          const Text('TICKET NUMBER', style: labelStyle),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) { if (canSubmit) onLookup(); },
            style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
            decoration: inputDecoration.copyWith(hintText: 'e.g. 20613427'),
          ),
          const SizedBox(height: 16),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: (!isLoading && canSubmit) ? 1.0 : 0.45,
            child: GestureDetector(
              onTap: (!isLoading && canSubmit) ? onLookup : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: MayaChatTheme.brandGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Check Status',
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

// ── Result ────────────────────────────────────────────────────────────────────

class _LookupResultView extends StatelessWidget {
  final String ticketNumber;
  final String concern;

  const _LookupResultView({
    super.key,
    required this.ticketNumber,
    required this.concern,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _StatusChip('Received'),
              const SizedBox(width: 6),
              _StatusChip('In queue'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            concern,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ticket #$ticketNumber',
            style: const TextStyle(
              fontSize: 13,
              color: MayaChatTheme.hintAndSubtitle,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 16),
          _TimelineRow(
            isDone: true,
            hasLineBelow: true,
            label: 'Submitted',
            timestamp: 'Jun 22, 2026 • 10:15 AM',
          ),
          _TimelineRow(
            isCurrent: true,
            hasLineBelow: true,
            label: 'In progress',
            timestamp: 'Jun 22, 2026 • 10:45 AM',
            subtitle: 'Takes 3–5 business days',
          ),
          const _TimelineRow(label: 'Closed'),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Timeline ──────────────────────────────────────────────────────────────────

class _TimelineRow extends StatelessWidget {
  final bool isDone;
  final bool isCurrent;
  final bool hasLineBelow;
  final String label;
  final String? timestamp;
  final String? subtitle;

  const _TimelineRow({
    this.isDone = false,
    this.isCurrent = false,
    this.hasLineBelow = false,
    required this.label,
    this.timestamp,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = isDone || isCurrent;
    final Color lineColor = isDone ? MayaChatTheme.brandGreen : const Color(0xFFDDDDDD);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: _buildIndicator(),
                ),
                if (hasLineBelow)
                  Expanded(
                    child: CustomPaint(painter: _DashPainter(color: lineColor)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: hasLineBelow ? 14 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: active ? const Color(0xFF212121) : MayaChatTheme.hintAndSubtitle,
                    ),
                  ),
                  if (timestamp != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      timestamp!,
                      style: const TextStyle(fontSize: 12, color: MayaChatTheme.hintAndSubtitle),
                    ),
                  ],
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(fontSize: 12, color: MayaChatTheme.hintAndSubtitle),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    if (isDone) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: MayaChatTheme.brandGreen,
        ),
        child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
      );
    }
    if (isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: MayaChatTheme.brandGreen, width: 2),
        ),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCCCCCC), width: 2),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  final Color color;
  const _DashPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    const dash = 4.0;
    const gap = 3.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, (y + dash).clamp(0.0, size.height)),
        paint,
      );
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

// ── Not Found ─────────────────────────────────────────────────────────────────

class _LookupNotFoundView extends StatelessWidget {
  final String ticketNumber;
  final VoidCallback onTryAgain;

  const _LookupNotFoundView({
    super.key,
    required this.ticketNumber,
    required this.onTryAgain,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🔍  Ticket Not Found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find a ticket with number #$ticketNumber. '
            'Please double-check the number and try again.',
            style: const TextStyle(
              fontSize: 13,
              color: MayaChatTheme.hintAndSubtitle,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onTryAgain,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                border: Border.all(color: MayaChatTheme.brandGreen),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: MayaChatTheme.brandGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

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
