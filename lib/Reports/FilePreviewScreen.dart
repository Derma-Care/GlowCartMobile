import 'dart:convert';
import 'dart:io';

import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

class FilePreviewScreen extends StatefulWidget {
  final String fileUrl; // base64 string

  const FilePreviewScreen({super.key, required this.fileUrl});

  @override
  State<FilePreviewScreen> createState() => _FilePreviewScreenState();
}

class _FilePreviewScreenState extends State<FilePreviewScreen> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _createTempFileFromBase64();
  }

  Future<void> _createTempFileFromBase64() async {
    try {
      final decodedBytes = base64Decode(widget.fileUrl);

      final isPdfFile = _isPdf(decodedBytes);
      final fileName = isPdfFile ? "preview.pdf" : "preview.jpg";
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/$fileName");
      await file.writeAsBytes(decodedBytes);

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error decoding base64: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _isPdf(List<int> bytes) {
    final header = utf8.decode(bytes.take(4).toList(), allowMalformed: true);
    return header.contains('%PDF');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: "Preview"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : localPath!.endsWith('.pdf')
              ? PDFView(filePath: localPath!)
              : PhotoView(imageProvider: FileImage(File(localPath!))),
    );
  }
}
