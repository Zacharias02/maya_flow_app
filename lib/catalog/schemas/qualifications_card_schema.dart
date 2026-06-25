import 'package:json_schema_builder/json_schema_builder.dart';

final qualificationsCardSchema = Schema.object(
  properties: {
    'headerTitle': Schema.string(),
    'items': Schema.list(
      items: Schema.object(
        properties: {
          'label': Schema.string(),
          'detail': Schema.string(),
        },
        required: ['label'],
      ),
    ),
  },
  required: ['items'],
);
