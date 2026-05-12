import 'package:json_schema_builder/json_schema_builder.dart';

/// Swipeable tips for cashbacks & rewards (A2UI root component).
final rewardsCarouselSchema = S.object(
  properties: {
    'headerTitle': S.string(
      description: 'Optional title above the carousel, e.g. "Maximize your rewards"',
    ),
    'slides': S.list(
      description:
          '2–6 swipeable cards. Each item: title (short), body (1–2 actionable sentences), emoji (optional).',
      minItems: 2,
      maxItems: 6,
      items: S.object(
        properties: {
          'title': S.string(description: 'Slide headline'),
          'body': S.string(description: 'Concrete tip for earning or redeeming rewards'),
          'emoji': S.string(description: 'Optional single emoji or short symbol'),
        },
        required: ['title', 'body'],
      ),
    ),
  },
  required: ['slides'],
);
