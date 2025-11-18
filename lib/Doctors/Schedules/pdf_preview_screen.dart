import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfPreviewScreen extends StatelessWidget {
  final File file;
  const PdfPreviewScreen({super.key, required this.file, required String pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview Consent PDF")),
      body: PdfPreview(build: (format) async => file.readAsBytes()),
    );
  }
}
