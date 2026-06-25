import 'package:json_schema_builder/json_schema_builder.dart';

final ticketCardSchema = Schema.object(
  properties: {
    'prefillTitle': Schema.string(),
    'reasons': Schema.list(items: Schema.string()),
  },
);
