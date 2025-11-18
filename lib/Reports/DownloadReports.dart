import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart'; // Optional: to open the file directly

Future<void> downloadAndOpenReport(String base64Str) async {
  try {
    final decodedBytes = base64Decode(base64Str);
    final isPdf = _isPdf(decodedBytes);
    final fileName = isPdf ? "downloaded_report.pdf" : "downloaded_image.jpg";

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(decodedBytes);

    // Optionally open the file using OpenFile plugin
    await OpenFilex.open(file.path);

    print("✅ File saved and opened: ${file.path}");
  } catch (e) {
    print("❌ Error in downloadAndOpenReport: $e");
  }
}

bool _isPdf(List<int> bytes) {
  final header = utf8.decode(bytes.take(4).toList(), allowMalformed: true);
  return header.contains('%PDF');
}
