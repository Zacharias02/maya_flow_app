import 'package:json_schema_builder/json_schema_builder.dart';

final sendMoneyToUserFormSchema = S.object(
  properties: {
    'username': S.string(
      description: 'Recipient Maya username / handle, with or without leading @ (e.g. maria_maya or @maria_maya)',
    ),
    'displayName': S.string(
      description: 'Optional friendly name shown next to the handle (e.g. Maria Santos)',
    ),
    'amount': S.number(description: 'Amount to send in the given currency'),
    'currency': S.string(description: 'ISO or display currency, default PHP in the app'),
    'note': S.string(description: 'Optional personal note shown on the send form'),
  },
  required: ['username', 'amount'],
);
