import 'package:firebase_ai/firebase_ai.dart';
import 'package:genui/genui.dart';

import 'a2ui_duplicate_fallback.dart';
import 'a2ui_stream_repair.dart';
import 'gemini_user_prompt.dart';
import 'system_prompt.dart';

class GeminiTransport {
  Future<void> onSend(
    ChatMessage message,
    A2uiTransportAdapter transport,
  ) async {
    final prompt = userMessageForGemini(message);
    if (prompt.isEmpty) return;

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(buildSystemPrompt()),
    );

    final stream = model.generateContentStream([Content.text(prompt)]);

    final buffer = StringBuffer();
    await for (final chunk in stream) {
      final text = chunk.text;
      if (text != null && text.isNotEmpty) buffer.write(text);
    }
    final raw = buffer.toString();
    final repaired = repairMayaA2UiAssistantText(raw);
    final withOrphans = ensureOrphanDupCreatesHaveUpdateComponents(repaired);
    final finalized = ensureDuplicateProfileChoiceFallback(
      userPrompt: prompt,
      assistantText: withOrphans,
    );
    if (finalized.isNotEmpty) transport.addChunk(finalized);
  }
}
