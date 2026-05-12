import 'dart:async';

import 'package:flutter/material.dart';

/// Short status lines shown while the assistant is preparing a reply, with a gentle fade cycle.
class CyclingFadePhrases extends StatefulWidget {
  const CyclingFadePhrases({
    super.key,
    required this.phrases,
    this.style,
    /// When set (e.g. `2`), that many distinct lines are chosen at random from [phrases]
    /// and only those are cycled until this widget is disposed. When null, all [phrases] cycle in order.
    this.randomSubsetSize,
  });

  final List<String> phrases;
  final TextStyle? style;
  final int? randomSubsetSize;

  @override
  State<CyclingFadePhrases> createState() => _CyclingFadePhrasesState();
}

class _CyclingFadePhrasesState extends State<CyclingFadePhrases>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _opacity;
  late List<String> _activePhrases;
  int _index = 0;
  Timer? _phraseTimer;

  /// Fade in + fade out = 2 s total so each spiel is readable.
  static const _fadeIn = Duration(seconds: 1);
  static const _hold = Duration(milliseconds: 800);
  static const _fadeOut = Duration(seconds: 1);

  List<String> _buildActivePhrases() {
    final all = widget.phrases;
    if (all.isEmpty) return [];
    final k = widget.randomSubsetSize;
    if (k == null || k < 1) return List<String>.from(all);
    final take = k > all.length ? all.length : k;
    final pool = List<String>.from(all)..shuffle();
    return pool.sublist(0, take);
  }

  @override
  void initState() {
    super.initState();
    _activePhrases = _buildActivePhrases();
    _controller = AnimationController(
      vsync: this,
      duration: _fadeIn,
      reverseDuration: _fadeOut,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.addStatusListener(_onAnimStatus);
    _startCycle();
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _phraseTimer?.cancel();
      _phraseTimer = Timer(_hold, () {
        if (!mounted) return;
        _controller.reverse();
      });
    } else if (status == AnimationStatus.dismissed) {
      if (!mounted) return;
      final len = _activePhrases.length;
      if (len == 0) return;
      setState(() {
        _index = (_index + 1) % len;
      });
      _controller.forward();
    }
  }

  void _startCycle() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant CyclingFadePhrases oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.randomSubsetSize != widget.randomSubsetSize ||
        !_listEq(oldWidget.phrases, widget.phrases)) {
      setState(() {
        _activePhrases = _buildActivePhrases();
        _index = 0;
      });
    }
  }

  bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _phraseTimer?.cancel();
    _controller.removeStatusListener(_onAnimStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_activePhrases.isEmpty) return const SizedBox.shrink();

    final baseStyle =
        widget.style ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontStyle: FontStyle.italic,
        );

    // Show the spiels fading in/out for 2 sec in CyclingFadePhrases. Used by the build() method.
    return FadeTransition(
      opacity: _opacity,
      child: Text(_activePhrases[_index], style: baseStyle),
    );
  }
}
