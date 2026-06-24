import 'package:flutter/material.dart';

/// Visual tokens for the customer-service chat shell (matches in-app Maya support UI).
abstract final class MayaChatTheme {
  static const Color brandGreen = Color(0xFF00A651);
  static const Color botBubbleBackground = Color(0xFFF9F9FA);
  static const Color inputBarBackground = Color(0xFFF5F5F5);
  static const Color scaffoldBackground = Colors.white;
  static const Color hintAndSubtitle = Color(0xFF9E9E9E);
  static const Color appBarTitle = Color(0xFF212121);
  static const Color inputFieldBorder = Color(0xFFE0E0E0);

  static const double bubbleCornerRadius = 28;
  static const double bubbleTailRadius = 6;

  static const BorderRadius bubbleRadius = BorderRadius.all(
    Radius.circular(12),
  );

  static BorderRadius bubbleBorderRadius({
    required bool isUser,
    required bool isLastInGroup,
  }) {
    const corner = Radius.circular(bubbleCornerRadius);
    const tail = Radius.circular(bubbleTailRadius);
    if (!isLastInGroup) {
      return const BorderRadius.all(corner);
    }
    if (isUser) {
      return const BorderRadius.only(
        topLeft: corner,
        topRight: corner,
        bottomLeft: corner,
        bottomRight: tail,
      );
    }
    return const BorderRadius.only(
      topLeft: corner,
      topRight: corner,
      bottomLeft: tail,
      bottomRight: corner,
    );
  }

  static const BorderRadius inputFieldRadius = BorderRadius.all(
    Radius.circular(24),
  );

  static TextStyle userBubbleTextStyle(Color onGreen) => TextStyle(
    color: Color.fromRGBO(255, 255, 255, 1),
    fontSize: 14,
    height: 1.2,
  );

  static TextStyle botBubbleTextStyle(Color onGray) =>
      TextStyle(color: Colors.black, fontSize: 14, height: 1.2);
}
