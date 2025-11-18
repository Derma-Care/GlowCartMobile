import 'dart:convert';
import 'dart:typed_data';
import 'package:cutomer_app/Booings/BooingService.dart';

import 'package:cutomer_app/BottomNavigation/Appoinments/GetAppointmentModel.dart';
import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';

import 'package:cutomer_app/Consultations/SymptomsController.dart';
import 'package:cutomer_app/Controller/CustomerController.dart';
import 'package:cutomer_app/Doctors/Schedules/ConsentFormAPI.dart';
import 'package:cutomer_app/Doctors/Schedules/ConsentFromModal.dart';
import 'package:cutomer_app/Doctors/Schedules/UserDataConsentScreen.dart';
import 'package:cutomer_app/Doctors/Schedules/consent_form_model.dart';
import 'package:cutomer_app/Help/Numbers.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';

import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';

import 'package:url_launcher/url_launcher.dart';
import '../ListOfDoctors/HospitalAndDoctorModel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SkinCareConsentFormScreen extends StatefulWidget {
  final HospitalDoctorModel doctor;
  // final PatientModel? patient;
  final String? bookingId;
  final String? pID;
  final Getappointmentmodel? doctorBookings;

  const SkinCareConsentFormScreen({
    Key? key,
    required this.doctor,
    // required this.patient,
    this.bookingId,
    this.pID,
    this.doctorBookings,
  }) : super(key: key);

  @override
  State<SkinCareConsentFormScreen> createState() =>
      _SkinCareConsentFormScreenState();
}

class _SkinCareConsentFormScreenState extends State<SkinCareConsentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SignatureController _patientSignController;
  // final SignatureController patientSignController = SignatureController();
  DateTime _procedureDate = DateTime.now();
  final selectedServicesController = Get.find<SelectedServicesController>();
  // consent points
  final scontroller = SymptomsController();
  final Map<String, bool> _consentPoints = {
    "I consent to the procedure": true,
    "I consent to the use of my data": true,
    "I agree to receive follow-up communications": true,
  };

  bool _agreed = false;
  bool _signatureSaved = false;
  Uint8List? _pdfBytes;
  bool _patientSigned = false;
  ConsentForm? consentFormData;
  String? procedureName;
  final String procedure =
      "I hereby provide my informed consent to undergo the procedure and acknowledge that I have understood the associated pre-procedure, procedure, and post-procedure care and guidelines and the corresponding possible reactions and risks.";
  String? userData;
  @override
  void initState() {
    super.initState();
    _patientSignController = SignatureController(penStrokeWidth: 2);
    fetchConsentForm();
    print("clinicId ))_${widget.doctor.hospital.hospitalId}");
    print("subServiceId ))_${widget.pID}");

    print("Doctor signuture ${widget.doctor.doctor.doctorSignature}");
    setState(() {
      userData =
          "I, ${widget.doctorBookings!.name}, hereby give my voluntary and informed consent for the collection, storage, and use of my medical records, personal health information, and diagnostic images for purposes including research, education, training, and improving medical services. I understand that all information will be handled in accordance with applicable privacy laws and regulations, and that my identity will be protected unless I provide separate written authorization. I acknowledge that participation is voluntary and that I may withdraw my consent at any time, without affecting the medical care I receive.";
    });
  }

  @override
  void dispose() {
    _patientSignController.dispose();
    super.dispose();
  }

  // void _openQuestions() {
  //   // Navigate to your Questions page or show a dialog
  //   print('Questions button clicked');
  // }

  void _openQuestions(BuildContext context) {
    print("_openQuestions calling ");
    showDialog(
      context: context,
      builder: (context) {
        // List of questions and answers
        final faqList = [
          {
            "question": "How was the quality of the service you received?",
            "answer":
                "The service was excellent, and the staff followed all the procedures carefully."
          },
          {
            "question": "Was the service completed on time?",
            "answer":
                "Yes, the appointment started and ended on time without any delays."
          },
          {
            "question": "Was the cost of the service reasonable?",
            "answer":
                "The cost was fair and matched the quality of care provided."
          },
          {
            "question": "How clean was Pragna Clinic?",
            "answer":
                "The clinic was very clean and well-maintained, giving a safe and comfortable environment."
          },
          {
            "question": "Was the staff polite and helpful?",
            "answer":
                "The staff were courteous, attentive, and made the visit smooth."
          },
          {
            "question":
                "How would you rate your overall experience at Pragna Clinic?",
            "answer":
                "Overall, the experience was excellent, and I felt well taken care of."
          },
          {
            "question": "Was this branch easy to find?",
            "answer":
                "The branch was easy to locate, with clear directions and signage."
          },
          {
            "question": "Was the waiting time at this branch reasonable?",
            "answer": "The waiting time was minimal and managed efficiently."
          },
          {
            "question": "How friendly was the reception staff?",
            "answer": "The reception staff were very friendly and welcoming."
          },
          {
            "question": "Would you visit this branch again?",
            "answer":
                "Yes, I would definitely return to this branch in the future."
          },
        ];

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: Container(
            padding: const EdgeInsets.all(8),
            constraints: BoxConstraints(maxHeight: 500),
            child: Column(
              children: [
                const Text(
                  "Frequently Asked Questions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: faqList.length,
                    itemBuilder: (context, index) {
                      final item = faqList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Q${index + 1}: ${item['question']}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "A: ${item['answer']}",
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Utility
  Uint8List? decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;

    // Remove "data:image/png;base64," if present
    final cleaned = base64String.split(',').last;
    return base64Decode(cleaned);
  }

  final consentFormService = ConsentFormService();

  void fetchConsentForm() async {
    final data = await consentFormService.getConsentForm(
      clinicId: widget.doctor.hospital.hospitalId,
      subServiceId: widget.pID ??
          selectedServicesController.selectedSubServices.first.subServiceId,
      procedureId: "1", // 👈 fallback generic form
    );

    if (data != null) {
      setState(() {
        consentFormData = data;
        procedureName = data.subServiceName;
      });

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => ConsentFormScreen(consentFormData: consentFormData!),
      //   ),
      // );
    } else {
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "No consent form available",
        type: SnackbarType.warning,
      );
    }
  }

  Future<Uint8List> _buildPdf() async {
    final pdf = pw.Document();
    final dateFmt = DateFormat('dd MMM yyyy');

    // ✅ Load logo if available

    final logoBytes = decodeBase64Image(
        widget.doctor.hospital.hospitalLogo); // Uint8List from constructor
    final doctorSignPng = widget.doctor.doctor.doctorSignature;
    final patientSignPng = _patientSignController.isNotEmpty
        ? await _patientSignController.toPngBytes()
        : null;

    Uint8List? base64ToUint8List(String? base64String) {
      if (base64String == null || base64String.isEmpty) return null;

      // Remove prefix if exists (like "data:image/png;base64,")
      final cleaned = base64String.split(',').last;

      return base64Decode(cleaned);
    }

    final Uint8List? doctorSignBytes = base64ToUint8List(doctorSignPng);
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          // 🏥 Header with Logo + Clinic Info
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              if (logoBytes != null)
                pw.Container(
                  height: 60,
                  width: 60,
                  child: pw.Image(pw.MemoryImage(logoBytes)),
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(widget.doctor.hospital.name,
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      "Branch: ${(widget.doctor.hospital.branch != null && widget.doctor.hospital.branch != "" && widget.doctor.hospital.branch!.isNotEmpty) ? widget.doctor.hospital.branch : widget.doctor.hospital.city}",
                      style: pw.TextStyle(fontSize: 12)),
                ],
              )
            ],
          ),

          pw.SizedBox(height: 16),

          pw.Center(
            child: pw.Text("Consent for ${procedureName} Procedure",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ),

          pw.Divider(),

          // 🧑‍⚕️ Doctor Info Section
          pw.Text("Doctor Information",
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text("Name: ${widget.doctor.doctor.doctorName}"),
          pw.Text("Specialization: ${widget.doctor.doctor.specialization}"),
          pw.Text("License No: ${widget.doctor.doctor.doctorLicence}"),
          pw.SizedBox(height: 12),

          // 👩‍🦰 Patient Info Section
          pw.Text("Patient Information",
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text("Name: ${widget.doctorBookings?.name ?? ""}"),
          pw.Text("Mobile: ${widget.doctorBookings?.mobileNumber ?? ""}"),
          pw.Text("Gender: ${widget.doctorBookings?.gender ?? ""}"),
          pw.Text("Age: ${widget.doctorBookings?.age ?? ""}"),
          // pw.Text("Address: ${widget.patient.}"),
          pw.Text("Procedure Date: ${dateFmt.format(_procedureDate)}"),
          pw.SizedBox(height: 12),

          // ✅ Consent Points
          // pw.Text("Agreed Consent Points:",
          //     style:
          //         pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          // pw.SizedBox(height: 6),
          // ..._consentPoints.entries
          //     .where((e) => e.value)
          //     .map((e) => pw.Bullet(text: e.key))
          //     .toList(),
          // pw.SizedBox(height: 20),
          // ✅ Dynamic Consent Points from API
          // ✅ Static Consent Points
          pw.Text("General Consent Points:",
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          ..._consentPoints.entries.map((e) {
            return pw.Bullet(
              text: "${e.key} : ${e.value ? 'Yes' : 'No'}",
              style: pw.TextStyle(fontSize: 12),
            );
          }).toList(),
          pw.SizedBox(height: 12),

// ✅ Dynamic Consent Points from API
          // ✅ Dynamic Consent Points from API
          if (consentFormData != null &&
              consentFormData!.sections.isNotEmpty) ...[
            pw.Text("Additional Consent Points (from API):",
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 6),
            ...consentFormData!.sections.map((section) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(section.heading,
                      style: pw.TextStyle(
                          fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  ...section.questions.map((q) {
                    return pw.Bullet(
                      text: "${q.question} : ${q.answer ? 'Yes' : 'No'}",
                      style: pw.TextStyle(fontSize: 12),
                    );
                  }).toList(),
                  pw.SizedBox(height: 8),
                ],
              );
            }).toList(),
          ],

          pw.Text("I consent to the procedure",
              style:
                  pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(procedure),
          pw.SizedBox(height: 12),
          pw.Text("I consent to the use of my data",
              style:
                  pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(userData!),
          pw.SizedBox(height: 30),
          // 🖊 Signatures Section
          pw.Row(children: [
            pw.Expanded(
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Doctor Signature"),
                    pw.SizedBox(height: 6),
                    if (doctorSignBytes != null)
                      pw.Image(
                        pw.MemoryImage(doctorSignBytes),
                        height: 60,
                      )
                    else
                      pw.Text("No signature available"),
                  ]),
            ),
            pw.SizedBox(height: 30),
            pw.Expanded(
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Patient Signature"),
                    pw.SizedBox(height: 6),
                    if (patientSignPng != null)
                      pw.Image(pw.MemoryImage(patientSignPng), height: 60)
                  ]),
            ),
          ]),

          pw.SizedBox(height: 30),
          pw.Divider(),

          // 📌 Footer
          pw.Center(
            child: pw.Text(
                "This consent form is digitally generated and valid with a physical signature.",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          )
        ],
      ),
    );

    return pdf.save();
  }

  updateSignFunction(String bookingId, String signatureBytes) {}

  void _onSubmit() async {
    if (widget.bookingId == null || widget.bookingId!.isEmpty) return;

    // Get user info
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('userName') ?? '';
    final mobileNumber = prefs.getString('mobileNumber') ?? '';

    // Get signature bytes
    final signatureData = await _patientSignController.toPngBytes();
    if (signatureData == null) {
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Please provide your signature",
        type: SnackbarType.warning,
      );

      return;
    }

    // Build PDF and encode
    final pdfBytes = await _buildPdf();
    final pdfBase64 = base64Encode(pdfBytes);

    // Prepare payload
    final payload = {
      "bookingId": widget.bookingId,
      "consentFormPdf": pdfBase64,
      // "followupStatus": "dfd", // TODO: Remove after deploy
    };

    // Update consent form
    final success = await updateConsentForm(payload);

    if (success != null && success.isNotEmpty) {
      if (!mounted) return;

      setState(() {
        _patientSigned = true;
        _signatureSaved = true;
        _pdfBytes = pdfBytes;
      });

      // Show success message using GetX
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Consent Form Uploaded Sucessfully...!",
        type: SnackbarType.success,
      );
      // Get.snackbar(
      //   "Success",
      //   "Consent Form Uploaded Sucessfully...!",
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.BOTTOM,
      // );

      // Navigate to dashboard
      Get.offAll(() => BottomNavController(
            mobileNumber: mobileNumber,
            username: username,
            index: 0,
          ));
    } else {
      if (!mounted) return;

      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Failed to save signature. Please try again.",
        type: SnackbarType.error,
      );
    }
  }

  // void _onSubmit() async {
  //   print("_signatureSaveddata calling");
  //   print("_signatureSaveddata: $_signatureSaved");
  //   print("Booking ID: ${widget.bookingId}");

  //   final prefs = await SharedPreferences.getInstance();
  //   final username = prefs.getString('userName') ?? '';
  //   final mobileNumber = prefs.getString('mobileNumber') ?? '';

  //   // 1️⃣ Booking exists → Save signature and update consent form
  //   if (widget.bookingId != null && widget.bookingId!.isNotEmpty) {
  //     final signatureData = await _patientSignController.toPngBytes();

  //     if (signatureData == null) {
  //       ScaffoldMessageSnackbar.show(
  //         context: context,
  //         message: "Please provide your signature",
  //         type: SnackbarType.warning,
  //       );
  //       return;
  //     }

  //     final pdfBytes = await _buildPdf();
  //     final pdfBase64 = base64Encode(pdfBytes);

  //     final payload = {
  //       "bookingId": widget.bookingId!,
  //       "consentFormPdf": pdfBase64,
  //       "followupStatus": "dfd" //TODO:Remove This after deploye
  //     };

  //     final success = await updateConsentForm(payload);
  //     print("updateConsentForm ${success}");

  //     if (success != null && success.isNotEmpty) {
  //       if (!mounted) return;

  //       setState(() {
  //         _patientSigned = true;
  //         _signatureSaved = true;
  //         _pdfBytes = pdfBytes;
  //       });

  //       // Show snackbar safely
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("Signature saved successfully"),
  //           backgroundColor: Colors.green,
  //         ),
  //       );

  //       // Then navigate
  //       Get.to(() => BottomNavController(
  //             mobileNumber: widget.doctorBookings!.mobileNumber,
  //             username: widget.doctorBookings!.name,
  //             index: 0,
  //           ));
  //     } else {
  //       ScaffoldMessageSnackbar.show(
  //         context: context,
  //         message: "Failed to save signature. Please try again.",
  //         type: SnackbarType.error,
  //       );
  //       return;
  //     }
  //   }

  //   // 2️⃣ No booking → normal confirm booking flow
  //   final pdfBytes = await _buildPdf();

  //   Get.to(() => Confirmbookingdetails(
  //         doctor: widget.doctor,
  //         patient: widget.patient!,
  //         pdfBytes: pdfBytes,
  //       ));
  // }

  void _showSnack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // Save PDF to app directory and optionally share
  Future<void> _savePdf() async {
    final pdfBytes = await _buildPdf();

    Directory dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/patient_signature.pdf";
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    setState(() {
      _pdfBytes = pdfBytes;
    });

    ScaffoldMessageSnackbar.show(
      context: context,
      message: "PDF saved to: $filePath",
      type: SnackbarType.success,
    );
  }

  // Share PDF file
  Future<void> _sharePdf() async {
    if (_pdfBytes == null) return;

    Directory dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/patient_signature.pdf";
    final file = File(filePath);
    await file.writeAsBytes(_pdfBytes!);

    await Share.shareFiles([file.path], text: "Patient Consent Form PDF");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: "Patient Consent Form"),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name : ",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                            "${capitalizeEachWord(widget.doctorBookings?.name ?? "")}"),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Age : ",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text("${widget.doctorBookings?.age ?? ""}"),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mobile Number : ",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text("${widget.doctorBookings?.mobileNumber ?? ""}"),
                      ],
                    ),
                  ]),
            ),
            _Section(
              title: 'Consent',
              child: Column(
                children:
                    _consentPoints.keys.toList().asMap().entries.map((entry) {
                  final index = entry.key; // 0-based index
                  final point = entry.value; // actual text

                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: GestureDetector(
                      onTap: () {
                        // ✅ make only specific indexes clickable
                        if (index == 0) {
                          if (consentFormData != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConsentFormScreen(
                                  consentFormData: consentFormData!,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessageSnackbar.show(
                              context: context,
                              message: "Consent form not loaded yet",
                              type: SnackbarType.warning,
                            );
                          }
                        } else if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDataConsentScreen(
                                  patientname: widget.doctorBookings!.name),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "$point", // adds numbering
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.2,
                          color: (index == 0 || index == 1)
                              ? Colors.blue
                              : Colors.black,
                          decoration: (index == 0 || index == 1)
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                    value: _consentPoints[point],
                    onChanged: null,
                    // onChanged: (val) {
                    //   setState(() {
                    //     _consentPoints[point] = val ?? false;
                    //   });
                    // },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text:
                      'Your data will be kept confidential and used in accordance with our ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    height: 1.8, // <--- controls line height (default is ~1.5)
                  ),
                  children: [
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        height: 1.2, // <--- match parent line height
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          const url = 'https://www.example.com/privacy-policy';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Questions Button
                  ElevatedButton.icon(
                    onPressed: () => _openQuestions(context),
                    icon: Icon(
                      Icons.question_answer,
                      color: Colors.white,
                    ),
                    label: Text('Questions Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(width: 20), // spacing between buttons

                  // WhatsApp Button
                  ElevatedButton.icon(
                    onPressed: () => whatsUpChat(
                        scontroller.selectedBranch.value?.contactNumber),
                    icon: Icon(
                      Icons.whatshot,
                      color: Colors.white,
                    ),
                    label: Text('Help via WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_patientSigned && widget.bookingId != "")
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.check, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Signature Saved",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                    const Spacer(),

                    // 👁 Preview PDF
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                      tooltip: "Preview PDF",
                      onPressed: (_pdfBytes != null)
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfPreviewScreen(
                                    pdfBytes: _pdfBytes!,
                                    pdfUrl: '',
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),

                    // ⬇️ Download PDF
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: _pdfBytes != null ? _sharePdf : null,
                    ),
                  ],
                ),
              ),
            if (widget.bookingId != null &&
                widget.bookingId.toString().isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      "Patient Signature",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _patientSignController.clear(),
                    child: const Text("Clear"),
                  ),
                  TextButton(
                    onPressed: () async {
                      final data = await _patientSignController.toPngBytes();
                      if (data != null) {
                        final pdf = await _buildPdf(); // generate PDF
                        setState(() {
                          _patientSigned = true;
                          _signatureSaved = true;
                          _pdfBytes = pdf;
                        });

                        // Use Get.snackbar instead of context-based snackbar
                        ScaffoldMessageSnackbar.show(
                          context: context,
                          message: "Signature Saved Successfully",
                          type: SnackbarType.success,
                        );
                        // Get.snackbar(
                        //   "Success",
                        //   "Signature Saved Successfully",
                        //   backgroundColor: Colors.green,
                        //   colorText: Colors.white,
                        //   snackPosition: SnackPosition.BOTTOM,
                        // );
                      } else {
                        ScaffoldMessageSnackbar.show(
                          context: context,
                          message: "Please provide your signature",
                          type: SnackbarType.error,
                        );

                        // Get.snackbar(
                        //   "Error",
                        //   "Please provide your signature",
                        //   backgroundColor: Colors.red,
                        //   colorText: Colors.white,
                        //   snackPosition: SnackPosition.BOTTOM,
                        // );
                      }
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),

            if (widget.bookingId != null &&
                widget.bookingId.toString().isNotEmpty)
              // Signature box
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AspectRatio(
                    aspectRatio: 3.5,
                    child: Signature(
                      controller: _patientSignController,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),

            // Buttons Row

            // ✅ Saved Indicator
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 50,
        color: mainColor,
        child: FilledButton.icon(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            foregroundColor: MaterialStateProperty.all(Colors.black),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          onPressed: _onSubmit, // ✅ just call the function
          label: Text(
            "SUBMIT",
            style: TextStyle(
              color: (widget.bookingId != null &&
                      widget.bookingId.toString().isNotEmpty &&
                      _patientSigned)
                  ? Colors.white
                  : Colors.grey,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ),
        child
      ]),
    );
  }
}

class PdfPreviewScreen extends StatelessWidget {
  final Uint8List? pdfBytes;
  const PdfPreviewScreen(
      {super.key, required this.pdfBytes, required String pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(title: "Consent PDF Preview"),
      body: PdfPreview(
        build: (format) async => pdfBytes!,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}
