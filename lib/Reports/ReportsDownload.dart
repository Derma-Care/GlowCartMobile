import 'package:cutomer_app/BottomNavigation/Appoinments/GetAppointmentModel.dart';
import 'package:cutomer_app/Reports/DownloadReports.dart';
import 'package:cutomer_app/Reports/FilePreviewScreen.dart';
import 'package:flutter/material.dart';

import '../PatientsDetails/PatientModel.dart';

Future<void> showReportDownloadSheet(
  BuildContext context,
  List<ReportItem> reports,
) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Available Reports",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              for (var report in reports)
                for (var i = 0; i < report.reportFile.length; i++)
                  Card(
                    child: ListTile(
                      title: Text('${report.reportName} - File ${i + 1}'),
                      subtitle: Text("Type: ${report.reportType}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye_outlined),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FilePreviewScreen(
                                    fileUrl: report.reportFile[i],
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () async {
                              Navigator.pop(context);
                              await downloadAndOpenReport(report.reportFile[i]);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      );
    },
  );
}
