import 'package:json_schema_builder/json_schema_builder.dart';

final transactionCardSchema = S.object(
  properties: {
    'merchant': S.string(description: 'Merchant name'),
    'amount': S.number(description: 'Transaction amount in PHP'),
    'status': S.string(description: 'Transaction status e.g. declined'),
    'reason': S.string(description: 'Human-readable decline reason'),
    'date': S.string(description: 'Transaction date'),
  },
  required: ['merchant', 'amount', 'status', 'reason'],
);
