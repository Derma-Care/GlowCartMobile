import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FullscreenLoader extends StatefulWidget {
  final String message;

  final String logoPath;

  const FullscreenLoader({
    super.key,
    required this.message,
    required this.logoPath,
  });

  @override
  State<FullscreenLoader> createState() => _FullscreenLoaderState();
}

class _FullscreenLoaderState extends State<FullscreenLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration:
          const Duration(seconds: 4), // Total duration for the color cycle
      vsync: this,
    )..repeat(); // Repeat indefinitely

    _colorAnimation = _controller.drive(
      TweenSequence<Color?>([
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.teal, end: Colors.purple),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.purple, end: Colors.orange),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.orange, end: Colors.green),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.green, end: Colors.teal),
          weight: 1,
        ),
      ]),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(100, 2, 2, 2),
      body: Center(
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white, // White box background
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display logo
              Image.asset(
                widget.logoPath,
                height: 60, // Adjust the height of the logo
                width: 60, // Adjust the width of the logo
              ),
              SizedBox(
                height: 5.0,
              ),
              // Loading spinner
              Center(
                child: AnimatedBuilder(
                  animation: _colorAnimation,
                  builder: (context, child) {
                    return SpinKitCircle(
                      color: _colorAnimation.value, // Dynamic color
                      size: 20.0, // Adjust size as needed
                    );
                  },
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              // Loading text
              Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black, // Text color for contrast
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
