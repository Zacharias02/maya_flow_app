import 'package:flutter/material.dart';

import '../chat_theme.dart';

/// Vertically stacked, right-aligned pill suggestions (outlined green on white).
class ChatQuickReplyColumn extends StatelessWidget {
  const ChatQuickReplyColumn({super.key, required this.suggestions, required this.onSelect});

  final List<String> suggestions;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final text in suggestions) ...[
          _QuickReplyPill(label: text, onTap: () => onSelect(text)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _QuickReplyPill extends StatelessWidget {
  const _QuickReplyPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(20));
    const minWidth = 36.0;
    final maxWidth = (MediaQuery.of(context).size.width * 0.90).clamp(minWidth, double.infinity);

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          clipBehavior: Clip.antiAlias,
          constraints: BoxConstraints(maxWidth: maxWidth, minWidth: minWidth),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: MayaChatTheme.brandGreen),
            color: Colors.transparent,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Text(
                  label,
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: MayaChatTheme.brandGreen, fontSize: 14, height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
