import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:genui/genui.dart';

import '../../catalog/maya_catalog.dart';
import '../../core/ai/gemini_transport.dart';
import 'a2ui_leak_sanitizer.dart';

class ChatController extends ChangeNotifier {
  late final SurfaceController _surfaceController;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversation;
  final _geminiTransport = GeminiTransport();

  final List<ChatEntry> _messages = [];
  StreamSubscription<ConversationEvent>? _eventSub;
  int? _currentAiTextIndex;
  bool _awaitingFirstChunk = false;

  List<ChatEntry> get messages => List.unmodifiable(_messages);
  SurfaceHost get surfaceHost => _surfaceController;
  bool get isWaiting => _conversation.state.value.isWaiting;

  /// True from send until the first streamed text or surface arrives for that turn.
  bool get showThinkingIndicator => _awaitingFirstChunk;

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

  /// Hides A2UI JSON that GenUI surfaced as plain text when the model used the wrong JSON shape.
  /// If stripping empties the entire bubble, removes the entry entirely — an empty
  /// ChatEntry would still render as a phantom bubble.
  void _stripLeakedA2UiFromLastAiBubble() {
    final idx = _currentAiTextIndex;
    if (idx == null || idx >= _messages.length) return;
    final entry = _messages[idx];
    if (entry.isUser || entry.isSurface) return;
    final t = entry.text;
    if (t == null || t.isEmpty) return;
    final cleaned = stripLeakedA2UiJsonFromAssistantText(t);
    if (cleaned == t) return;
    if (cleaned.trim().isEmpty) {
      // The whole content was leaked JSON — delete the phantom bubble.
      _messages.removeAt(idx);
      _currentAiTextIndex = null;
    } else {
      _messages[idx] = ChatEntry.aiText(cleaned);
    }
  }

  void _onEvent(ConversationEvent event) {
    if (event is ConversationSurfaceAdded) {
      // Flush any leaked JSON from the preceding text bubble before we lose
      // track of its index — once _currentAiTextIndex is nulled we can't find it.
      _stripLeakedA2UiFromLastAiBubble();
      _awaitingFirstChunk = false;
      _currentAiTextIndex = null;
      _messages.add(ChatEntry.surface(event.surfaceId));
      notifyListeners();
    } else if (event is ConversationContentReceived) {
      _awaitingFirstChunk = false;
      final idx = _currentAiTextIndex;
      if (idx != null) {
        _messages[idx] = _messages[idx].appendText(event.text);
      } else {
        _currentAiTextIndex = _messages.length;
        _messages.add(ChatEntry.aiText(event.text));
      }
      _stripLeakedA2UiFromLastAiBubble();
      notifyListeners();
    } else if (event is ConversationError) {
      print(event.error);
      _awaitingFirstChunk = false;
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
    _awaitingFirstChunk = true;
    notifyListeners();
    try {
      await _conversation.sendRequest(ChatMessage.user(text));
    } finally {
      _awaitingFirstChunk = false;
      notifyListeners();
    }
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

  ChatEntry appendText(String more) {
    final existing = text ?? '';
    if (existing.isEmpty || more.isEmpty) {
      return ChatEntry._(text: existing + more, isUser: isUser);
    }
    final last = existing[existing.length - 1];
    final first = more[0];
    // Insert a space when a word character abuts a letter — guards against
    // chunks that arrive at a word boundary without the separating space.
    // We skip digit–digit so numbers split across chunks stay intact.
    final needsSpace = _isWordChar(last) && _isLetter(first);
    return ChatEntry._(text: existing + (needsSpace ? ' ' : '') + more, isUser: isUser);
  }
}

bool _isWordChar(String c) => RegExp(r'[a-zA-Z0-9]').hasMatch(c);
bool _isLetter(String c) => RegExp(r'[a-zA-Z]').hasMatch(c);
