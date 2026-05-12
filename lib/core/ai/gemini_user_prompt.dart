import 'dart:convert';

import 'package:genui/genui.dart';

/// Turns a [ChatMessage] into a single user prompt for Gemini.
///
/// GenUI submits template taps as `ChatMessage.user('', parts: [UiInteractionPart])`;
/// [ChatMessage.text] is empty for those, so we must surface the interaction here.
String userMessageForGemini(ChatMessage message) {
  final chunks = <String>[];
  final typed = message.text.trim();
  if (typed.isNotEmpty) chunks.add(typed);

  for (final ui in message.parts.uiInteractionParts) {
    chunks.add(_formatUiInteraction(ui.interaction));
  }

  return chunks.join('\n\n').trim();
}

String _formatUiInteraction(String interactionJson) {
  try {
    final outer = jsonDecode(interactionJson) as Map<String, dynamic>;
    final action = outer['action'] as Map<String, dynamic>?;
    if (action != null) {
      final name = action['name'] as String? ?? 'ui_action';
      final surfaceId = action['surfaceId'] as String?;
      final source = action['sourceComponentId'] as String?;
      final ctx = action['context'];
      final buf = StringBuffer()
        ..writeln(
          '[The user used an in-chat template (interactive card) in the Maya customer service thread. '
          'Reply right away with a short, warm follow-up—confirm what they did, offer a clear next step, '
          'or ask one specific question. Do not leave the conversation hanging.]',
        )
        ..writeln('Action: $name');
      if (surfaceId != null) buf.writeln('Surface id: $surfaceId');
      if (source != null) buf.writeln('Component id: $source');
      if (ctx is Map && ctx.isNotEmpty) {
        buf.writeln('Details: ${jsonEncode(ctx)}');
      }
      return buf.toString().trim();
    }
  } catch (_) {
    // fall through
  }
  return '[In-chat UI interaction]\n$interactionJson';
}
