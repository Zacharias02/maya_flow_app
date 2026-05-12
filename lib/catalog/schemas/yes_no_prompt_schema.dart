import 'package:json_schema_builder/json_schema_builder.dart';

final yesNoPromptSchema = S.object(
  properties: {
    'question': S.string(description: 'Optional question text shown above the buttons'),
    'yesLabel': S.string(description: 'Label for the affirmative button (default: Yes)'),
    'noLabel': S.string(description: 'Label for the negative button (default: No)'),
  },
  required: [],
);
