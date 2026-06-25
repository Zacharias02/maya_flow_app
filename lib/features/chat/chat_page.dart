import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:genui/genui.dart';

import '../../shared/chat_scope.dart';
import '../../shared/customer_chat_copy.dart';
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
          'Customer Service Chat',
          style: TextStyle(color: MayaChatTheme.appBarTitle, fontWeight: FontWeight.w700, fontSize: 17),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: SvgPicture.asset('assets/svg/icon_history.svg', width: 24, height: 24),
            tooltip: 'Chat history',
            onPressed: () {},
          ),
          IconButton(
            icon: SvgPicture.asset('assets/svg/icon_close.svg', width: 24, height: 24),
            tooltip: 'Close',
            onPressed: () => Navigator.maybePop(context),
          ),
        ],
      ),
      body: ChatScope(
        addBotMessage: _controller.addBotMessage,
        markSurfaceAsForm: _controller.markSurfaceAsForm,
        clearSurfaceForm: _controller.clearSurfaceForm,
        child: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final messages = _controller.messages;
                final showThinking = _controller.showThinkingIndicator;
                final showSuggestions = !_controller.hasUserMessages;
                final extraCount = showThinking ? 1 : 0;
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: messages.length + extraCount,
                        itemBuilder: (context, index) {
                          if (index < messages.length) {
                            return _MessageItem(
                              entry: messages[index],
                              surfaceHost: _controller.surfaceHost,
                              isLastInGroup: _isLastInSenderGroup(messages, index, botTypingFollows: showThinking),
                            );
                          }
                          return ChatTypingPhraseBubble(key: ValueKey<int>(messages.length));
                        },
                      ),
                    ),
                    if (showSuggestions)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: ChatQuickReplyColumn(suggestions: kDefaultChatQuickReplies, onSelect: _sendPrefilled),
                      ),
                  ],
                );
              },
            ),
          ),
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) =>
                _InputBar(controller: _textController, onSend: _send, isWaiting: _controller.isWaiting),
          ),
        ],
        ),
      ),
    );
  }
}

bool _isLastInSenderGroup(List<ChatEntry> messages, int index, {required bool botTypingFollows}) {
  final entry = messages[index];
  if (entry.isSurface) return false;

  if (index + 1 < messages.length && messages[index + 1].isUser == entry.isUser) {
    return false;
  }

  if (!entry.isUser && botTypingFollows && index == messages.length - 1) {
    return false;
  }

  return true;
}

class _MessageItem extends StatelessWidget {
  final ChatEntry entry;
  final SurfaceHost surfaceHost;
  final bool isLastInGroup;

  const _MessageItem({required this.entry, required this.surfaceHost, required this.isLastInGroup});

  @override
  Widget build(BuildContext context) {
    if (entry.isSurface) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Surface(surfaceContext: surfaceHost.contextFor(entry.surfaceId!)),
      );
    }

    if (entry.isUser) {
      return _UserBubble(text: entry.text ?? '', isLastInGroup: isLastInGroup);
    }

    return _AiBubble(text: entry.text ?? '', isLastInGroup: isLastInGroup);
  }
}

class _UserBubble extends StatelessWidget {
  final String text;
  final bool isLastInGroup;

  const _UserBubble({required this.text, required this.isLastInGroup});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.fromLTRB(56, 4, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: ShapeDecoration(
          color: MayaChatTheme.brandGreen,
          shape: ContinuousRectangleBorder(
            borderRadius: MayaChatTheme.bubbleBorderRadius(isUser: true, isLastInGroup: isLastInGroup),
          ),
        ),
        child: Text(text, style: MayaChatTheme.userBubbleTextStyle(Colors.white)),
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  final String text;
  final bool isLastInGroup;

  const _AiBubble({required this.text, required this.isLastInGroup});

  @override
  Widget build(BuildContext context) {
    final baseStyle = MayaChatTheme.botBubbleTextStyle(MayaChatTheme.appBarTitle);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 56, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: ShapeDecoration(
          color: MayaChatTheme.botBubbleBackground,
          shape: ContinuousRectangleBorder(
            borderRadius: MayaChatTheme.bubbleBorderRadius(isUser: false, isLastInGroup: isLastInGroup),
          ),
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
            blockSpacing: 20,
          ),
          shrinkWrap: true,
          softLineBreak: true,
        ),
      ),
    );
  }
}

class _InputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isWaiting;

  const _InputBar({required this.controller, required this.onSend, required this.isWaiting});

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  bool get _hasText => widget.controller.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final showSend = _hasText;
    final canSend = _hasText && !widget.isWaiting;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      color: Color.fromRGBO(244, 245, 245, 1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Always check key info since our chatbot can make mistakes',
              textAlign: TextAlign.center,
              style: TextStyle(color: MayaChatTheme.hintAndSubtitle, fontSize: 11, height: 1.3),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/svg/camera.svg',
                    width: 24,
                    height: 24,
                    colorFilter: widget.isWaiting
                        ? ColorFilter.mode(MayaChatTheme.appBarTitle.withValues(alpha: 0.38), BlendMode.srcIn)
                        : null,
                  ),
                  tooltip: 'Camera',
                  onPressed: widget.isWaiting ? null : () {},
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/svg/attachment.svg',
                    width: 24,
                    height: 24,
                    colorFilter: widget.isWaiting
                        ? ColorFilter.mode(MayaChatTheme.appBarTitle.withValues(alpha: 0.38), BlendMode.srcIn)
                        : null,
                  ),
                  tooltip: 'Attachments',
                  onPressed: widget.isWaiting ? null : () {},
                ),
                Flexible(
                  child: TextField(
                    controller: widget.controller,
                    onSubmitted: (_) {
                      if (canSend) widget.onSend();
                    },
                    textInputAction: TextInputAction.send,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(color: MayaChatTheme.appBarTitle, fontSize: 15),
                    cursorColor: MayaChatTheme.brandGreen,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      hintStyle: const TextStyle(color: MayaChatTheme.hintAndSubtitle),
                      filled: true,
                      fillColor: MayaChatTheme.scaffoldBackground,
                      contentPadding: EdgeInsets.fromLTRB(16, 12, showSend ? 6 : 16, 12),
                      suffixIcon: showSend
                          ? Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: canSend ? widget.onSend : null,
                                  borderRadius: BorderRadius.circular(13),
                                  child: SvgPicture.asset(
                                    canSend ? 'assets/svg/send_icon.svg' : 'assets/svg/send_icon_disable.svg',
                                    width: 26,
                                    height: 26,
                                  ),
                                ),
                              ),
                            )
                          : null,
                      suffixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 26),
                      border: OutlineInputBorder(
                        borderRadius: MayaChatTheme.inputFieldRadius,
                        borderSide: const BorderSide(color: MayaChatTheme.inputFieldBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: MayaChatTheme.inputFieldRadius,
                        borderSide: const BorderSide(color: MayaChatTheme.inputFieldBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: MayaChatTheme.inputFieldRadius,
                        borderSide: const BorderSide(color: MayaChatTheme.inputFieldBorder),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
