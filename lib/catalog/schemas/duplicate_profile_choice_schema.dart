import 'package:json_schema_builder/json_schema_builder.dart';

/// Stacked choices for duplicate-account keep/remove (avoids cramped side-by-side labels).
final duplicateProfileChoiceSchema = S.object(
  properties: {
    'question': S.string(description: 'Main heading, e.g. which profile to keep'),
    'subtitle': S.string(
      description: 'Optional one line under the heading (e.g. removal disclaimer)',
    ),
    'notificationEmail': S.string(
      description:
          'Email address where ticket confirmation is sent (from USER CONTEXT primary email)',
    ),
    'choices': S.list(
      description:
          '2–4 full-width options. Each item: id (stable machine id), title (primary line), subtitle (optional smaller line).',
      minItems: 2,
      maxItems: 4,
      items: S.object(
        properties: {
          'id': S.string(description: 'Stable id e.g. keep_alpha, keep_beta'),
          'title': S.string(description: 'Primary label, may wrap'),
          'subtitle': S.string(description: 'Secondary line: emails, internal id, handle'),
        },
        required: ['id', 'title'],
      ),
    ),
  },
  required: ['question', 'choices', 'notificationEmail'],
);
