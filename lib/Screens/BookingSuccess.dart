import 'package:cutomer_app/Consultations/SymptomsController.dart';
import 'package:cutomer_app/Dashboard/DashBoardController.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:cutomer_app/PatientsDetails/PatientModel.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/GradintColor.dart';
import 'package:cutomer_app/Utils/MapOnGoogle.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../BottomNavigation/BottomNavigation.dart';
import '../ConfirmBooking/ConsultationController.dart';
import '../Controller/CustomerController.dart';
import '../Doctors/DoctorDetails/DoctorDetailsController.dart';
import '../Doctors/ListOfDoctors/DoctorController.dart';
import '../Doctors/ListOfDoctors/DoctorService.dart';
import '../Help/Numbers.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SuccessScreen extends StatefulWidget {
  final HospitalDoctorModel serviceDetails;
  final PatientModel patient;
  final String paymentId;
  final String mobileNumber;
  final String paymentType;
  final HospitalDoctorModel clinicData;
  final String branchName;

  const SuccessScreen({
    super.key,
    required this.serviceDetails,
    required this.paymentId,
    required this.patient,
    required this.mobileNumber,
    required this.paymentType,
    required this.clinicData,
    required this.branchName,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  DoctorService service = DoctorService();
  final doctorController = Get.put(DoctorController());
  final doctordetailscontroller = Doctordetailscontroller();
  final scontroller = Get.find<SymptomsController>();

  final Dashboardcontroller controller = Dashboardcontroller();
  final consultationController = Get.put(Consultationcontroller());
  final selectedServicesController = Get.find<SelectedServicesController>();
  final branchController = Get.find<SymptomsController>();
  @override
  void initState() {
    super.initState();
    print("servicesAddedList: ${widget.serviceDetails}");
  }

  Future<void> addToGoogleCalendarWeb({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    String location = "",
  }) async {
    final String start =
        DateFormat("yyyyMMdd'T'HHmmss'Z'").format(startTime.toUtc());
    final String end =
        DateFormat("yyyyMMdd'T'HHmmss'Z'").format(endTime.toUtc());

    final Uri url = Uri.parse(
      "https://calendar.google.com/calendar/render"
      "?action=TEMPLATE"
      "&text=${Uri.encodeComponent(title)}"
      "&details=${Uri.encodeComponent(description)}"
      "&location=${Uri.encodeComponent(location)}"
      "&dates=$start/$end",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch Google Calendar";
    }
  }

  Future<void> addToDeviceCalendar({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    String location = "",
  }) async {
    final deviceCalendarPlugin = DeviceCalendarPlugin();

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Set your timezone

    // Ask permission
    final permissionsGranted = await deviceCalendarPlugin.requestPermissions();
    if (!(permissionsGranted.isSuccess && permissionsGranted.data == true)) {
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Permission denied\n Calendar access was not granted",
        type: SnackbarType.warning,
      );
      // Get.snackbar("Permission denied", "Calendar access was not granted");
      return;
    }

    // Get calendars
    final calendarsResult = await deviceCalendarPlugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data!.isEmpty) {
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "No calendars available",
        type: SnackbarType.error,
      );

      return;
    }

    final calendarId = calendarsResult.data!.first.id;

    // Convert DateTime → TZDateTime
    final tzStart = tz.TZDateTime.from(startTime, tz.local);
    final tzEnd = tz.TZDateTime.from(endTime, tz.local);

    final event = Event(
      calendarId,
      title: title,
      description: description,
      start: tzStart,
      end: tzEnd,
      location: location,
    );

    final createResult = await deviceCalendarPlugin.createOrUpdateEvent(event);

    if (createResult!.isSuccess) {
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Event added to your calendar ",
        type: SnackbarType.success,
      );
      // Get.snackbar("Success", "Event added to your calendar");
    } else {
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Failed to add event",
        type: SnackbarType.error,
      );
      // Get.snackbar("Error", "Failed to add event");
    }
  }

  void _navigateToBookingDetails() {
    controller.clearAfterAppointment();
    selectedServicesController.clearAll();
    consultationController.selectedConsultation.value = null;
    consultationController.clear();
    scontroller.clearForm();
    scontroller.clearAttachments();

    Get.offAll(
      BottomNavController(
        mobileNumber: widget.mobileNumber,
        username: widget.patient.name,
        index: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(gradient: appGradient()),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const Icon(Icons.check_circle,
                      size: 100, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Congratulation',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.paymentType == 'cash'
                        ? 'Appointment booked successfully'
                        : 'Payment is Successful',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Thank you for trusting us! Our team is ready to serve you with excellence.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 40),

                  /// Appointment Card
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(
                            "You have successfully booked an appointment with",
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "${widget.clinicData.hospital.name} ",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 25),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),

                          Text(
                            "${widget.serviceDetails.doctor.doctorName}, ${widget.serviceDetails.doctor.qualification}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 25),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),

                          Text(
                            "${branchController.selectedBranch.value!.branchName}, ",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color:
                                      const Color.fromARGB(255, 236, 230, 230),
                                ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),

                          /// Date & Time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month,
                                      color: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(widget.patient.monthYear,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.timer, color: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(widget.patient.servicetime,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Doctor timing & hospital contact
                  Obx(() {
                    var branch = branchController.selectedBranch.value;
                    if (branch == null) {
                      print("⚠️ No branch selected yet"); // debug
                      return const SizedBox();
                    }

                    print(
                        "✅ Displaying branch in ServiceDetailsPage: ${branch.branchName}");

                    return doctordetailscontroller.buildTimingAndContactSection(
                      timing: widget.serviceDetails.doctor.availableTimes,
                      onCall: () {
                        print("📞 Calling: ${branch.contactNumber}");
                        customerCare(branch.contactNumber);
                      },
                      onDirection: () {
                        final double latitude =
                            double.parse(branch.latitude ?? "0.0");
                        final double longitude =
                            double.parse(branch.longitude ?? "0.0");
                        // replace with your branch longitude

                        print(
                            "📍 Opening map for coordinates: $latitude, $longitude");

                        // Open map using latitude and longitude
                        MapUtils.openMapByCoordinates(latitude, longitude);
                      },
                      hospitalNumber: branch.contactNumber,
                      days: widget.serviceDetails.doctor.availableDays,
                    );
                  })
                ],
              ),
            ),
          ),
        ),
      ),

      /// Bottom Button
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: appGradient(),
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: Colors.transparent, // use gradient from parent
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.calendar_today, color: Colors.white),
          label: const Text(
            "Add to Google Calendar",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                  backgroundColor: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [mainColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Add to Google Calendar?",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Do you want to add this appointment to your Google Calendar?",
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _navigateToBookingDetails();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.white,
                                      width: 1), // white border
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  "No",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  Navigator.pop(context);

                                  final dateStr = widget.patient.serviceDate;
                                  final timeStr = widget.patient.servicetime;
                                  final dateTimeStr = "$dateStr $timeStr";
                                  final format =
                                      DateFormat("yyyy-MM-dd hh:mm a");
                                  final start = format.parse(dateTimeStr);
                                  final end =
                                      start.add(const Duration(minutes: 30));

                                  print("📅 Start: $start");
                                  print("📅 End: $end");

                                  await addToGoogleCalendarWeb(
                                    title:
                                        "Appointment with ${widget.serviceDetails.doctor.doctorName}",
                                    description:
                                        "Consultation at ${widget.serviceDetails.hospital.name}",
                                    startTime: start,
                                    endTime: end,
                                    location:
                                        widget.serviceDetails.hospital.address,
                                  );

                                  _navigateToBookingDetails();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.white,
                                      width: 1), // white border
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  "Yes",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
