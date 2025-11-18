import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Uint8List pdfDataFuture;

  PdfPreviewScreen(String path, {required this.pdfDataFuture, required String pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Preview"),
      ),
      body: FutureBuilder<File>(
        future: _savePdfTemporarily(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading PDF"));
          } else if (!snapshot.hasData) {
            return Center(child: Text("No PDF found"));
          }

          return PDFView(
            filePath: snapshot.data!.path,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            onError: (error) {
              print(error.toString());
            },
          );
        },
      ),
    );
  }

  Future<File> _savePdfTemporarily() async {
    // Generate the PDF bytes
    final pdfBytes = await pdfDataFuture;

    // Get the temporary directory
    final tempDir = await getTemporaryDirectory();

    // Save the PDF to a temporary file
    final tempFile = File("${tempDir.path}/preview.pdf");
    await tempFile.writeAsBytes(pdfBytes);

    return tempFile;
  }
}
