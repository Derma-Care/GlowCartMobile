import 'dart:io';

import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/PDFPreview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientReportScreen extends StatefulWidget {
  final String mobileNumber;
  const PatientReportScreen({super.key, required this.mobileNumber});

  @override
  State<PatientReportScreen> createState() => _PatientReportScreenState();
}

class _PatientReportScreenState extends State<PatientReportScreen> {
  bool loading = true;
  Map<String, dynamic>? customerData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await Future.delayed(const Duration(seconds: 1));

    // 🔹 Dummy API response
    customerData = {
      "customerMobile": widget.mobileNumber,
      "patients": [
        {
          "patientId": "P001",
          "name": "John",
          "visits": [
            {
              "visitId": "V001",
              "date": "2025-09-01",
              "reports": [
                "https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf",
                "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
              ],
              "prescriptionPdf":
                  "https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf",
              "beforeImages": [
                "https://img.freepik.com/premium-photo/model-with-natural-look_14117-24000.jpg",

                // "https://picsum.photos/201/300"
              ],
              "afterImages": [
                "https://picsum.photos/202/300",
                "https://picsum.photos/203/300"
              ]
            }
          ]
        },
        {
          "patientId": "P002",
          "name": "Jane",
          "visits": [
            {
              "visitId": "V002",
              "date": "2025-09-05",
              "reports": [
                "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"
              ],
              "prescriptionPdf":
                  "https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf",
              "beforeImages": [
                "https://images.huffingtonpost.com/2011-06-20-LETHA_before_after.jpg"
                // "https://picsum.photos/204/300",
                // "https://picsum.photos/205/300"
              ],
              "afterImages": [
                "https://picsum.photos/206/300",
                "https://picsum.photos/207/300"
              ]
            }
          ]
        }
      ]
    };

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    final patients = customerData!["patients"] as List;

    return Scaffold(
      appBar: CommonHeader(
        title: "Patient Reports",
      ),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          final visits = patient["visits"] as List;

          return ExpansionTile(
            title:
                Text("Patient: ${patient["name"]} (${patient["patientId"]})"),
            children: visits.map((visit) => VisitCard(visit: visit)).toList(),
          );
        },
      ),
    );
  }
}

class VisitCard extends StatelessWidget {
  final Map<String, dynamic> visit;
  const VisitCard({super.key, required this.visit});

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _previewPdf(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(pdfUrl: url),
      ),
    );
  }

  void _previewImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewScreen(imageUrl: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Visit Date: ${visit["date"]}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

            const SizedBox(height: 10),

            // Reports (Multiple PDFs)
            const Text("Reports",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...(visit["reports"] as List).map((pdfUrl) => Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _previewPdf(context, pdfUrl),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Preview"),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => _openFile(pdfUrl),
                      icon: const Icon(Icons.download),
                      label: const Text("Download"),
                    ),
                  ],
                )),

            const SizedBox(height: 10),

            // Prescription PDF (Single)
            const Text("Prescription",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      _previewPdf(context, visit["prescriptionPdf"]),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Preview"),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _openFile(visit["prescriptionPdf"]),
                  icon: const Icon(Icons.download),
                  label: const Text("Download"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Before Images
            const Text("Before/After Images",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (visit["beforeImages"] as List).length,
                itemBuilder: (context, i) {
                  final imgUrl = visit["beforeImages"][i];
                  return GestureDetector(
                    onTap: () => _previewImage(context, imgUrl),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.network(
                        imgUrl,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // After Images
            // const Text("After Images",
            //     style: TextStyle(fontWeight: FontWeight.bold)),
            // SizedBox(
            //   height: 120,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     itemCount: (visit["afterImages"] as List).length,
            //     itemBuilder: (context, i) {
            //       final imgUrl = visit["afterImages"][i];
            //       return GestureDetector(
            //         onTap: () => _previewImage(context, imgUrl),
            //         child: Padding(
            //           padding: const EdgeInsets.all(4.0),
            //           child: Image.network(
            //             imgUrl,
            //             height: 120,
            //             width: 120,
            //             fit: BoxFit.cover,
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  const PdfViewerScreen({super.key, required this.pdfUrl});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadAndSavePdf();
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final bytes = response.bodyBytes;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp.pdf');
      await file.writeAsBytes(bytes, flush: true);

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading PDF: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: "PDF Viewer",
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : localPath != null
              ? PDFView(
                  filePath: localPath!,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageSnap: true,
                )
              : const Center(child: Text("Failed to load PDF")),
    );
  }
}

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;
  const ImagePreviewScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: "Image Preview",
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
        ),
      ),
    );
  }
}
