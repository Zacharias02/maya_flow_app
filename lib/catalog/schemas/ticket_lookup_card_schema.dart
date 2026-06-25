import 'package:json_schema_builder/json_schema_builder.dart';

final ticketLookupCardSchema = Schema.object(
  properties: {
    'prefillNumber': Schema.string(),
  },
);
