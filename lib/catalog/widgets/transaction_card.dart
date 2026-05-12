import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import '../maya_catalog_theme.dart';
import '../schemas/transaction_card_schema.dart';

final transactionCard = CatalogItem(
  name: 'TransactionCard',
  dataSchema: transactionCardSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return _TransactionCard(itemContext: itemContext, data: data);
  },
);

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.itemContext, required this.data});

  final CatalogItemContext itemContext;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final merchant = data['merchant'] as String? ?? '';
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final status = data['status'] as String? ?? '';
    final reason = data['reason'] as String? ?? '';
    final date = data['date'] as String? ?? '';
    final isDeclined = status.toLowerCase() == 'declined';
    final cs = Theme.of(context).colorScheme;

    return MayaCatalogCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDeclined
                      ? cs.error.withValues(alpha: 0.1)
                      : MayaCatalogTheme.tintSurface(context),
                  borderRadius: MayaCatalogTheme.innerRadius,
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: isDeclined ? cs.error : cs.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(merchant, style: MayaCatalogTheme.titleStyle(context)),
                    const SizedBox(height: 2),
                    Text(
                      'Transaction',
                      style: MayaCatalogTheme.subtitleStyle(context),
                    ),
                  ],
                ),
              ),
              if (status.isNotEmpty)
                _StatusChip(status: status, isDeclined: isDeclined),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'PHP ${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontFamily: MayaCatalogTheme.fontPro,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDeclined ? cs.error : MayaCatalogTheme.brandGreen,
            ),
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
                borderRadius: MayaCatalogTheme.innerRadius,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reason,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (date.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (isDeclined) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: MayaCatalogTheme.primaryFilledButtonStyle(context),
                onPressed: () {
                  itemContext.dispatchEvent(
                    UserActionEvent(
                      surfaceId: itemContext.surfaceId,
                      name: 'TransactionCard_dispute_tapped',
                      sourceComponentId: itemContext.id,
                      context: {
                        'widget': 'TransactionCard',
                        'merchant': merchant,
                        'amount': amount,
                        'status': status,
                        'summary':
                            'User tapped Dispute transaction on the transaction card.',
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.money_off_csred_outlined, size: 20),
                label: const Text('Dispute transaction'),
              ),
            ),
          ],
        ],
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDeclined
            ? cs.errorContainer
            : MayaCatalogTheme.tintSurface(context),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDeclined
              ? cs.error.withValues(alpha: 0.35)
              : cs.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isDeclined
              ? cs.onErrorContainer
              : MayaCatalogTheme.brandGreenDark,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
