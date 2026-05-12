import 'package:json_schema_builder/json_schema_builder.dart';

final updateDetailsFormSchema = S.object(
  properties: {
    'fullName': S.string(description: 'Current full name'),
    'email': S.string(description: 'Current email address'),
    'phone': S.string(description: 'Current phone number'),
  },
  required: ['fullName', 'email'],
);
