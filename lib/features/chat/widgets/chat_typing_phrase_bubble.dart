import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../chat_theme.dart';
import 'timed_typing_phrases.dart';

/// Typing row: Lottie bubble plus timed status spiels until the reply starts.
class ChatTypingPhraseBubble extends StatelessWidget {
  const ChatTypingPhraseBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 64, top: 4, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: ShapeDecoration(
                color: MayaChatTheme.botBubbleBackground,
                shape: ContinuousRectangleBorder(
                  borderRadius: MayaChatTheme.bubbleBorderRadius(
                    isUser: false,
                    isLastInGroup: true,
                  ),
                ),
              ),
              child: Lottie.asset(
                'assets/lottie/anim_typing.json',
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: TimedTypingPhrases(
                enableFadingAnimation: false,
                style: TextStyle(
                  color: MayaChatTheme.appBarTitle.withValues(alpha: 0.72),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
