import 'dart:typed_data';
import 'dart:io';

import 'package:cutomer_app/Utils/PDFPreview.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
// import 'package:open_file/open_file.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../BottomNavigation/Appoinments/BookingModal.dart';

class InvoicePage {
  String generateInvoiceNumber() {
    String sequenceNumber = "00001";
    final yearPart = DateFormat('yyyy').format(DateTime.now());
    final sequencePart = sequenceNumber.toString().padLeft(3, '0');
    return 'SURECARE-$yearPart-INV$sequencePart';
  }

  Future<Uint8List> generatePdf(
      PdfPageFormat format, AppointmentData appointment) async {
    const String gstNo = "07AAAAA1234A1Z1";
    final pdf = pw.Document();
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    final String invoiceNumber = generateInvoiceNumber();

    // Load custom font
    final fontData = await rootBundle.load('assets/NotoSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // Load the logo image
    final imageBytes = await rootBundle.load('assets/white_logo.png');
    final image = pw.MemoryImage(imageBytes.buffer.asUint8List());

    dynamic pricePerDay;
    dynamic totalCost;
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            // crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header Section
              pw.Container(
                color: PdfColors.teal,
                padding: pw.EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "SURECARE",
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 26,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "Shop No: 8-2-893/82/490, Jubilee Hills Road Number 10\nBeside UCO Bank, near H&M, Hyderabad, Telangana 500033",
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 10,
                                color: PdfColors.white,
                              ),
                            ),
                          ],
                        ),
                        pw.Image(
                          image,
                          width: format.width * 0.10,
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "Invoice #: $invoiceNumber",
                              style: pw.TextStyle(
                                font: ttf,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              "Booking ID #: ${appointment.appointmentId}",
                              style: pw.TextStyle(
                                  font: ttf, color: PdfColors.white),
                            ),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              "Service ID #: ${appointment.servicesAdded.first.serviceId}",
                              style: pw.TextStyle(
                                  font: ttf, color: PdfColors.white),
                            ),
                          ],
                        ),
                        pw.Text(
                          "Date: $formattedDate",
                          style:
                              pw.TextStyle(font: ttf, color: PdfColors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // Customer Details Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex:
                        2, // Allocate 2/3 of the row's width to the Invoice To section
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Invoice To:",
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(appointment.patientName,
                            style: pw.TextStyle(font: ttf)),
                        pw.Text("${appointment.customerNumber}",
                            style: pw.TextStyle(font: ttf)),
                        pw.Text("${appointment.emailId}",
                            style: pw.TextStyle(font: ttf)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex:
                        1, // Allocate 1/3 of the row's width to the GST section
                    child: pw.Text(
                      "GST No: $gstNo",
                      style: pw.TextStyle(font: ttf),
                      textAlign: pw.TextAlign.right, // Align text to the right
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 16),

              // Table Header
              pw.Container(
                color: PdfColors.teal,
                padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text("Item Description",
                          style:
                              pw.TextStyle(font: ttf, color: PdfColors.white)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text("No.of\nDays",
                          style:
                              pw.TextStyle(font: ttf, color: PdfColors.white)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text("Actual Price",
                          style:
                              pw.TextStyle(font: ttf, color: PdfColors.white)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text("Grand\nTotal",
                          style:
                              pw.TextStyle(font: ttf, color: PdfColors.white)),
                    ),
                  ],
                ),
              ),

              // Table Content
              ...appointment.servicesAdded.map((service) {
                pricePerDay = service.price / service.numberOfDays;
                totalCost = service.finalCost;
                return pw.Container(
                  padding: pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 5,
                        child: pw.Text(service.serviceName,
                            style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text("${service.numberOfDays}",
                            style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text("₹ ${pricePerDay.toStringAsFixed(0)}",
                            style: pw.TextStyle(font: ttf)),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                            "₹ ${service.finalCost.toStringAsFixed(0)}",
                            style: pw.TextStyle(font: ttf)),
                      ),
                    ],
                  ),
                );
              }).toList(),

              pw.SizedBox(height: 16),

              // Summary Section
              pw.Divider(color: PdfColors.grey),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("A. Subtotal:",
                      style: pw.TextStyle(
                          font: ttf, fontWeight: pw.FontWeight.bold)),
                  pw.Text("₹ ${pricePerDay.toStringAsFixed(0)}",
                      style: pw.TextStyle(font: ttf)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("B. Discount Amount:",
                      style: pw.TextStyle(
                          font: ttf, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      "-₹ ${appointment.servicesAdded.first.discountAmount.toStringAsFixed(0)}",
                      style: pw.TextStyle(font: ttf)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("C. Discounted Amount:",
                      style: pw.TextStyle(
                          font: ttf, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      "₹ ${appointment.servicesAdded.first.discountedCost.toStringAsFixed(0)}",
                      style: pw.TextStyle(font: ttf)),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("D. Tax & Charges:",
                      style: pw.TextStyle(
                          font: ttf, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      "₹ ${appointment.servicesAdded.first.taxAmount.toStringAsFixed(0)}",
                      style: pw.TextStyle(font: ttf)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColors.grey),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Grand Total (C+D):",
                      style: pw.TextStyle(
                          font: ttf,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16)),
                  pw.Text(
                      "₹ ${appointment.servicesAdded.first.finalCost.toStringAsFixed(0)}",
                      style: pw.TextStyle(font: ttf, fontSize: 16)),
                ],
              ),

              pw.Spacer(),

              // Footer Section
              pw.Text(
                "Thank you for your business!",
                style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // void _showPdfPreview(
  //     BuildContext context, AppointmentData appointment) async {
  //   final pdfData = await generatePdf(PdfPageFormat.a4, appointment);

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => PdfPreviewScreen(
  //         pdfDataFuture: Future.value(pdfData),
  //       ),
  //     ),
  //   );
  // }

  Future<void> checkPermissions() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    if (await Permission.manageExternalStorage.isDenied) {
      await Permission.manageExternalStorage.request();
    }
  }

  Future<void> downloadPdf(
      BuildContext context, AppointmentData appointment) async {
    try {
      // Check and request permissions
      await checkPermissions();

      // Generate the PDF
      final pdfBytes = await generatePdf(PdfPageFormat.a4, appointment);
      final directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      // Get app-specific directory
      // final directory = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final formattedTimestamp = DateFormat('yyyyMMdd').format(now);
      final filePath =
          '${directory.path}/${appointment.servicesAdded.first.serviceName}_$formattedTimestamp.pdf';

      // Save the PDF
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Show success message with "Open" option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invoice downloaded to $filePath"),
          action: SnackBarAction(
            label: "Open",
            onPressed: () async {
              final result = await OpenFilex.open(file.path);
              if (result.type != ResultType.done) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text("Could not open the file: ${result.message}")),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving file: $e")),
      );
    }
  }
}
