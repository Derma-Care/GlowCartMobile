import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> savePdfToDownloads(BuildContext context, List<int> pdfBytes) async {
  // Request storage permission (Android)
  if (Platform.isAndroid) {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
        return;
      }
    }
  }

  // Get folder
  Directory? dir;
  if (Platform.isAndroid) {
    dir = Directory("/storage/emulated/0/Download"); // Android public Downloads
  } else if (Platform.isIOS) {
    dir = await getApplicationDocumentsDirectory(); // iOS sandbox
  } else {
    dir = await getDownloadsDirectory(); // Desktop
  }

  // Save PDF
  if (dir != null) {
    final filePath = "${dir.path}/patient_signature.pdf";
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("PDF saved to: $filePath")),
    );
  }
}
