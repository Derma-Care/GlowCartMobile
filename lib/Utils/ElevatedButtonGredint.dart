import 'package:flutter/material.dart';

import 'GradintColor.dart'; // <- where your appGradient() is defined

class GradientButton extends StatelessWidget {
  final String? text;
  final Widget? child; // NEW: support for Obx or custom content
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final double minWidth;

  const GradientButton({
    super.key,
    this.text,
    this.child,
    required this.onPressed,
    this.borderRadius = 10.0,
    this.padding = const EdgeInsets.symmetric(vertical: 15.0, horizontal: 60.0),
    this.textStyle,
    this.minWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: appGradient(),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            padding: padding,
            constraints: BoxConstraints(minWidth: minWidth),
            alignment: Alignment.center,
            child: child ??
                Text(
                  text ?? "",
                  style: textStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                ),
          ),
        ),
      ),
    );
  }
}
