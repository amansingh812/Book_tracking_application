import 'package:flutter/material.dart';

class ThinkingDots extends StatefulWidget {
  const ThinkingDots({super.key});

  @override
  State<ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<ThinkingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dot1 = _controller.value >= 0.0 && _controller.value <= 0.6 ? 1.0 : 0.4;
        final dot2 = _controller.value >= 0.2 && _controller.value <= 0.8 ? 1.0 : 0.4;
        final dot3 = _controller.value >= 0.4 && _controller.value <= 1.0 ? 1.0 : 0.4;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(opacity: dot1, child: _buildDot()),
            const SizedBox(width: 4),
            Opacity(opacity: dot2, child: _buildDot()),
            const SizedBox(width: 4),
            Opacity(opacity: dot3, child: _buildDot()),
          ],
        );
      },
    );
  }

  Widget _buildDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        shape: BoxShape.circle,
      ),
    );
  }
}
