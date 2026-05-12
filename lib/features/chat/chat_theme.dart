import 'package:flutter/material.dart';

/// Visual tokens for the customer-service chat shell (matches in-app Maya support UI).
abstract final class MayaChatTheme {
  static const Color brandGreen = Color(0xFF00A651);
  static const Color botBubbleBackground = Color(0xFFE8E8E8);
  static const Color inputBarBackground = Color(0xFFF5F5F5);
  static const Color scaffoldBackground = Colors.white;
  static const Color hintAndSubtitle = Color(0xFF9E9E9E);
  static const Color appBarTitle = Color(0xFF212121);
  static const Color inputFieldBorder = Color(0xFFE0E0E0);

  static const BorderRadius bubbleRadius = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadius inputFieldRadius = BorderRadius.all(
    Radius.circular(24),
  );

  static TextStyle userBubbleTextStyle(Color onGreen) =>
      TextStyle(color: onGreen, fontSize: 15, height: 1.35);

  static TextStyle botBubbleTextStyle(Color onGray) =>
      TextStyle(color: onGray, fontSize: 15, height: 1.35);
}
