import 'dart:convert';

import 'package:cutomer_app/Booings/BooingService.dart';
import 'package:cutomer_app/Booings/FollowUpModal.dart';
import 'package:cutomer_app/BottomNavigation/Appoinments/AppointmentService.dart';
import 'package:cutomer_app/BottomNavigation/Appoinments/AppointmentView.dart';
import 'package:cutomer_app/BottomNavigation/Appoinments/GetAppointmentModel.dart';
import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';
import 'package:cutomer_app/Consultations/SymptomsController.dart';
import 'package:cutomer_app/Dashboard/VisitController.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:cutomer_app/Doctors/Schedules/DoctorSlotService.dart';
import 'package:cutomer_app/Doctors/Schedules/Schedule.dart';
import 'package:cutomer_app/Doctors/Schedules/ScheduleController.dart';
import 'package:cutomer_app/Screens/BookingSuccess.dart';
import 'package:cutomer_app/Services/GetHospiatlsAndDoctorWithSubService.dart';
import 'package:cutomer_app/Utils/AppointmentCard.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:cutomer_app/Widget/Bottomsheet.dart';
import 'package:cutomer_app/Widget/date_selector_widget.dart';
import 'package:cutomer_app/Widget/time_slot_grid_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ConfirmBooking/ConsultationPrice.dart';

class VisitType extends StatefulWidget {
  final String mobileNumber;
  final String username;
  final String consulationType;
  final ValueChanged<String> onVisitTypeChanged; // callback
  const VisitType({
    super.key,
    required this.mobileNumber,
    required this.username,
    required this.consulationType,
    required this.onVisitTypeChanged,
  });

  @override
  State<VisitType> createState() => _VisitTypeState();
}

HospitalDoctorModel? selectedHospitalDoctor;

class _VisitTypeState extends State<VisitType> {
  final SymptomsController controller = Get.put(SymptomsController());
  final appointmentService = Get.put(AppointmentService());
  final visitController = Get.put(VisitController());
  List<HospitalDoctorModel> hospitalDoctors = [];
  String selectedType = "First Time"; // default
  final scheduleController = Get.find<ScheduleController>();
  bool showAllRows = false;
  final ScrollController _dateScrollController = ScrollController();
  Getappointmentmodel? selectedBooking;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    // _fetchAppointments();
    selectedType = "First Time";
    controller.updateVisitType("First Time");
    scheduleController.initializeWeekDates();
    _initializeData();
    // fetchHospitalDoctor().then((value) async {
    //   setState(() => hospitalDoctors = value);

    //   if (hospitalDoctors.isNotEmpty) {
    //     final today = scheduleController.weekDates.first; // first date (today)
    //     final doctorId = hospitalDoctors.first.doctor.doctorId;
    //     final clinicId = hospitalDoctors.first.hospital.hospitalId;
    //     // final prefs = await SharedPreferences.getInstance();
    //     var branchId = visitController.bookings.first.branchId;
    //     final slots = await DoctorSlotService.fetchDoctorSlots(
    //         doctorId, clinicId, branchId!);
    //     scheduleController.selectDate(today, slots);
    //     print("jhgjjhjhgslots L::${slots}");
    //   }
    // });
  }

  Future<void> _initializeData() async {
    try {
      await _fetchAppointments(); // Wait for appointments first

      final hospitalList = await fetchHospitalDoctor();
      setState(() => hospitalDoctors = hospitalList);

      if (hospitalDoctors.isNotEmpty && visitController.bookings.isNotEmpty) {
        final today = scheduleController.weekDates.first;
        final doctorId = hospitalDoctors.first.doctor.doctorId;
        final clinicId = hospitalDoctors.first.hospital.hospitalId;
        final branchId = visitController.bookings.first.branchId ?? "";

        final slots = await DoctorSlotService.fetchDoctorSlots(
          doctorId,
          clinicId,
          branchId,
        );

        scheduleController.selectDate(today, slots);
        print("✅ Loaded slots for today: $slots");
      } else {
        print("⚠️ No doctors or bookings available to load slots.");
      }
    } catch (e) {
      print("❌ Error initializing data: $e");
    }
  }

  Future<void> _fetchAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('customerId') ?? "";
    print("jhgjjhjhg L::${id}");
    setState(() => visitController.loading.value = true);
    try {
      final appointments =
          await appointmentService.fetchInprogressAppointments(id);
      visitController.setBookings(appointments);
      print("jhgjjhjhg L::${appointments.length}");
    } catch (e) {
      print("❌ Error fetching appointments: $e");
    } finally {
      setState(() => visitController.loading.value = false);
    }
  }

  void _handleFirstTime() {
    controller.updateVisitType(selectedType);
    // Get.offAll(() => BottomNavController(
    //       mobileNumber: widget.mobileNumber,
    //       username: widget.username,
    //       index: 0,
    //     ));
  }

  void _handleFollowUp() async {
    print("_handleFollowUp calling");
    await _fetchAppointments();
    final screenHeight = MediaQuery.of(context).size.height;
    final appointments = visitController.bookings;
    if (appointments == null || appointments.isEmpty) {
      print("No appointments found");

      ScaffoldMessageSnackbar.show(
        context: context,
        message: "You don’t have any past bookings",
        type: SnackbarType.warning,
      );

      if (visitController.loading.value) {
        ScaffoldMessageSnackbar.show(
          context: context,
          message: "Please wait, loading appointments...",
          type: SnackbarType.warning,
        );
        return;
      }

      // Get.snackbar(
      //   "No Appointments",
      //   "You don’t have any past bookings",
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: const Color.fromARGB(255, 66, 119, 235),
      //   colorText: const Color.fromARGB(255, 255, 255, 255),
      //   duration: const Duration(seconds: 3),
      //   margin: const EdgeInsets.all(12),
      //   borderRadius: 10,
      // );

      controller.updateVisitType(selectedType);
      return;
    }

    Get.bottomSheet(
      Container(
        height: screenHeight * 0.75,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Drag Handle ---
            Container(
              height: 5,
              width: 50,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const Text(
              "Select Your Follow-Up Appointment",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // --- List of appointments ---
            Flexible(
              child: Obx(() {
                if (visitController.loading.value) {
                  // ✅ Loading state
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: SpinKitFadingCircle(
                            color: mainColor,
                            size: 40.0,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Loading Appointments...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (visitController.bookings.isEmpty) {
                  // ✅ Empty state
                  return const Center(
                    child: Text('No follow-up appointments available'),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: appointments.length,
                    itemBuilder: (_, index) {
                      final Getappointmentmodel appt = appointments[index];
                      final patientName = appt.name.isNotEmpty
                          ? capitalizeEachWord(appt.name)
                          : "Unknown Patient";

                      selectedHospitalDoctor = hospitalDoctors.firstWhereOrNull(
                        (doc) => doc.doctor.doctorId == appt.doctorId,
                      );

                      // ✅ Doctor not found (unavailable)
                      // if (selectedHospitalDoctor == null) {
                      //   return Card(
                      //     color: Colors.grey.shade100,
                      //     elevation: 1,
                      //     margin: const EdgeInsets.symmetric(
                      //         vertical: 6, horizontal: 8),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(12),
                      //       side: const BorderSide(
                      //           color: Colors.grey, width: 0.8),
                      //     ),
                      //     child: ListTile(
                      //       leading: const Icon(Icons.block,
                      //           color: Colors.redAccent),
                      //       title: Text(
                      //         patientName,
                      //         style:
                      //             const TextStyle(fontWeight: FontWeight.bold),
                      //       ),
                      //       subtitle: const Text(
                      //         "Doctor not available currently",
                      //         style: TextStyle(color: Colors.redAccent),
                      //       ),
                      //       trailing: TextButton(
                      //         onPressed: () {
                      //           ScaffoldMessageSnackbar.show(
                      //             context: context,
                      //             message:
                      //                 "Doctor details are unavailable for this booking",
                      //             type: SnackbarType.warning,
                      //           );
                      //         },
                      //         child: const Text(
                      //           "View Details",
                      //           style: TextStyle(color: Colors.redAccent),
                      //         ),
                      //       ),
                      //     ),
                      //   );
                      // }

                      // ✅ Normal doctor available card
                      return Card(
                        color: selectedHospitalDoctor!
                                .doctor.doctorAvailabilityStatus
                            ? Colors.white
                            : Colors.grey.shade100,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: selectedHospitalDoctor!
                                      .doctor.doctorAvailabilityStatus
                                  ? mainColor
                                  : Colors.grey.shade100,
                              width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      patientName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: secondaryColor),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.favorite,
                                            size: 14, color: secondaryColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${appt.freeFollowUpsLeft ?? 0} Left",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: secondaryColor,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.local_hospital,
                                      size: 18, color: mainColor),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                        " ${selectedHospitalDoctor?.hospital.name ?? "NA"}"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      size: 18, color: mainColor),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                        " ${selectedHospitalDoctor?.doctor.doctorName ?? "-"}"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month,
                                      size: 18, color: mainColor),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Last Consultation: ${appt.serviceDate ?? "-"} ${appt.servicetime ?? "-"}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 235, 201, 194),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.medical_services,
                                            size: 12, color: mainColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          appt.consultationType ?? '',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: mainColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.remove_red_eye,
                                        size: 18, color: mainColor),
                                    onPressed: () {
                                      // Get.back();
                                      Get.to(() => AppointmentPreview(
                                            doctor: selectedHospitalDoctor!,
                                            doctorBookings: appt,
                                          ));
                                    },
                                    label: const Text("View Details",
                                        style: TextStyle(color: mainColor)),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 28,
                                    color: Colors.grey.shade300,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.check_circle_outline,
                                        size: 18, color: mainColor),
                                    onPressed: () {
                                      selectedBooking = appt;

                                      if (!selectedHospitalDoctor!
                                          .doctor.doctorAvailabilityStatus) {
                                        ScaffoldMessageSnackbar.show(
                                          context: context,
                                          message: "Doctor not Available Now",
                                          type: SnackbarType.warning,
                                        );
                                        return;
                                      }
                                      Get.back();
                                      Get.bottomSheet(
                                        bottomSlotWidget(
                                          selectedHospitalDoctor!
                                              .hospital.hospitalId,
                                          selectedHospitalDoctor!
                                              .doctor.doctorId,
                                          appt.patientId,
                                          appt.clinicName,
                                          appt.doctorName,
                                          appt.branchId,
                                        ),
                                        isScrollControlled: true,
                                        backgroundColor: Colors.white,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20)),
                                        ),
                                      );

                                      controller.updateVisitType(selectedType);
                                    },
                                    label: const Text("Select",
                                        style: TextStyle(color: mainColor)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget bottomSlotWidget(String hospitalId, String doctorId, String patientId,
      String clinicName, String doctorName, branchId) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Doctor & Clinic Info Card
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.local_hospital,
                                  color: Colors.redAccent, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  clinicName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.blueAccent, size: 22),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  doctorName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 Heading for Date Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Choose Date",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(">"),
                    ],
                  ),

                  const SizedBox(height: 12),
                  // showDays(hospitalId, doctorId, branchId),
                  // const Divider(height: 32),
                  // timeslots(doctorId),

                  DateSelectorWidget(
                    scrollController: _dateScrollController,
                    scheduleController: scheduleController,
                    doctorId: doctorId,
                    branchId: branchId,
                  ),

                  const SizedBox(height: 24),

                  TimeSlotGridWidget(scheduleController: scheduleController),
                ],
              ),
            ),
          ),

          // Sticky Submit Button
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (scheduleController.selectedSlotIndex.value == -1) {
                    Get.snackbar(
                      "Warning",
                      "No Slot Selected. Please choose a slot before booking",
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  try {
                    final selectedSlot = scheduleController.currentSlots[
                        scheduleController.selectedSlotIndex.value];
                    // String formattedDate = DateFormat('yyyy-MM-dd')
                    //     .format(scheduleController.selectedDate.value);
                    final selectedDate = scheduleController.selectedDate.value;
                    final postBookingPayload = FollowUpModal(
                      bookingId: selectedBooking?.bookingId ?? "",
                      doctorId: selectedBooking?.doctorId ?? "",
                      visitType: "follow-up",
                      mobileNumber: widget.mobileNumber,
                      serviceDate:
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                      servicetime: scheduleController.selectedSlotText.value,
                      patientId: patientId,
                      bookingFor: selectedBooking?.bookingFor ?? "",
                      branchId: selectedBooking?.branchId ?? "",
                    );
                    print("📅 Booking Payload:");
                    print("Booking ID: ${postBookingPayload.bookingId}");
                    print("Doctor ID: ${postBookingPayload.doctorId}");
                    print("Visit Type: ${postBookingPayload.visitType}");
                    print("Mobile: ${postBookingPayload.mobileNumber}");
                    print("Service Date: ${postBookingPayload.serviceDate}");
                    print("Service Time: ${postBookingPayload.servicetime}");
                    print("Patient ID: ${postBookingPayload.patientId}");
                    print("Booking For: ${postBookingPayload.bookingFor}");
                    print("Branch ID: ${postBookingPayload.branchId}");
                    var resData = await followUpBookings(postBookingPayload);
                    print("resData: $resData");

                    if (resData != null) {
                      final statusCode = resData['statusCode'] ?? 0;
                      final message =
                          resData['message'] ?? "Booking failed. Try again";

                      if (statusCode == 200 || statusCode == 201) {
                        // Show success snackbar
                        // showSnackbar(
                        //   "Success",
                        //   "",
                        //   "success",
                        // );
                        ScaffoldMessageSnackbar.show(
                          context: context,
                          message:
                              "Appointment Booked on ${DateFormat('dd MMM').format(scheduleController.selectedDate.value)}",
                          type: SnackbarType.success,
                        );
                        // Clear selection
                        scheduleController.selectedSlotIndex.value = -1;
                        scheduleController.currentSlots.clear();

                        Get.offAll(() => BottomNavController(
                              mobileNumber: widget.mobileNumber,
                              username: widget.username,
                              index: 1,
                            ));
                      } else {
                        ScaffoldMessageSnackbar.show(
                          context: context,
                          message: message,
                          type: SnackbarType.error,
                        );
                        // showSnackbar("Error", message, "error");
                      }
                    } else {
                      ScaffoldMessageSnackbar.show(
                        context: context,
                        message: "Unexpected error occurred",
                        type: SnackbarType.error,
                      );
                      // showSnackbar(
                      //     "Error", "Unexpected error occurred", "error");
                    }
                  } catch (e) {
                    print('[❌] Exception booking appointment: $e');
                    ScaffoldMessageSnackbar.show(
                      context: context,
                      message: "Unexpected error occurred",
                      type: SnackbarType.error,
                    );
                    // showSnackbar("Error", "Unexpected error occurred", "error");
                  }
                },
                child: const Text(
                  "Book Appointment",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text(
          //   "Choose Visit Type",
          //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          // ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text("First Time")),
                  selected: selectedType == "First Time",
                  selectedColor: mainColor.withOpacity(0.2),
                  onSelected: (_) {
                    setState(() => selectedType = "First Time");
                    widget.onVisitTypeChanged(selectedType); // notify parent
                    _handleFirstTime();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text("Follow-Up")),
                  selected: selectedType == "Follow-Up",
                  selectedColor: mainColor.withOpacity(0.2),
                  onSelected: (_) {
                    setState(() => selectedType = "Follow-Up");
                    widget.onVisitTypeChanged(selectedType); // notify parent
                    _handleFollowUp();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget timeslots(String doctorId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Available Time",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.help, size: 20),
              onPressed: () {
                showReportBottomSheet(
                  context: context,
                  title: "Slots",
                  options: [
                    ReportOption(
                        icon: Icons.block,
                        title: "Booked Slot",
                        color: Colors.grey),
                    ReportOption(
                        icon: Icons.check_circle,
                        title: "Currently selected",
                        color: mainColor),
                    ReportOption(
                        icon: Icons.access_time,
                        title: "Available Slots",
                        color: Colors.white),
                  ],
                  onSelected: (selected) {
                    print("User selected: $selected");
                  },
                );
              },
            )
          ],
        ),
        const SizedBox(height: 10),

        // Slots
        Obx(() {
          if (scheduleController.currentSlots.isEmpty) {
            return const Text("No available slots",
                style: TextStyle(color: Colors.red));
          }

          return Column(
            children: [
              // Build rows of 4
              ...List.generate(
                showAllRows
                    ? (scheduleController.currentSlots.length / 4).ceil()
                    : ((scheduleController.currentSlots.length / 4).ceil() > 2
                        ? 2
                        : (scheduleController.currentSlots.length / 4).ceil()),
                (rowIndex) {
                  final startIndex = rowIndex * 4;
                  final endIndex =
                      (startIndex + 4 < scheduleController.currentSlots.length)
                          ? startIndex + 4
                          : scheduleController.currentSlots.length;

                  final rowSlots = scheduleController.currentSlots
                      .sublist(startIndex, endIndex);

                  return Row(
                    children: List.generate(4, (i) {
                      if (i < rowSlots.length) {
                        final slotData = rowSlots[i];
                        final slotText = slotData.slot;
                        final isBooked = slotData.slotbooked;

                        // 👇 Always map to the actual index in the main list
                        final actualIndex = startIndex + i;

                        final isSelected = actualIndex ==
                            scheduleController.selectedSlotIndex.value;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: GestureDetector(
                              onTap: () {
                                // if (!isBooked) {
                                //   scheduleController.selectSlotAsync(
                                //       actualIndex,
                                //       slotText,
                                //       doctorId); // ✅ real index
                                // }

                                if (!isBooked) {
                                  scheduleController.selectSlott(
                                    actualIndex,
                                    slotText,
                                  ); // ✅ real index
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: isBooked
                                      ? Colors.grey.shade300
                                      : isSelected
                                          ? mainColor
                                          : Colors.white,
                                  border: Border.all(
                                      color:
                                          isBooked ? Colors.grey : mainColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  slotText,
                                  style: TextStyle(
                                    color: isBooked
                                        ? Colors.grey
                                        : isSelected
                                            ? Colors.white
                                            : mainColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const Expanded(child: SizedBox(height: 48));
                      }
                    }),
                  );
                },
              ),

              // Toggle view more / less
              if ((scheduleController.currentSlots.length / 4).ceil() > 2)
                TextButton(
                  onPressed: () {
                    setState(() {
                      showAllRows = !showAllRows;
                    });
                  },
                  child: Text(
                    showAllRows ? "View Less" : "View More",
                    style: TextStyle(color: mainColor),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget showDays(String clinicId, String doctorId, String branchId) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        controller: _dateScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: scheduleController.weekDates.length,
        itemBuilder: (context, index) {
          final date = scheduleController.weekDates[index];

          return Obx(() {
            final isSelected =
                index == scheduleController.selectedDayIndex.value;

            return GestureDetector(
              onTap: () async {
                // final prefs = await SharedPreferences.getInstance();
                // var branchId = await prefs.getString('branchId');

                final slots = await DoctorSlotService.fetchDoctorSlots(
                    doctorId, clinicId, branchId);
                scheduleController.selectDate(date, slots);
              },
              child: Container(
                width: 60,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? mainColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: mainColor),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                          color: mainColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd').format(date),
                      style: TextStyle(
                          color: isSelected ? Colors.white : mainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      DateFormat('E').format(date).toUpperCase(),
                      style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : mainColor),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
