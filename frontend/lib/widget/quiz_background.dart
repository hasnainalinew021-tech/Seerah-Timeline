import 'package:flutter/material.dart';

class QuizBackground extends StatelessWidget {
  final Widget child;

  const QuizBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Color
        Container(
          color: const Color(0xFFE0F2F1), // Light Teal/Green background
        ),
        // Decorative Circles (Soft Polka Dots)
        Positioned(
          top: -50,
          left: -50,
          child: _buildCircle(150),
        ),
        Positioned(
          top: 100,
          right: -30,
          child: _buildCircle(100),
        ),
        Positioned(
          bottom: -50,
          left: 50,
          child: _buildCircle(200),
        ),
        Positioned(
          top: 300,
          left: -40,
          child: _buildCircle(80),
        ),
        Positioned(
          bottom: 150,
          right: -40,
          child: _buildCircle(120),
        ),
        // Content
        SafeArea(child: child),
      ],
    );
  }

  Widget _buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
    );
  }
}
