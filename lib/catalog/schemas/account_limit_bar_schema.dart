import 'package:json_schema_builder/json_schema_builder.dart';

final accountLimitBarSchema = S.object(
  properties: {
    'label': S.string(description: 'Label for the limit bar'),
    'used': S.number(description: 'Amount used'),
    'total': S.number(description: 'Total limit'),
    'currency': S.string(description: 'Currency symbol'),
  },
  required: ['used', 'total'],
);
