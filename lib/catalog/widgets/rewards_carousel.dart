import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import '../maya_catalog_theme.dart';
import '../schemas/rewards_carousel_schema.dart';

final rewardsCarousel = CatalogItem(
  name: 'RewardsCarousel',
  dataSchema: rewardsCarouselSchema,
  widgetBuilder: (itemContext) {
    final data = itemContext.data as Map<String, dynamic>;
    return _RewardsCarousel(data: data);
  },
);

class _RewardsCarousel extends StatefulWidget {
  const _RewardsCarousel({required this.data});

  final Map<String, dynamic> data;

  @override
  State<_RewardsCarousel> createState() => _RewardsCarouselState();
}

class _RewardsCarouselState extends State<_RewardsCarousel> {
  late final PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.86);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _parseSlides() {
    final raw = widget.data['slides'];
    if (raw is! List) return [];
    final out = <Map<String, String>>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      final title = m['title']?.toString() ?? '';
      final body = m['body']?.toString() ?? '';
      if (title.isEmpty && body.isEmpty) continue;
      out.add({
        'title': title,
        'body': body,
        'emoji': m['emoji']?.toString() ?? '',
      });
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final slides = _parseSlides();
    final header = widget.data['headerTitle'] as String? ?? 'Ways to boost your rewards';
    final cs = Theme.of(context).colorScheme;

    if (slides.isEmpty) {
      return const SizedBox.shrink();
    }

    return MayaCatalogCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: ShapeDecoration(
                    color: MayaCatalogTheme.tintSurface(context),
                    shape: const ContinuousRectangleBorder(
                      borderRadius: MayaCatalogTheme.squircleInner,
                    ),
                  ),
                  child: Icon(Icons.card_giftcard_rounded, color: cs.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(header, style: MayaCatalogTheme.titleStyle(context)),
                      Text(
                        'Swipe cards for tips',
                        style: MayaCatalogTheme.subtitleStyle(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 18, bottom: 6),
            child: Row(
              children: [
                Icon(Icons.swipe_rounded, size: 16, color: cs.primary.withValues(alpha: 0.85)),
                const SizedBox(width: 6),
                Text(
                  'Swipe for more',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 176,
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              padEnds: true,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) {
                final s = slides[i];
                final emoji = s['emoji'] ?? '';
                final active = i == _page;
                return Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10, bottom: 10, top: 4),
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: MayaCatalogTheme.cardWhite,
                      shadows: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      shape: ContinuousRectangleBorder(
                        side: BorderSide(
                          color: active ? cs.primary.withValues(alpha: 0.35) : MayaCatalogTheme.stroke,
                          width: active ? 1.5 : 1,
                        ),
                        borderRadius: MayaCatalogTheme.squircleInner,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${emoji.isNotEmpty ? '$emoji ' : ''}${s['title']}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontFamily: MayaCatalogTheme.fontPro,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                  color: const Color(0xFF212121),
                                ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Text(
                              s['body'] ?? '',
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.4,
                                    color: cs.onSurface.withValues(alpha: 0.88),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (slides.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 14, top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active ? MayaCatalogTheme.brandGreen : cs.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
