// gradient_shader.dart
import 'package:flutter/material.dart';

Shader createGradientShader({required double width, required double height}) {
  // Define gradient colors
  const Color startColor = Color(0xFF00AEEF); // Bright Sky Blue
  const Color endColor = Color(0xFF0072CE); // Deep Blue

  // Return a Linear Gradient Shader
  return LinearGradient(
    colors: [endColor, startColor],
  ).createShader(Rect.fromLTWH(0, 0, width, height));
}
