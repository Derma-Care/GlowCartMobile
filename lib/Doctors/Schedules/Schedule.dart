import 'package:cutomer_app/Customers/GetCustomerModel.dart';
import 'package:cutomer_app/Dashboard/GetCustomerData.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/DoctorSlotModel.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:cutomer_app/Doctors/Schedules/ConsentForm.dart';
import 'package:cutomer_app/Doctors/Schedules/ScheduleController.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
import 'package:cutomer_app/Widget/GobelTimer.dart';
import 'package:cutomer_app/Widget/TimerController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Consultations/SymptomsController.dart';
import '../../Controller/CustomerController.dart';
import '../../PatientsDetails/PatientDetailsFormController.dart';
import '../../PatientsDetails/PatientModel.dart';
import '../../PatientsDetails/PatientsDetails.dart';
import '../../Registration/RegisterController.dart';
import '../../ConfirmBooking/ConfirmBookingDetails.dart';
import '../../ConfirmBooking/ConsultationController.dart';
import '../../Utils/GradintColor.dart';
import '../../Widget/Bottomsheet.dart';

import 'package:intl/intl.dart';

import 'DoctorSlotService.dart';

class ScheduleScreen extends StatefulWidget {
  final HospitalDoctorModel doctorData;
  final String mobileNumber;
  final String username;
  final String branchId;
  const ScheduleScreen(
      {super.key,
      required this.doctorData,
      required this.mobileNumber,
      required this.username,
      required this.branchId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScrollController _dateScrollController = ScrollController();
  // final scheduleController = Get.find<ScheduleController>();
  final SymptomsController symptomsController = Get.put(SymptomsController());
  final ScheduleController scheduleController =
      Get.put(ScheduleController(), tag: UniqueKey().toString());

  final patientdetailsformcontroller = Get.put(Patientdetailsformcontroller());
  final selectedServicesController = Get.find<SelectedServicesController>();
  final consultationController = Get.find<Consultationcontroller>();
  final registercontroller = Get.put(Registercontroller());
  bool showAllRows = false;

  String? id;
  List<DoctorSlot>? slots;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());

    getUserData();
  }

  Future<void> _initialize() async {
    if (!mounted) return;

    try {
      // Start loading first
      scheduleController.isLoading.value = true;
      scheduleController.currentSlots.clear();
      scheduleController.selectedSlotIndex.value = -1;
      scheduleController.selectedSlotText.value = '';

      // Initialize week dates
      await scheduleController.initializeWeekDates();

      id = consultationController.selectedConsultation.value?.consultationId;

      final prefs = await SharedPreferences.getInstance();
      final hospitalId = prefs.getString('hospitalId');

      // Fetch latest slots
      final allSlots = await DoctorSlotService.fetchDoctorSlots(
        widget.doctorData.doctor.doctorId,
        hospitalId!,
        widget.branchId,
        onLoading: (loading) => scheduleController.isLoading.value = loading,
      );

      // Apply slots to controller
      scheduleController.filterSlotsForSelectedDate(allSlots);
      scheduleController.currentSlots.refresh();

      // Schedule midnight refresh
      scheduleController.scheduleMidnightRefresh(
        doctorId: widget.doctorData.doctor.doctorId,
        hospitalId: hospitalId,
        branchId: widget.branchId,
      );
    } catch (e) {
      debugPrint('❌ Initialization error: $e');
    } finally {
      // Stop loading after everything
      scheduleController.isLoading.value = false;
    }
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
  @override
  void dispose() {
    Get.delete<ScheduleController>(tag: scheduleController.hashCode.toString());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialize();
  }

  Future<void> fetchDoctorSlotsOnce() async {
    print("📡 Fetching slots once...");
    final prefs = await SharedPreferences.getInstance();
    var hospitalId = prefs.getString('hospitalId');

    final allSlots = await DoctorSlotService.fetchDoctorSlots(
      widget.doctorData.doctor.doctorId,
      hospitalId!,
      widget.branchId,
    );

    // ✅ Immediately update the controller with new data
    scheduleController.filterSlotsForSelectedDate(allSlots);
    scheduleController.currentSlots.refresh();
  }

  String? fullName;
  String? patientId;
  GetCustomerModel? patientData;

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    var customerId = await prefs.getString('customerId');
    final userData = await fetchUserData(
        customerId!); // Assuming this returns a Map or model
    if (userData != null) {
      setState(() {
        fullName =
            userData.fullName; // or userData.fullName depending on structure
        patientData = userData;
        patientId = userData.patientId;
        print("✅ Fetched user data: $fullName, $patientId");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonHeader(
          title: "Schedule",
          onNotificationPressed: () {},
          onSettingPressed: () {},
        ),
        body: Stack(children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month & Arrow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy')
                            .format(scheduleController.selectedDate.value),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon:
                            Icon(Icons.keyboard_arrow_right, color: mainColor),
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _dateScrollController.animateTo(
                              _dateScrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                            );
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  showDays(),

                  const SizedBox(height: 24),
                  timeslots(),

                  const SizedBox(height: 24),
                  Divider(color: secondaryColor),
                  const SizedBox(height: 12),
                  languagesKnown(),
                  Divider(color: secondaryColor),

                  PatientDetailsForm(
                    mobileNumber: widget.mobileNumber,
                    username: widget.username,
                  ), // ✅ Add your working form here
                ],
              ),
            ),
          ),
          GlobalTimerFAB(
              doctorId: widget.doctorData.doctor.doctorId,
              slot: scheduleController.selectedSlotText.value),
        ]),
        bottomNavigationBar: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: appGradient(),
          ),
          child: Obx(() => TextButton(
                onPressed: scheduleController.currentSlots.isEmpty
                    ? null // ✅ Button disabled if no slots available
                    : () async {
                        if (!patientdetailsformcontroller.formKey.currentState!
                            .validate()) {
                          showSnackbar(
                              "Warning",
                              "Please fill the Patient Details Form",
                              "warning");
                          return;
                        }

                        final slotIndex =
                            scheduleController.selectedSlotIndex.value;

                        // if (slotIndex == -1) {
                        //   showSnackbar(
                        //       "Warning", "Please select a slot", "warning");
                        //   return;
                        // }

                        final slotText =
                            scheduleController.selectedSlotText.value;

                        if (slotIndex == -1 || slotText.isEmpty) {
                          ScaffoldMessageSnackbar.show(
                            context: context,
                            message: "Please select a slot",
                            type: SnackbarType.warning,
                          );
                          // showSnackbar(
                          //     "Warning", "Please select a slot", "warning");
                          return;
                        }

                        final slot = scheduleController.currentSlots[slotIndex];

                        bool success = await scheduleController.selectSlotAsync(
                            slotIndex,
                            slot.slot,
                            widget.doctorData.doctor.doctorId,
                            widget.branchId);

                        // if (!success) {
                        //   showSnackbar("Warning",
                        //       "Failed to select slot. Try again", "warning");
                        //   return;
                        // }
                        // ✅ Start global timer when continuing
                        // Start timer
                        final timerController = Get.find<TimerController>();
                        timerController.startTimer(
                            doctorId: widget.doctorData.doctor.doctorId,
                            slot: slotText,
                            context: context);
                        final String enteredName =
                            patientdetailsformcontroller.selectedFor == 'Self'
                                ? (fullName ?? widget.username ?? '')
                                : patientdetailsformcontroller
                                    .nameController.text
                                    .trim();

                        // ✅ Slot successfully selected, continue to next screen
                        String formattedDate = DateFormat('yyyy-MM-dd')
                            .format(scheduleController.selectedDate.value);
                        if (enteredName.isEmpty) {
                          ScaffoldMessageSnackbar.show(
                            context: context,
                            message: "Please provide patient information",
                            type: SnackbarType.warning,
                          );

                          return; // Stop navigation
                        }
                        PatientModel patientmodel = PatientModel(
                          name: patientdetailsformcontroller.selectedFor ==
                                  'Self'
                              ? (fullName ?? widget.username)
                              : patientdetailsformcontroller.nameController.text
                                  .trim(),
                          patientId: patientdetailsformcontroller.selectedFor ==
                                  'Self'
                              ? patientId ??
                                  "" // use patientData.patientId if Self, fallback to empty
                              : patientdetailsformcontroller
                                          .patientId?.isNotEmpty ==
                                      ""
                                  ? patientdetailsformcontroller.patientId!
                                  : "",
                          age: patientdetailsformcontroller.selectedFor ==
                                  'Self'
                              ? "${patientdetailsformcontroller.age} Yrs"
                              : "${patientdetailsformcontroller.ageController.text} Yrs",
                          gender: registercontroller.selectedGender,
                          bookingFor:
                              patientdetailsformcontroller.selectedFor.value,
                          problem: consultationController.selectedConsultation
                                      .value!.consultationType
                                      .toLowerCase() ==
                                  "services & treatments"
                              ? patientdetailsformcontroller
                                  .notesController.text
                              : symptomsController.symptoms.value,
                          monthYear: DateFormat('MMMM dd, yyyy')
                              .format(scheduleController.selectedDate.value),
                          serviceDate: formattedDate,
                          servicetime:
                              scheduleController.selectedSlotText.value,
                          mobileNumber: widget.mobileNumber,
                          customerDeviceId:
                              (await SharedPreferences.getInstance())
                                      .getString('fcm') ??
                                  "",
                          relation:
                              patientdetailsformcontroller.selectedFor == 'Self'
                                  ? "Self"
                                  : patientdetailsformcontroller
                                      .relationController.text
                                      .trim(),
                          patientMobileNumber:
                              patientdetailsformcontroller.selectedFor == 'Self'
                                  ? widget.mobileNumber
                                  : patientdetailsformcontroller
                                      .patientMobileNumberController.text
                                      .trim(),
                          patientAddress: patientdetailsformcontroller
                              .addressController.text,
                        );

                        Get.to(() => Confirmbookingdetails(
                              doctor: widget.doctorData,
                              patient: patientmodel,
                            ));
                      },
                child: Text(
                  "CONTINUE",
                  style: TextStyle(
                      color: scheduleController.currentSlots.isEmpty
                          ? Colors.grey.shade400
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              )),
        ));
  }

  languagesKnown() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text("Languages Known",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 20,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.doctorData.doctor.languages.map((lang) {
            String displayText =
                scheduleController.languageLabels[lang] ?? lang;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Text(
                displayText,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

// In your timeslots() widget:
  Widget timeslots() {
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
        Obx(() {
          if (scheduleController.isLoading.value) {
            // Show loading spinner while fetching slots
            return Center(
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
                    "Fetching Slots...",
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

          if (scheduleController.currentSlots.isEmpty) {
            // Show message if no slots available
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "No available slots",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          // Slots available
          return Column(
            children: [
              // Slot rows (4 per row)
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
                        final actualIndex = startIndex + i;

                        final isSelected = slotData.tempSelected ||
                            (actualIndex ==
                                scheduleController.selectedSlotIndex.value);

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: GestureDetector(
                              onTap: () {
                                if (!isBooked) {
                                  scheduleController.selectSlott(
                                    actualIndex,
                                    slotText,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: slotData.slotbooked
                                      ? Colors.grey.shade300
                                      : isSelected
                                          ? mainColor
                                          : Colors.white,
                                  border: Border.all(
                                      color: slotData.slotbooked
                                          ? Colors.grey
                                          : mainColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  slotData.slot,
                                  style: TextStyle(
                                    color: slotData.slotbooked
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

              // 🔘 View More / View Less toggle
              if ((scheduleController.currentSlots.length / 4).ceil() > 2)
                TextButton(
                  onPressed: () {
                    setState(() {
                      showAllRows = !showAllRows;
                    });
                  },
                  child: Text(
                    showAllRows ? 'View Less' : 'View More',
                    style: TextStyle(color: mainColor),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

// In your showDays() widget:
  Widget showDays() {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        controller: _dateScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: scheduleController.weekDates.length,
        itemBuilder: (context, index) {
          final date = scheduleController.weekDates[index];

          return Obx(() {
            final isSelected =
                index == scheduleController.selectedDayIndex.value;
            print("isSelected $isSelected");

            return GestureDetector(
              onTap: () async {
                final tappedDate = date;
                final prefs = await SharedPreferences.getInstance();
                var hospitalId = await prefs.getString('hospitalId');
                final slots = await DoctorSlotService.fetchDoctorSlots(
                    widget.doctorData.doctor.doctorId,
                    hospitalId!,
                    widget.branchId);

                scheduleController.selectDate(tappedDate, slots);
              },
              child: Container(
                width: 50,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected ? mainColor : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: mainColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : mainColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('E').format(date).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : mainColor,
                      ),
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
