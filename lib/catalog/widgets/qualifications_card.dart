import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import '../../features/chat/chat_theme.dart';
import '../schemas/qualifications_card_schema.dart';

final qualificationsCard = CatalogItem(
  name: 'QualificationsCard',
  dataSchema: qualificationsCardSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return _QualificationsCard(data: data);
  },
);

class _QualificationsCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const _QualificationsCard({required this.data});

  @override
  State<_QualificationsCard> createState() => _QualificationsCardState();
}

class _QualificationsCardState extends State<_QualificationsCard> {
  int? _expandedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final headerTitle = widget.data['headerTitle'] as String?;
    final items = ((widget.data['items'] as List?) ?? [])
        .cast<Map<String, dynamic>>();

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (headerTitle != null && headerTitle.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Text(
                  headerTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9E9E),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const _Divider(),
            ],
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const _Divider(),
              _AccordionItem(
                label: items[i]['label'] as String? ?? '',
                detail: items[i]['detail'] as String?,
                isExpanded: _expandedIndex == i,
                onTap: () => setState(() {
                  _expandedIndex = _expandedIndex == i ? null : i;
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccordionItem extends StatefulWidget {
  final String label;
  final String? detail;
  final bool isExpanded;
  final VoidCallback onTap;

  const _AccordionItem({
    required this.label,
    required this.detail,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<_AccordionItem> createState() => _AccordionItemState();
}

class _AccordionItemState extends State<_AccordionItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: widget.isExpanded ? 1.0 : 0.0,
    );
    _expandAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(_AccordionItem old) {
    super.didUpdateWidget(old);
    if (widget.isExpanded != old.isExpanded) {
      widget.isExpanded ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 4,
              color: widget.isExpanded
                  ? MayaChatTheme.brandGreen
                  : Colors.transparent,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 240),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: widget.isExpanded
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: const Color(0xFF212121),
                              height: 1.3,
                            ),
                            child: Text(widget.label),
                          ),
                        ),
                        const SizedBox(width: 10),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.isExpanded
                                  ? MayaChatTheme.brandGreen
                                  : const Color(0xFFBDBDBD),
                              width: 1.5,
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, anim) => ScaleTransition(
                              scale: anim,
                              child: child,
                            ),
                            child: Icon(
                              widget.isExpanded ? Icons.remove : Icons.add,
                              key: ValueKey(widget.isExpanded),
                              size: 16,
                              color: widget.isExpanded
                                  ? MayaChatTheme.brandGreen
                                  : const Color(0xFFBDBDBD),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizeTransition(
                      sizeFactor: _expandAnim,
                      axisAlignment: -1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          if (widget.detail?.isNotEmpty ?? false)
                            FadeTransition(
                              opacity: _expandAnim,
                              child: Text(
                                widget.detail!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF616161),
                                  height: 1.45,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0));
  }
}
