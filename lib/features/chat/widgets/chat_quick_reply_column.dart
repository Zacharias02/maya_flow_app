import 'package:flutter/material.dart';

import '../chat_theme.dart';

/// Vertically stacked, right-aligned pill suggestions (outlined green on white).
class ChatQuickReplyColumn extends StatelessWidget {
  const ChatQuickReplyColumn({
    super.key,
    required this.suggestions,
    required this.onSelect,
  });

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
    return Material(
      color: MayaChatTheme.scaffoldBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MayaChatTheme.brandGreen, width: 1),
          ),
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: MayaChatTheme.brandGreen,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
