import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';

/// 🌈 Reusable App Gradient (top-left to bottom-right)
LinearGradient appGradient() {
  return const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    // colors: [secondaryColor, mainColor],
    colors: [secondaryColor, mainColor],
  );
}

LinearGradient appGradientGrey() {
  return const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.grey, Color.fromARGB(153, 158, 158, 158)],
  );
}

LinearGradient acrdGradient() {
  return const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 202, 214, 255), // equivalent to #CAD6FF
      Color.fromARGB(255, 121, 128, 153), // example shade close to #798099
    ],
  );
}

/// 📦 Optional: Common BoxDecoration with Gradient
BoxDecoration gradientBoxDecoration({double radius = 8.0}) {
  return BoxDecoration(
    gradient: appGradient(),
    borderRadius: BorderRadius.circular(radius),
  );
}

/// 🧱 Optional: Common Button Style (transparent to allow gradient)
ButtonStyle transparentButtonStyle({double radius = 8.0}) {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign textAlign;

  const GradientText(
    this.text, {
    required this.gradient,
    required this.style,
    this.textAlign = TextAlign.left,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
