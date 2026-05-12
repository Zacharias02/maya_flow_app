import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';

import '../../catalog/maya_catalog.dart';
import '../../core/ai/gemini_transport.dart';

class ChatController extends ChangeNotifier {
  late final SurfaceController _surfaceController;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;
  final _geminiTransport = GeminiTransport();

  final List<ChatEntry> _messages = [];
  StreamSubscription<ConversationEvent>? _eventSub;
  int? _currentAiTextIndex;

  List<ChatEntry> get messages => List.unmodifiable(_messages);
  SurfaceHost get surfaceHost => _surfaceController;
  bool get isWaiting => _conversation.state.value.isWaiting;

  void init() {
    _surfaceController = SurfaceController(catalogs: [mayaCatalog()]);
    _transport = A2uiTransportAdapter(
      onSend: (message) => _geminiTransport.onSend(message, _transport),
    );
    _conversation = Conversation(
      controller: _surfaceController,
      transport: _transport,
    );
    _conversation.state.addListener(notifyListeners);
    _eventSub = _conversation.events.listen(_onEvent);
  }

  void _onEvent(ConversationEvent event) {
    if (event is ConversationSurfaceAdded) {
      _currentAiTextIndex = null;
      _messages.add(ChatEntry.surface(event.surfaceId));
      notifyListeners();
    } else if (event is ConversationContentReceived) {
      final idx = _currentAiTextIndex;
      if (idx != null) {
        _messages[idx] = _messages[idx].appendText(event.text);
      } else {
        _currentAiTextIndex = _messages.length;
        _messages.add(ChatEntry.aiText(event.text));
      }
      notifyListeners();
    } else if (event is ConversationError) {
      print(event.error);
      _currentAiTextIndex = null;
      _messages.add(
        ChatEntry.aiText('Something went wrong. Please try again.'),
      );
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    _currentAiTextIndex = null;
    _messages.add(ChatEntry.user(text));
    notifyListeners();
    await _conversation.sendRequest(ChatMessage.user(text));
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    _conversation.state.removeListener(notifyListeners);
    _conversation.dispose();
    _transport.dispose();
    _surfaceController.dispose();
    super.dispose();
  }
}

class ChatEntry {
  final String? text;
  final String? surfaceId;
  final bool isUser;

  const ChatEntry._({this.text, this.surfaceId, required this.isUser});

  factory ChatEntry.user(String text) => ChatEntry._(text: text, isUser: true);
  factory ChatEntry.aiText(String text) =>
      ChatEntry._(text: text, isUser: false);
  factory ChatEntry.surface(String id) =>
      ChatEntry._(surfaceId: id, isUser: false);

  bool get isSurface => surfaceId != null;

  ChatEntry appendText(String more) =>
      ChatEntry._(text: (text ?? '') + more, isUser: isUser);
}
