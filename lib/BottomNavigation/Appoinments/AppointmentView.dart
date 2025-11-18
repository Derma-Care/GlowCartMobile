import 'dart:convert';
import 'dart:io';
// import 'package:cutomer_app/Doctors/Schedules/ConsentFormWithSign.dart';
import 'package:cutomer_app/Reports/DownloadReports.dart';
import 'package:cutomer_app/Reports/FilePreviewScreen.dart';
import 'package:cutomer_app/Utils/SavePdfToDownloads.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:cutomer_app/Widget/TreatmentSittingsCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import '../../Doctors/Schedules/ConsentForm.dart';
import '../../Doctors/DoctorDetails/DoctorDetailsScreen.dart';
import '../../Reports/ReportsDownload.dart';
import '../../Utils/Constant.dart';

import '../../Utils/Header.dart';

import 'GetAppointmentModel.dart';

class AppointmentPreview extends StatefulWidget {
  final HospitalDoctorModel doctor;
  final Getappointmentmodel doctorBookings;

  const AppointmentPreview({
    Key? key,
    required this.doctor,
    required this.doctorBookings,
  }) : super(key: key);

  @override
  State<AppointmentPreview> createState() => _AppointmentPreviewState();
}

class _AppointmentPreviewState extends State<AppointmentPreview>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final patient = widget.doctorBookings;
    final doctor = widget.doctor;

    String base64String = doctor.doctor.doctorPicture;
    final regex = RegExp(r'data:image/[^;]+;base64,');
    base64String = base64String.replaceAll(regex, '');
    final prefix = 'data:image/jpeg;base64,';
    if (base64String.startsWith(prefix)) {
      base64String = base64String.substring(prefix.length);
    }

    Future<bool> requestStoragePermission() async {
      if (Platform.isAndroid) {
        // ✅ Android 11+ (Scoped Storage)
        if (await Permission.manageExternalStorage.isGranted) return true;

        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      } else {
        // ✅ iOS or other platforms - no special permission needed
        return true;
      }
    }

    final today = DateTime.now();
    final serviceDate =
        DateTime.parse(patient.serviceDate); // example: "2025-10-12"

// Compare only the date part (ignore time)
    bool isToday = serviceDate.year == today.year &&
        serviceDate.month == today.month &&
        serviceDate.day == today.day;

    if (patient.consultationType.toLowerCase() == "services & treatments" &&
        patient.consentFormPdf == null &&
        isToday &&
        patient.status.toLowerCase() == "confirmed") {
      print("✅ Condition matched — service is today!");
    }

    bool isSameDate(String dateString) {
      final today = DateTime.now();
      final parsed = DateTime.parse(dateString);
      return parsed.year == today.year &&
          parsed.month == today.month &&
          parsed.day == today.day;
    }

    final isCompletedStatus = patient.status.toLowerCase() == 'completed';
    final showReports = patient.status.toLowerCase() == 'completed' ||
        patient.status.toLowerCase() == 'in-progress';

    return Scaffold(
      appBar: CommonHeader(title: "Appointment Details"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (patient.status.toLowerCase() == "rejected")
              Card(
                color: Colors.red,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "Reason For Reject",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${patient.reasonForCancel}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Hospital Accordion
            ExpansionTile(
              title: Text("Clinic Details"),
              leading: Icon(Icons.local_hospital_outlined, color: mainColor),
              children: [
                _infoRow("Hospital", patient.clinicName),
                _infoRow("Branch", patient?.branchname ?? ""),
                // _infoRow("Location", doctor.hospital.address),
                // _infoRow("Contact", doctor.hospital.contactNumber),
              ],
            ),
            const SizedBox(height: 8),
            // Doctor Accordion
            ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    // ✅ Wrap with Expanded so it respects width
                    child: Text(
                      patient.doctorName,
                      maxLines: 2, // ✅ Allow up to 2 lines
                      overflow:
                          TextOverflow.ellipsis, // ✅ Show ... if text overflows
                      style: const TextStyle(fontSize: 16), // optional styling
                    ),
                  ),
                ],
              ),
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: doctor.doctor.doctorPicture.isNotEmpty
                    ? MemoryImage(base64Decode(base64String))
                    : const AssetImage('assets/placeholder.png')
                        as ImageProvider,
              ),
              children: [
                _infoRow("Specialization", doctor.doctor.specialization),
                _infoRow("Experience", "${doctor.doctor.experience} years"),
                TextButton(
                  onPressed: () {
                    Get.to(DoctorDetailScreen(doctorData: doctor));
                  },
                  child: const Text("About Doctor"),
                ),
              ],
            ),

            const SizedBox(height: 8),
            // Patient Info Accordion
            ExpansionTile(
              title: Text("Patient Details"),
              leading: Icon(Icons.account_circle_outlined, color: mainColor),
              children: [
                _infoRow("Name", patient.name),
                _infoRow("Age", patient.age.toString()),
                _infoRow("Gender", patient.gender),
                _infoRow("Booking For", patient.bookingFor),
                _infoRow("Date", patient.serviceDate),
                _infoRow("Time", patient.servicetime),
                _infoRow("Problem", patient.problem),
              ],
            ),
            const SizedBox(height: 8),
            // Service / Payment Info Accordion
            ExpansionTile(
              title: Text("Service & Payment Details"),
              leading: Icon(Icons.payment_outlined, color: mainColor),
              children: [
                _infoRow("Service", patient.subServiceName),
                _infoRow("Consultation Type", patient.consultationType),
                _infoRow("Consultation Fee", "₹${patient.consultationFee}"),
                _infoRow("Total Fee", "₹${patient.totalFee}"),
              ],
            ),
            const SizedBox(height: 8),

            Column(
              children: [
                if (patient.consultationType.toLowerCase() ==
                        "services & treatments" &&
                    patient.status.toLowerCase() != "confirmed")
                  ExpansionTile(
                    title: Text("Treatments Sittings Details"),
                    leading: Icon(Icons.healing, color: mainColor),
                    children: [
                      SittingDetailsCard(
                        // totalSittings: patient.totalSittings ?? 0,
                        // takenSittings: patient.takenSittings ?? 0,
                        // currentSitting: patient.currentSitting ?? 0,
                        // pending: patient.pendingSittings ?? 0,
                        treatments: patient.treatments,
                      ),
                    ],
                  ),
                // example usage inside a Column or ListView
              ],
            ),

            const SizedBox(height: 8),
            // Reports Accordion

            if (showReports)
              ExpansionTile(
                title: const Text(
                  "Reports & Prescriptions",
                ),
                leading: const Icon(
                  Icons.picture_as_pdf_outlined,
                  color: mainColor,
                ),
                children: [
                  // ✅ Tab Controller for Prescription & Reports
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Container(
                          // color: Colors.blue.shade50,
                          child: const TabBar(
                            labelColor: mainColor,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: mainColor,
                            tabs: [
                              Tab(text: "Prescriptions"),
                              Tab(text: "Reports"),
                            ],
                          ),
                        ),
                        SizedBox(
                          height:
                              300, // Adjust height as needed or use Expanded in parent
                          child: TabBarView(
                            children: [
                              // ✅ Prescriptions Tab
                              if (patient.prescriptionPdf != null &&
                                  patient.prescriptionPdf!.isNotEmpty)
                                ListView.builder(
                                  itemCount: patient.prescriptionPdf!.length,
                                  itemBuilder: (context, index) {
                                    final base64File =
                                        patient.prescriptionPdf![index];
                                    final fileName =
                                        "Prescription_Visit_${index + 1}.pdf";

                                    return ListTile(
                                      title: Text(
                                          "Prescription_Visit_${index + 1}"),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.visibility,
                                                color: mainColor),
                                            onPressed: () async {
                                              try {
                                                final bytes =
                                                    base64Decode(base64File);
                                                final tempDir =
                                                    await getTemporaryDirectory();
                                                final filePath =
                                                    "${tempDir.path}/$fileName";
                                                final file = File(filePath);
                                                await file.writeAsBytes(bytes);
                                                await OpenFilex.open(file.path);
                                              } catch (e) {
                                                ScaffoldMessageSnackbar.show(
                                                  context: context,
                                                  message:
                                                      "Failed to open $fileName: $e",
                                                  type: SnackbarType.error,
                                                );
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.download,
                                                color: mainColor),
                                            onPressed: () async {
                                              try {
                                                final bytes =
                                                    base64Decode(base64File);
                                                final downloadDir = Directory(
                                                    "/storage/emulated/0/Download");
                                                if (!await downloadDir
                                                    .exists()) {
                                                  await downloadDir.create(
                                                      recursive: true);
                                                }
                                                final filePath =
                                                    "${downloadDir.path}/$fileName";
                                                final file = File(filePath);
                                                await file.writeAsBytes(bytes);
                                                ScaffoldMessageSnackbar.show(
                                                  context: context,
                                                  message:
                                                      "$fileName saved to Downloads",
                                                  type: SnackbarType.success,
                                                );
                                                await OpenFilex.open(file.path);
                                              } catch (e) {
                                                ScaffoldMessageSnackbar.show(
                                                  context: context,
                                                  message:
                                                      "Failed to download $fileName: $e",
                                                  type: SnackbarType.error,
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              else
                                const Center(
                                  child: Text("No prescriptions available"),
                                ),

                              // ✅ Reports Tab
                              if (patient.reports != null &&
                                  patient.reports!.isNotEmpty)
                                ListView(
                                  children: patient.reports!
                                      .expand((reportGroup) =>
                                          reportGroup.reportsList)
                                      .map((reportItem) {
                                    return Column(
                                      children: reportItem.reportFile
                                          .map((fileBase64) {
                                        final fileName =
                                            "${reportItem.reportName.replaceAll(" ", "_")}.pdf";

                                        return ListTile(
                                          title: Text(reportItem.reportName),
                                          subtitle: Text(reportItem.reportDate),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.visibility,
                                                    color: mainColor),
                                                onPressed: () async {
                                                  try {
                                                    final bytes = base64Decode(
                                                        fileBase64);
                                                    final tempDir =
                                                        await getTemporaryDirectory();
                                                    final filePath =
                                                        "${tempDir.path}/$fileName";
                                                    final file = File(filePath);
                                                    await file
                                                        .writeAsBytes(bytes);
                                                    await OpenFilex.open(
                                                        file.path);
                                                  } catch (e) {
                                                    ScaffoldMessageSnackbar
                                                        .show(
                                                      context: context,
                                                      message:
                                                          "Failed to open report: $e",
                                                      type: SnackbarType.error,
                                                    );
                                                  }
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.download,
                                                    color: mainColor),
                                                onPressed: () async {
                                                  try {
                                                    final bytes = base64Decode(
                                                        fileBase64);
                                                    final downloadDir = Directory(
                                                        "/storage/emulated/0/Download");
                                                    if (!await downloadDir
                                                        .exists()) {
                                                      await downloadDir.create(
                                                          recursive: true);
                                                    }
                                                    final filePath =
                                                        "${downloadDir.path}/$fileName";
                                                    final file = File(filePath);
                                                    await file
                                                        .writeAsBytes(bytes);
                                                    ScaffoldMessageSnackbar
                                                        .show(
                                                      context: context,
                                                      message:
                                                          "$fileName saved to Downloads",
                                                      type:
                                                          SnackbarType.success,
                                                    );
                                                    await OpenFilex.open(
                                                        file.path);
                                                  } catch (e) {
                                                    ScaffoldMessageSnackbar
                                                        .show(
                                                      context: context,
                                                      message:
                                                          "Failed to download report: $e",
                                                      type: SnackbarType.error,
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  }).toList(),
                                )
                              else
                                const Center(
                                  child: Text("No reports available"),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            Column(
              children: [
                // Other widgets...

                if (patient.consultationType.toLowerCase() ==
                        "services & treatments" &&
                    patient.consentFormPdf == null &&
                    isSameDate(patient.serviceDate) &&
                    patient.status.toLowerCase() == "confirmed")
                  ListTile(
                    title: const Text("Consent Form"),
                    trailing: Icon(Icons.picture_as_pdf, color: mainColor),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SkinCareConsentFormScreen(
                            doctor: doctor,
                            // patient: null,
                            bookingId: patient.bookingId,
                            pID: patient.subServiceId,
                            doctorBookings: widget.doctorBookings,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              )),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
