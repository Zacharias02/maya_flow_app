import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(ratio * 100).toStringAsFixed(0)}% used',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isHighUsage
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 12,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  isHighUsage
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Used', style: Theme.of(context).textTheme.labelSmall),
                    Text(
                      '$currency ${_format(used)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Available', style: Theme.of(context).textTheme.labelSmall),
                    Text(
                      '$currency ${_format(available)}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Total limit: $currency ${_format(total)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
