import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfGenerator {
  static Future<String> generateInvoice(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // Extract data from the input map
    final date = data['date'];
    final customerName = data['customerName'];
    final customerAddress = data['customerAddress'];
    final items = List<Map<String, dynamic>>.from(data['items']);
    final total = data['total'];

    // Load assets
    final logoBytes = await File('assets/surecare_launcher.png').readAsBytes();
    final backgroundBytes =
        await File('assets/background_image.png').readAsBytes();

    // Create PDF
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Stack(
          children: [
            pw.Positioned(
              child: pw.Image(
                pw.MemoryImage(backgroundBytes),
                fit: pw.BoxFit.cover,
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(
                      pw.MemoryImage(logoBytes),
                      height: 50,
                    ),
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 30,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('Date: $date'),
                pw.SizedBox(height: 10),
                pw.Text('Customer Name: $customerName'),
                pw.Text('Address: $customerAddress'),
                pw.SizedBox(height: 20),
                pw.Text('Invoice Details:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                ...items.map((item) => pw.Text(
                    '${item['name']} - \$${item['price']}')).toList(),
                pw.Divider(),
                pw.Text('Total: \$${total}',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );

    // Save the PDF to the external directory
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/invoice.pdf';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath; // Return the saved file path
  }
}
