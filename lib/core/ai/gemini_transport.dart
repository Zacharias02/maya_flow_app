import 'package:firebase_ai/firebase_ai.dart';
import 'package:genui/genui.dart';

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

    await for (final chunk in stream) {
      final text = chunk.text;
      if (text != null && text.isNotEmpty) transport.addChunk(text);
    }
  }
}
