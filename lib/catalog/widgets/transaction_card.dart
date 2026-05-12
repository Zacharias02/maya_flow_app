import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import '../schemas/transaction_card_schema.dart';

final transactionCard = CatalogItem(
  name: 'TransactionCard',
  dataSchema: transactionCardSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return _TransactionCard(data: data);
  },
);

class _TransactionCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TransactionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final merchant = data['merchant'] as String? ?? '';
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final status = data['status'] as String? ?? '';
    final reason = data['reason'] as String? ?? '';
    final date = data['date'] as String? ?? '';
    final isDeclined = status.toLowerCase() == 'declined';

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
                Expanded(
                  child: Text(
                    merchant,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: status, isDeclined: isDeclined),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'PHP ${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDeclined ? Theme.of(context).colorScheme.error : null,
              ),
            ),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(reason, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            ],
            if (date.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (isDeclined) ...[
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dispute submitted. Our team will review within 3–5 business days.'),
                    ),
                  );
                },
                child: const Text('Dispute Transaction'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool isDeclined;

  const _StatusChip({required this.status, required this.isDeclined});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDeclined
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isDeclined
              ? Theme.of(context).colorScheme.onErrorContainer
              : Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
