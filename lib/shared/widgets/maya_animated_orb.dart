import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MayaAnimatedOrb extends StatelessWidget {
  const MayaAnimatedOrb({super.key, this.size = 148});

  final double size;

  // Glow radius is larger than the sphere so it bleeds outward like a halo.
  double get _glowSize => size * 1.55;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _glowSize,
      height: _glowSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Programmatic glow ──────────────────────────────────────────────
          // The Lottie file's "Glow Outlines" layer uses a linear gradient
          // (t=2) instead of radial (t=1), so the AE glow effect is invisible
          // at runtime. We replicate it here with a blurred radial gradient.
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              width: size * 1.15,
              height: size * 1.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00DD6E).withValues(alpha: 0.75),
                    const Color(0xFF00A651).withValues(alpha: 0.40),
                    const Color(0xFF00A651).withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // ── Lottie sphere ──────────────────────────────────────────────────
          Lottie.asset(
            'assets/lottie/maya_orb.json',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
