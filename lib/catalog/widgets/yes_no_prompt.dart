import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import '../maya_catalog_theme.dart';
import '../schemas/yes_no_prompt_schema.dart';

final yesNoPrompt = CatalogItem(
  name: 'YesNoPrompt',
  dataSchema: yesNoPromptSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return _YesNoPrompt(itemContext: itemContext, data: data);
  },
);

class _YesNoPrompt extends StatefulWidget {
  const _YesNoPrompt({required this.itemContext, required this.data});

  final CatalogItemContext itemContext;
  final Map<String, dynamic> data;

  @override
  State<_YesNoPrompt> createState() => _YesNoPromptState();
}

class _YesNoPromptState extends State<_YesNoPrompt> {
  String? _chosen;

  void _pick(String choice) {
    if (_chosen != null) return;
    setState(() => _chosen = choice);
    widget.itemContext.dispatchEvent(
      UserActionEvent(
        surfaceId: widget.itemContext.surfaceId,
        name: 'YesNoPrompt_${choice}_tapped',
        sourceComponentId: widget.itemContext.id,
        context: {
          'widget': 'YesNoPrompt',
          'choice': choice,
          'question': widget.data['question'] ?? '',
          'summary': 'User tapped "$choice" on the yes/no prompt.',
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final question = data['question'] as String?;
    final yesLabel = (data['yesLabel'] as String?)?.isNotEmpty == true
        ? data['yesLabel'] as String
        : 'Yes';
    final noLabel = (data['noLabel'] as String?)?.isNotEmpty == true
        ? data['noLabel'] as String
        : 'No';

    return MayaCatalogCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (question != null && question.isNotEmpty) ...[
            Text(question, style: MayaCatalogTheme.titleStyle(context)),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              Expanded(
                child: _ChoiceButton(
                  label: yesLabel,
                  icon: Icons.check_circle_outline_rounded,
                  filled: true,
                  selected: _chosen == 'yes',
                  dimmed: _chosen != null && _chosen != 'yes',
                  onTap: () => _pick('yes'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ChoiceButton(
                  label: noLabel,
                  icon: Icons.cancel_outlined,
                  filled: false,
                  selected: _chosen == 'no',
                  dimmed: _chosen != null && _chosen != 'no',
                  onTap: () => _pick('no'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isGreen = filled;
    final bg = isGreen ? MayaCatalogTheme.brandGreen : Colors.transparent;
    final fg = isGreen ? Colors.white : MayaCatalogTheme.brandGreen;
    final border = isGreen ? BorderSide.none : const BorderSide(color: MayaCatalogTheme.brandGreen, width: 1.5);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: dimmed ? 0.35 : 1.0,
      child: Material(
        color: selected ? (isGreen ? MayaCatalogTheme.brandGreenDark : MayaCatalogTheme.brandGreen.withValues(alpha: 0.1)) : bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: dimmed ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              border: Border.fromBorderSide(border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? Icons.check_rounded : icon,
                  size: 18,
                  color: selected
                      ? (isGreen ? Colors.white : MayaCatalogTheme.brandGreen)
                      : fg,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: MayaCatalogTheme.fontPro,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: selected
                        ? (isGreen ? Colors.white : MayaCatalogTheme.brandGreen)
                        : fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
