import 'dart:io';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;

  const ImagePreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: "Preview Image",
      ),
      body: Center(
        child: imagePath.isNotEmpty
            ? Image.file(
                File(imagePath)) // Display image using the provided path
            : const Text(
                "No image to preview"), // Handle error if no image path
      ),
    );
  }
}
