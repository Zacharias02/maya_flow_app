import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import '../maya_catalog_theme.dart';
import '../schemas/account_limit_bar_schema.dart';

final accountLimitBar = CatalogItem(
  name: 'AccountLimitBar',
  dataSchema: accountLimitBarSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return _AccountLimitBar(data: data);
  },
);

class _AccountLimitBar extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AccountLimitBar({required this.data});

  @override
  Widget build(BuildContext context) {
    final used = (data['used'] as num?)?.toDouble() ?? 0;
    final total = (data['total'] as num?)?.toDouble() ?? 1;
    final label = data['label'] as String? ?? 'Account Limit';
    final currency = data['currency'] as String? ?? 'PHP';
    final available = total - used;
    final ratio = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final isHighUsage = ratio >= 0.8;
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
                child: Icon(Icons.account_balance_wallet_outlined, color: cs.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: MayaCatalogTheme.titleStyle(context)),
                    Text(
                      'Your usage this period',
                      style: MayaCatalogTheme.subtitleStyle(context),
                    ),
                  ],
                ),
              ),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}% used',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isHighUsage ? cs.error : MayaCatalogTheme.brandGreen,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 11,
              backgroundColor: MayaCatalogTheme.trackGray,
              valueColor: AlwaysStoppedAnimation<Color>(
                isHighUsage ? cs.error : MayaCatalogTheme.brandGreen,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AmountBlock(
                label: 'Used',
                value: '$currency ${_format(used)}',
                emphasize: false,
              ),
              _AmountBlock(
                label: 'Available',
                value: '$currency ${_format(available)}',
                emphasize: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: ShapeDecoration(
              color: MayaCatalogTheme.tintSurface(context),
              shape: const ContinuousRectangleBorder(
                borderRadius: MayaCatalogTheme.squircleInner,
              ),
            ),
            child: Text(
              'Total limit: $currency ${_format(total)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _format(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$whole.${parts[1]}';
  }
}

class _AmountBlock extends StatelessWidget {
  const _AmountBlock({
    required this.label,
    required this.value,
    required this.emphasize,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: emphasize ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: emphasize ? MayaCatalogTheme.brandGreen : cs.onSurface,
              ),
        ),
      ],
    );
  }
}
