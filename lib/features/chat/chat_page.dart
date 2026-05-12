import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:genui/genui.dart';

import '../../core/mock/mock_data.dart';
import '../../shared/customer_chat_copy.dart';
import '../../shared/widgets/maya_animated_orb.dart';
import 'chat_controller.dart';
import 'chat_theme.dart';
import 'widgets/chat_quick_reply_column.dart';
import 'widgets/chat_typing_phrase_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _controller;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = ChatController();
    _controller.init();
    _controller.addListener(_scrollToBottom);
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollToBottom);
    _controller.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty || _controller.isWaiting) return;
    _textController.clear();
    _controller.sendMessage(text);
  }

  void _sendPrefilled(String text) {
    if (_controller.isWaiting) return;
    _controller.sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MayaChatTheme.scaffoldBackground,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: MayaChatTheme.scaffoldBackground,
        surfaceTintColor: Colors.transparent,

        title: const Text(
          'Customer service chat',
          style: TextStyle(
            color: MayaChatTheme.appBarTitle,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time_outlined),
            color: MayaChatTheme.appBarTitle,
            tooltip: 'Chat history',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.close),
            color: MayaChatTheme.appBarTitle,
            tooltip: 'Close',
            onPressed: () => Navigator.maybePop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final messages = _controller.messages;
                final showThinking = _controller.showThinkingIndicator;
                if (messages.isEmpty) {
                  return _EmptyState(onSelectSuggestion: _sendPrefilled);
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: messages.length + (showThinking ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (showThinking && index == messages.length) {
                      return ChatTypingPhraseBubble(
                        key: ValueKey<int>(messages.length),
                      );
                    }
                    return _MessageItem(
                      entry: messages[index],
                      surfaceHost: _controller.surfaceHost,
                    );
                  },
                );
              },
            ),
          ),
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => _InputBar(
              controller: _textController,
              onSend: _send,
              isWaiting: _controller.isWaiting,
              showThinking: _controller.showThinkingIndicator,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSelectSuggestion});

  final ValueChanged<String> onSelectSuggestion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MayaAnimatedOrb(size: 148),
                  const SizedBox(height: 28),
                  Text(
                    'Hello, $mockClientFirstName!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: MayaChatTheme.appBarTitle,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'How can I assist you today?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MayaChatTheme.hintAndSubtitle,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ChatQuickReplyColumn(
            suggestions: kDefaultChatQuickReplies,
            onSelect: onSelectSuggestion,
          ),
        ),
      ],
    );
  }
}

class _MessageItem extends StatelessWidget {
  final ChatEntry entry;
  final SurfaceHost surfaceHost;

  const _MessageItem({required this.entry, required this.surfaceHost});

  @override
  Widget build(BuildContext context) {
    if (entry.isSurface) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Surface(
          surfaceContext: surfaceHost.contextFor(entry.surfaceId!),
        ),
      );
    }

    if (entry.isUser) {
      return _UserBubble(text: entry.text ?? '');
    }

    return _AiBubble(text: entry.text ?? '');
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.fromLTRB(56, 4, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: MayaChatTheme.brandGreen,
          borderRadius: MayaChatTheme.bubbleRadius,
        ),
        child: Text(
          text,
          style: MayaChatTheme.userBubbleTextStyle(Colors.white),
        ),
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  final String text;
  const _AiBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final baseStyle = MayaChatTheme.botBubbleTextStyle(MayaChatTheme.appBarTitle);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 56, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: MayaChatTheme.botBubbleBackground,
          borderRadius: MayaChatTheme.bubbleRadius,
        ),
        child: MarkdownBody(
          data: text,
          styleSheet: MarkdownStyleSheet(
            p: baseStyle,
            strong: baseStyle.copyWith(fontWeight: FontWeight.w700),
            em: baseStyle.copyWith(fontStyle: FontStyle.italic),
            listBullet: baseStyle,
            blockquote: baseStyle.copyWith(color: MayaChatTheme.hintAndSubtitle),
            h1: baseStyle.copyWith(fontSize: 17, fontWeight: FontWeight.w700),
            h2: baseStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
            h3: baseStyle.copyWith(fontWeight: FontWeight.w700),
            pPadding: EdgeInsets.zero,
            blockSpacing: 6,
          ),
          shrinkWrap: true,
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isWaiting;
  final bool showThinking;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.isWaiting,
    required this.showThinking,
  });

  @override
  Widget build(BuildContext context) {
    final hint = showThinking
        ? 'Please wait…'
        : isWaiting
        ? 'Maya is replying…'
        : 'Type a message';

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
        decoration: const BoxDecoration(
          color: MayaChatTheme.inputBarBackground,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.photo_camera_outlined),
              color: MayaChatTheme.appBarTitle,
              tooltip: 'Camera',
              onPressed: isWaiting ? null : () {},
            ),
            IconButton(
              icon: const Icon(Icons.description_outlined),
              color: MayaChatTheme.appBarTitle,
              tooltip: 'Attachments',
              onPressed: isWaiting ? null : () {},
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
                enabled: !isWaiting,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(
                  color: MayaChatTheme.appBarTitle,
                  fontSize: 15,
                ),
                cursorColor: MayaChatTheme.brandGreen,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    color: MayaChatTheme.hintAndSubtitle,
                  ),
                  filled: true,
                  fillColor: MayaChatTheme.scaffoldBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: MayaChatTheme.inputFieldRadius,
                    borderSide: const BorderSide(
                      color: MayaChatTheme.inputFieldBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: MayaChatTheme.inputFieldRadius,
                    borderSide: const BorderSide(
                      color: MayaChatTheme.inputFieldBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: MayaChatTheme.inputFieldRadius,
                    borderSide: const BorderSide(
                      color: MayaChatTheme.brandGreen,
                      width: 1.5,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: MayaChatTheme.inputFieldRadius,
                    borderSide: BorderSide(
                      color: MayaChatTheme.inputFieldBorder.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!isWaiting) ...[
              const SizedBox(width: 4),
              IconButton.filled(
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: MayaChatTheme.brandGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ] else
              const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
