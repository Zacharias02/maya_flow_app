import 'package:flutter/material.dart';

import '../chat_theme.dart';
import 'cycling_fade_phrases.dart';

/// Typing row: fades between **two** random lines from [kTypingStatusPhrases] until the reply starts.
class ChatTypingPhraseBubble extends StatelessWidget {
  const ChatTypingPhraseBubble({super.key});

  static const List<String> kTypingStatusPhrases = [
    'Consulting the Oracle of Banking wisdom…',
    'Sharpening my digital pencils 📝',
    "Polishing up a reply you'll love 💚",
    'Double-knotting my chatbot shoelaces…',
    'Decrypting your curiosity, one bit at a time!',
    'Doing some AI yoga stretches before replying…',
    'Tuning the chatbot antenna for best results…',
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 64, top: 4, bottom: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: CyclingFadePhrases(
            phrases: kTypingStatusPhrases,
            randomSubsetSize: 2,
            style: TextStyle(
              color: MayaChatTheme.appBarTitle.withValues(alpha: 0.72),
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.25,
            ),
          ),
        ),
      ),
    );
  }
}
