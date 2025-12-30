import 'package:flutter/material.dart';

class Copyrights extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final TextStyle? style;
  final MainAxisAlignment alignment;
  final Color color;
  const Copyrights(
      {super.key,
      this.padding = const EdgeInsets.all(8.0),
      this.style,
      this.alignment = MainAxisAlignment.center,
      this.color = Colors.black54});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: alignment,
        children: [
          Text(
            "© 2025 Neha's Glow Kart. All rights reserved.",
            style: style ??
                TextStyle(
                  fontSize: 14,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
