// Copyright (c) 2024-2025 2024mt12104@wilp.bits-pilani.ac.in
// All rights reserved.

import 'package:flutter/material.dart';

/// Custom App Logo Widget for AjB4APP
/// Features a stylized note/document icon with gradient colors
class AppLogo extends StatelessWidget {
  final double size;
  final bool animated;

  const AppLogo({super.key, this.size = 80.0, this.animated = true});

  @override
  Widget build(BuildContext context) {
    if (animated) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 2000),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return _buildLogo(value);
        },
      );
    } else {
      return _buildLogo(1.0);
    }
  }

  Widget _buildLogo(double animationValue) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5722).withOpacity(0.6 * animationValue),
            blurRadius: 30,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: const Color(0xFFFFAB40).withOpacity(0.3 * animationValue),
            blurRadius: 50,
            spreadRadius: 15,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background gradient circle
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                    const Color(0xFFFF5722),
                    const Color(0xFFFFAB40),
                    animationValue,
                  )!,
                  const Color(0xFFFF5722),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Note icon with pen
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Document/Note shape
              Icon(
                Icons.description_rounded,
                size: size * 0.5,
                color: Colors.white,
              ),
              // Small pen overlay
              Transform.translate(
                offset: Offset(size * 0.15, -size * 0.25),
                child: Transform.rotate(
                  angle: 0.5,
                  child: Icon(
                    Icons.edit_rounded,
                    size: size * 0.25,
                    color: const Color(0xFFFFAB40),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Simplified Logo for smaller displays
class AppLogoSimple extends StatelessWidget {
  final double size;

  const AppLogoSimple({super.key, this.size = 60.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFFFAB40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5722).withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FittedBox(
        child: Icon(Icons.note_alt_rounded, color: Colors.white),
      ),
    );
  }
}

/// Logo with Text for splash screens or large displays
class AppLogoWithText extends StatelessWidget {
  final double logoSize;
  final double fontSize;

  const AppLogoWithText({
    super.key,
    this.logoSize = 100.0,
    this.fontSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: logoSize, animated: true),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF5722), Color(0xFFFFAB40)],
          ).createShader(bounds),
          child: Text(
            'AjB4APP',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Note It Down!',
          style: TextStyle(
            fontSize: fontSize * 0.5,
            color: const Color(0xFFFF5722),
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
