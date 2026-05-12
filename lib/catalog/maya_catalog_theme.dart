import 'package:flutter/material.dart';

/// Catalog: white card + thin border shell; interior uses Maya / theme accents.
abstract final class MayaCatalogTheme {
  /// Primary catalog typeface (headings, buttons, emphasis).
  static const String fontPro = 'Jeko';

  /// Book weight for supporting copy and form labels.
  static const String fontBook = 'Jeko';

  /// Maya brand green (aligned with [MayaChatTheme.brandGreen]).
  static const Color brandGreen = Color(0xFF00A651);
  static const Color brandGreenDark = Color(0xFF007A3D);

  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color borderGray = Color(0xFFE0E0E0);
  static const Color stroke = borderGray;
  static const Color trackGray = Color(0xFFEEEEEE);
  static const Color muted = Color(0xFF757575);

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius fieldRadius = BorderRadius.all(Radius.circular(8));
  static const BorderRadius innerRadius = fieldRadius;

  static BoxDecoration cardShell() => BoxDecoration(
        color: cardWhite,
        borderRadius: cardRadius,
        border: Border.all(color: borderGray, width: 1),
      );

  static Color tintSurface(BuildContext context) =>
      Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);

  static TextStyle titleStyle(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return (t.titleMedium ?? t.titleLarge ?? const TextStyle(fontSize: 17))
        .copyWith(
          fontFamily: fontPro,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF212121),
        );
  }

  static TextStyle subtitleStyle(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return (t.bodySmall ?? t.bodyMedium ?? const TextStyle(fontSize: 13))
        .copyWith(fontFamily: fontBook, color: muted, height: 1.35);
  }

  /// Typed text inside catalog `TextField`s.
  static TextStyle fieldValueStyle(BuildContext context) {
    return TextStyle(
      fontFamily: fontBook,
      fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16,
      color: const Color(0xFF212121),
    );
  }

  static InputDecoration inputDecoration(
    BuildContext context, {
    required String label,
    String? prefixText,
    IconData? prefixIcon,
  }) {
    const loose = OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: BorderSide(color: borderGray),
    );
    final labelTypography = TextStyle(
      fontFamily: fontBook,
      color: muted,
      fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 13),
    );
    return InputDecoration(
      labelText: label,
      labelStyle: labelTypography,
      floatingLabelStyle: labelTypography.copyWith(
        fontWeight: FontWeight.w500,
        color: const Color(0xFF212121),
      ),
      prefixText: prefixText,
      prefixStyle: TextStyle(
        fontFamily: fontBook,
        color: const Color(0xFF212121),
        fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16,
      ),
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, color: Theme.of(context).colorScheme.primary, size: 22),
      filled: true,
      fillColor: cardWhite,
      border: loose,
      enabledBorder: loose,
      focusedBorder: const OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: brandGreen, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  /// Primary Maya-style filled actions (icons optional at call site).
  static ButtonStyle primaryFilledButtonStyle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilledButton.styleFrom(
      backgroundColor: brandGreen,
      foregroundColor: Colors.white,
      disabledBackgroundColor: cs.surfaceContainerHighest,
      disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
      textStyle: const TextStyle(
        fontFamily: fontPro,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class MayaCatalogCard extends StatelessWidget {
  const MayaCatalogCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final outer = Theme.of(context);
    final catalogTextTheme = outer.textTheme.apply(
      fontFamily: MayaCatalogTheme.fontBook,
      bodyColor: const Color(0xFF212121),
      displayColor: const Color(0xFF212121),
    );
    return Theme(
      data: outer.copyWith(textTheme: catalogTextTheme),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DecoratedBox(
          decoration: MayaCatalogTheme.cardShell(),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
