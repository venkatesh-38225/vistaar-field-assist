import 'package:flutter/material.dart';

class AnimatedStepCircle extends StatefulWidget {
  final String text;
  final Color fillColor;
  final Color borderColor;

  const AnimatedStepCircle({
    required this.text,
    required this.fillColor,
    required this.borderColor,
    super.key,
  });

  @override
  State<AnimatedStepCircle> createState() => _AnimatedStepCircleState();
}

class _AnimatedStepCircleState extends State<AnimatedStepCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  bool get shouldAnimate => widget.fillColor != Colors.grey;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (shouldAnimate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedStepCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: widget.fillColor,
          shape: BoxShape.circle,
          border: Border.all(color: widget.borderColor, width: 3.0),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
