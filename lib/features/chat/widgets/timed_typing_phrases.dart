import 'dart:async';

import 'package:flutter/material.dart';

/// Status lines shown while the assistant is preparing a reply, advancing on a fixed schedule.
class TimedTypingPhrases extends StatefulWidget {
  const TimedTypingPhrases({
    super.key,
    this.style,
    this.enableFadingAnimation = false,
  });

  final TextStyle? style;
  final bool enableFadingAnimation;

  @override
  State<TimedTypingPhrases> createState() => _TimedTypingPhrasesState();
}

class _TimedTypingPhrasesState extends State<TimedTypingPhrases>
    with SingleTickerProviderStateMixin {
  static const _phrases = [
    'Thinking…',
    'Working on it…',
    'Getting the latest info…',
    'Checking the details…',
    'Preparing a helpful response…',
    "Don't worry, I'm still working on it… thanks for waiting!",
  ];

  /// When each spiel begins (seconds elapsed since mount).
  static const _breakpoints = [0, 5, 15, 25, 35, 45];

  AnimationController? _controller;
  Animation<double>? _opacity;
  int _index = 0;
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;

  static const _fadeIn = Duration(milliseconds: 400);
  static const _fadeOut = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    if (widget.enableFadingAnimation) {
      _controller = AnimationController(
        vsync: this,
        duration: _fadeIn,
        reverseDuration: _fadeOut,
      );
      _opacity = CurvedAnimation(parent: _controller!, curve: Curves.easeInOut);
      _controller!.forward();
    }
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void _onTick(Timer timer) {
    if (!mounted) return;
    _elapsedSeconds++;
    final nextIndex = _indexForElapsed(_elapsedSeconds);
    if (nextIndex != _index) {
      _advanceTo(nextIndex);
    }
  }

  int _indexForElapsed(int seconds) {
    for (var i = _breakpoints.length - 1; i >= 0; i--) {
      if (seconds >= _breakpoints[i]) return i;
    }
    return 0;
  }

  Future<void> _advanceTo(int nextIndex) async {
    if (widget.enableFadingAnimation) {
      await _controller!.reverse();
      if (!mounted) return;
      setState(() => _index = nextIndex);
      await _controller!.forward();
      return;
    }

    setState(() => _index = nextIndex);
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        widget.style ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontStyle: FontStyle.italic,
        );

    final text = Text(_phrases[_index], style: baseStyle);
    if (!widget.enableFadingAnimation || _opacity == null) return text;

    return FadeTransition(opacity: _opacity!, child: text);
  }
}
