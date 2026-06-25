import 'package:flutter/widgets.dart';

class ChatScope extends InheritedWidget {
  const ChatScope({
    super.key,
    required this.addBotMessage,
    required this.markSurfaceAsForm,
    required this.clearSurfaceForm,
    required super.child,
  });

  final void Function(String text) addBotMessage;
  final void Function(String surfaceId) markSurfaceAsForm;
  final void Function(String surfaceId) clearSurfaceForm;

  static ChatScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ChatScope>();

  @override
  bool updateShouldNotify(ChatScope old) => false;
}
