import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genui/genui.dart';

import '../maya_catalog_theme.dart';
import '../schemas/send_money_to_user_form_schema.dart';

final sendMoneyToUserForm = CatalogItem(
  name: 'SendMoneyToUserForm',
  dataSchema: sendMoneyToUserFormSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return _SendMoneyToUserForm(itemContext: itemContext, data: data);
  },
);

String _canonicalAtHandle(String raw) {
  final inner = raw.trim().replaceAll(RegExp(r'^@+'), '');
  return inner.isEmpty ? '' : '@$inner';
}

String _initialFromHandle(String handle) {
  final u = handle.replaceFirst('@', '');
  if (u.isEmpty) return '?';
  return u[0].toUpperCase();
}

class _SendMoneyToUserForm extends StatefulWidget {
  const _SendMoneyToUserForm({required this.itemContext, required this.data});

  final CatalogItemContext itemContext;
  final Map<String, dynamic> data;

  @override
  State<_SendMoneyToUserForm> createState() => _SendMoneyToUserFormState();
}

class _SendMoneyToUserFormState extends State<_SendMoneyToUserForm> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    final amt = (widget.data['amount'] as num?)?.toDouble();
    _amountCtrl = TextEditingController(
      text: amt != null && amt > 0
          ? amt.toStringAsFixed(amt == amt.truncateToDouble() ? 0 : 2)
          : '',
    );
    _noteCtrl = TextEditingController(
      text: widget.data['note'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _send() {
    setState(() => _sent = true);
    final handle = _canonicalAtHandle(widget.data['username'] as String? ?? '');
    final amountText = _amountCtrl.text.trim();
    widget.itemContext.dispatchEvent(
      UserActionEvent(
        surfaceId: widget.itemContext.surfaceId,
        name: 'SendMoneyToUserForm_send_tapped',
        sourceComponentId: widget.itemContext.id,
        context: {
          'widget': 'SendMoneyToUserForm',
          'toHandle': handle,
          'amountEntered': amountText,
          'note': _noteCtrl.text.trim(),
          'summary': 'User tapped Send money on the P2P @username form.',
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final handle = _canonicalAtHandle(widget.data['username'] as String? ?? '');
    final display = widget.data['displayName'] as String? ?? '';
    final currency = widget.data['currency'] as String? ?? 'PHP';
    final cs = Theme.of(context).colorScheme;

    return MayaCatalogCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: ShapeDecoration(
                  color: MayaCatalogTheme.tintSurface(context),
                  shape: const ContinuousRectangleBorder(
                    borderRadius: MayaCatalogTheme.squircleInner,
                  ),
                ),
                child: Icon(Icons.send_rounded, color: cs.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send money',
                      style: MayaCatalogTheme.titleStyle(context),
                    ),
                    Text(
                      'Peer transfer with @username',
                      style: MayaCatalogTheme.subtitleStyle(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.45),
                    width: 2,
                  ),
                  color: MayaCatalogTheme.tintSurface(context),
                ),
                child: Text(
                  _initialFromHandle(handle),
                  style: TextStyle(
                    fontFamily: MayaCatalogTheme.fontPro,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      handle.isEmpty ? '@username' : handle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: MayaCatalogTheme.fontPro,
                        fontWeight: FontWeight.w800,
                        color: MayaCatalogTheme.brandGreen,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (display.isNotEmpty)
                      Text(
                        display,
                        style: MayaCatalogTheme.subtitleStyle(context),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _amountCtrl,
            style: MayaCatalogTheme.fieldValueStyle(context),
            decoration: MayaCatalogTheme.inputDecoration(
              context,
              label: 'Amount',
              prefixText: '$currency ',
              prefixIcon: Icons.payments_outlined,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            style: MayaCatalogTheme.fieldValueStyle(context),
            decoration: MayaCatalogTheme.inputDecoration(
              context,
              label: 'Note (optional)',
              prefixIcon: Icons.notes_outlined,
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: MayaCatalogTheme.primaryFilledButtonStyle(context),
              onPressed: _sent || handle.isEmpty ? null : _send,
              icon: Icon(
                _sent ? Icons.check_rounded : Icons.send_to_mobile_outlined,
                size: 22,
              ),
              label: Text(_sent ? 'Sent' : 'Send money'),
            ),
          ),
        ],
      ),
    );
  }
}
