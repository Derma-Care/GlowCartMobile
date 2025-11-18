import 'dart:convert';
import 'dart:typed_data';
import 'package:cutomer_app/Booings/BooingService.dart';
import 'package:cutomer_app/Clinic/AboutClinicController.dart';
import 'package:cutomer_app/ConfirmBooking/ConsultationServices.dart';
import 'package:cutomer_app/Consultations/SymptomsController.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:cutomer_app/DotorRef/RefDoctorModal.dart';
import 'package:cutomer_app/DotorRef/RefDoctorService.dart';
import 'package:cutomer_app/Inputs/CustomDropdownField.dart';
import 'package:cutomer_app/Loading/FullScreeenLoader.dart';
import 'package:cutomer_app/Modals/ServiceModal.dart';
import 'package:cutomer_app/Screens/BookingSuccess.dart';
import 'package:cutomer_app/Services/SubServiceServices.dart';
import 'package:cutomer_app/TreatmentAndServices/SubserviceController.dart';
import 'package:cutomer_app/Utils/GradintColor.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
import 'package:cutomer_app/Widget/GobelTimer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../BottomNavigation/Appoinments/PostBooingModel.dart';
import '../Controller/CustomerController.dart';
import '../Doctors/DoctorDetails/DoctorDetailsScreen.dart';
import '../PatientsDetails/PatientModel.dart';
import '../Payments/AllPayments.dart';
import '../Payments/PaymentMode.dart';
import '../Utils/Constant.dart';
import 'ConsultationController.dart';

class Confirmbookingdetails extends StatefulWidget {
  final HospitalDoctorModel doctor;
  final PatientModel patient;
  final Uint8List? pdfBytes;
  Confirmbookingdetails({
    super.key,
    required this.doctor,
    required this.patient,
    this.pdfBytes,
  });

  @override
  State<Confirmbookingdetails> createState() => _ConfirmbookingdetailsState();
}

class _ConfirmbookingdetailsState extends State<Confirmbookingdetails> {
  final selectedServicesController = Get.find<SelectedServicesController>();
  final consultationController = Get.find<Consultationcontroller>();
  final SymptomsController symptomsController = Get.put(SymptomsController());
  final TextEditingController controller = TextEditingController();
  final TextEditingController doctorRefController = TextEditingController();
  final consultationcontroller = Get.find<Consultationcontroller>();
  SubService? subServiceDetails;
  // final confirmbookingcontroller = Get.find<Confirmbookingcontroller>();
  Doctor? doctor;
  final subServiceController = Get.find<SubServiceController>();
  Hospital? hospital;
  List<ConsultationModel> _consultations = [];
  int consultationFee = 0;
  int totalFee = 0;
  // globals.dart
  final hcontroller = Get.put(ClinicController());
  String globalServiceId = '';
  List<RefDoctor> apiDoctors = [];
  String? selectedDoctorRefId;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _getDoctors();
    doctor = widget.doctor.doctor;
    // hospital = widget.doctor.hospital;
    loadSubService();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final selectedId =
          consultationController.selectedConsultation.value?.consultationId ??
              "";

      print("selectedId Consulation : ${selectedId}");
      globalServiceId = selectedId;
      final consultations = await getConsultationDetails();

      if (consultations.isNotEmpty) {
        setState(() {
          _consultations = consultations;
        });

        // Now execute based on matched ID
        if (selectedId == consultations[0].consultationId) {
          print(
              "selectedId Consulation : ${selectedId} , ${consultations[0].consultationId}");
          setState(() {
            consultationFee = selectedServicesController
                .selectedSubServices.first.consultationFee
                .toInt();
          });
        } else if (selectedId == consultations[1].consultationId) {
          setState(() {
            consultationFee = doctor?.doctorFees.inClinicFee ?? 0;
          });
        } else if (selectedId == consultations[2].consultationId) {
          setState(() {
            consultationFee = doctor?.doctorFees.vedioConsultationFee ?? 0;
          });
        } else {
          setState(() {
            consultationFee = 0;
          });
        }
      }
    });
  }

  String? hospitalId;
  String? clinicName;

  void loadSubService() async {
    final prefs = await SharedPreferences.getInstance();
    var hospitalId = await prefs.getString('hospitalId');
    print("Calling loadSubService...${hospitalId}");

    // hcontroller.fetchClinic(hospitalId!);
    print("Calling loadSubService...");

    clinicName = await prefs.getString('hospitalName');
    // final hospitalId = widget.doctor.hospital.hospitalId;

    // Get the selected sub-service from controller
    final selectedSubService = subServiceController.selectedSubService.value;

    if (selectedSubService == null) {
      print("❌ No sub-service selected");
      return;
    }

    // print("Hospital ID: $hospitalId");
    print("Selected Sub-Service ID: ${selectedSubService.subServiceId}");

    // Use subServiceId to fetch the details
    final result = await fetchSubServiceDetails(
        hospitalId!, selectedSubService.subServiceId);

    print("Fetched Sub-Service Details: $result");

    setState(() {
      subServiceDetails = result;
    });
  }

  void _getDoctors() async {
    final service = RefDoctorService();
    final result = await service.fetchDoctors();
    print("Fetched doctors length: ${result.length}"); // Debug

    setState(() {
      apiDoctors = result;
      isLoading = false;
    });
  }

  String? selectedDoctor;
  // doctor_data.dart
  // final List<Map<String, String>> dummyDoctors = [
  //   {"name": "Dr. John Doe", "refId": "REF123"},
  //   {"name": "Dr. Smith Adams", "refId": "REF456"},
  //   {"name": "Dr. Priya Sharma", "refId": "REF789"},
  //   {"name": "Dr. Rahul Verma", "refId": "REF987"},
  // ];

  @override
  Widget build(BuildContext context) {
    final clinic = hcontroller.clinic.value;
    print("Clinic Data222: $clinic");
    Widget? consultationWidget;
    bool loading = false;
    String? currentConsultationId;
    String? selectedDoctorRefId = null; // not ''

    final double gstRate = 0.18;
    final double taxRate = 0;
    final double servicePrice = subServiceDetails?.price ?? 0;
    final double gstAmount = servicePrice * gstRate;
    final double taxAmount = servicePrice * taxRate;
    final double totalAmount = (servicePrice + gstAmount + taxAmount);
    final isServiceConsultation = _consultations.isNotEmpty &&
            consultationController
                    .selectedConsultation.value?.consultationType ==
                _consultations.first.consultationType
        ? true
        : false;

    final consultationType = consultationController
        .selectedConsultation.value?.consultationType
        ?.toLowerCase();
    // final consultationId =
    //     consultationController.selectedConsultation.value?.consultationId;
    final consultationId =
        consultationController.selectedConsultation.value?.consultationId;
    final backeEndCOnsulationID =
        _consultations.isNotEmpty ? _consultations.first.consultationId : '';

    // final consultationId =
    //     consultationController.selectedConsultation.value?.consultationId;

    print(
        '[🏥] Booking via Pay at paymentType ${selectedServicesController.selectedPayment.value}');

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CommonHeader(
        title: "Confirm Booking",
        onNotificationPressed: () {},
        onSettingPressed: () {},
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(top: 85), // ✅ Remove extra padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Info Card
              Column(
                children: [
                  profileCard(clinicName ?? ''),
                  Obx(() {
                    final consultationId = consultationController
                        .selectedConsultation.value?.consultationId;
                    if (consultationId == null) return SizedBox();

                    print("consultationId sdsadsad: $consultationId");

                    return FutureBuilder(
                      key: ValueKey(consultationId),
                      future: _getServiceButton(
                          consultationId, backeEndCOnsulationID),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          print("🔥 Error: ${snapshot.error}");
                          return Text("Error: ${snapshot.error}");
                        } else {
                          return snapshot.data as Widget;
                        }
                      },
                    );
                  })
                ],
              ),

              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Doctor Referral Code (if any)",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        isLoading
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<String>(
                                value: selectedDoctorRefId,
                                decoration: const InputDecoration(
                                  labelText: "Select Referring Doctor",
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(),
                                ),
                                items: apiDoctors.map((doctor) {
                                  return DropdownMenuItem<String>(
                                    value: doctor.referralId,
                                    child: Text(
                                        "${doctor.fullName} (${doctor.referralId})"),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedDoctorRefId = value;
                                    print(
                                        "Selected Doctor Ref ID: $selectedDoctorRefId");
                                  });
                                },
                              ),
                      ],
                    ),
                  ),
                  PaymentModeSelector(
                    consultationType: consultationController
                        .selectedConsultation.value!.consultationType,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Patient Details",
                  style: TextStyle(
                      color: mainColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 10),
              infoRow("Booking For", widget.patient.bookingFor),
              infoRow("Patient Name", widget.patient.name),
              infoRow("Patient Age", "${widget.patient.age} "),
              infoRow("Patient Gender", widget.patient.gender),

// Show Symptoms if available
              if (symptomsController.duration.value.isNotEmpty)
                Obx(() {
                  // final duration = symptomsController.duration.value;
                  return infoRow(
                    "Duration",
                    "${symptomsController.duration.value}",
                  );
                }),

              if (symptomsController.visitType.value.isNotEmpty)
                Obx(() {
                  return infoRow(
                      "Visit Type", "${symptomsController.visitType.value}");
                }),

              // Show Symptoms if available
              Obx(() {
                return infoColumn(
                  symptomsController.symptoms.value.isNotEmpty
                      ? "Symptoms"
                      : "Patient Problem",
                  symptomsController.symptoms.value.isNotEmpty
                      ? symptomsController.symptoms.value
                      : widget.patient.problem,
                );
              }),

              SizedBox(height: 15),

// Show Attachment if available
              if (symptomsController.attachments.value != null)
                Obx(() {
                  if (symptomsController.attachments.isEmpty) {
                    return SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 4),
                        child: Text(
                          "Attachments",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: List.generate(
                              symptomsController.attachments.length, (index) {
                            final file = symptomsController.attachments[index];
                            final isPdf =
                                file.path.toLowerCase().endsWith('.pdf');

                            final isPDF =
                                file.path.toLowerCase().endsWith('.pdf');
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (isPDF) {
                                      await OpenFilex.open(file.path);
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Scaffold(
                                            appBar: CommonHeader(
                                              title: "Image Preview",
                                            ),
                                            body: Center(
                                              child: InteractiveViewer(
                                                child: Image.file(file),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: isPDF
                                      ? Container(
                                          width: 140,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.grey[200],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.picture_as_pdf,
                                                  color: Colors.red, size: 30),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  file.path.split('/').last,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.file(file,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                ),
                                Positioned(
                                  right: -5,
                                  top: -5,
                                  child: InkWell(
                                    onTap: () => symptomsController
                                        .removeAttachment(index),
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: Colors.red,
                                      child: Icon(Icons.close,
                                          size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                      SizedBox(height: 15),
                    ],
                  );
                }),

              Divider(
                height: 1,
                color: secondaryColor,
              ),
              SizedBox(
                height: 15,
              ),
              // patyment imaformation
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Payment Details",
                  style: TextStyle(
                      color: mainColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text("${consultationId}"),
                  if (_consultations.isNotEmpty) ...[
                    // Text("${_consultations[0].consultationId}"),
                    if (consultationId != "ST_01") ...[
                      // Static fields for Services & Treatments
                      infoRow("Consultation Fee",
                          "₹ ${consultationFee.toStringAsFixed(0) ?? '0'}"),
                      infoRow("GST (18%)",
                          "₹ ${(consultationFee * 0.18).toStringAsFixed(0) ?? '0'}"),
                      infoRow("Other Tax",
                          "₹ ${taxAmount.toStringAsFixed(0) ?? '0'}"),
                      infoRow("Total Fee",
                          "₹ ${(consultationFee + consultationFee * 0.18 + 0)?.toStringAsFixed(0) ?? '0'}"),
                    ] else ...[
                      // Normal flow from subServiceDetails
                      infoRow(
                        "Consultation Fee",
                        "₹ ${subServiceDetails?.consultationFee?.toStringAsFixed(0) ?? '0'}",
                      ),
                      infoRow(
                        "${consultationController.selectedConsultation.value?.consultationType ?? 'Consultation'} Fee",
                        "₹ ${subServiceDetails?.price?.toStringAsFixed(0) ?? '0'}",
                      ),
                      infoRow(
                        "GST (${subServiceDetails?.gst ?? 0}%)",
                        "₹ ${subServiceDetails?.gstAmount?.toStringAsFixed(0) ?? '0'}",
                      ),
                      infoRow(
                        "Other Tax (${subServiceDetails?.taxPercentage?.toStringAsFixed(0) ?? '0'}%)",
                        "₹ ${subServiceDetails?.taxAmount?.toStringAsFixed(0) ?? '0'}",
                      ),
                      infoRow(
                        "Discounted Amount (${subServiceDetails?.discountPercentage?.toStringAsFixed(0) ?? '0'}%)",
                        "₹ ${subServiceDetails?.discountAmount?.toStringAsFixed(0) ?? '0'}",
                      ),
                      infoRow(
                        "Total Fee",
                        "₹ ${subServiceDetails?.finalCost?.toStringAsFixed(0) ?? '0'}",
                      ),
                    ]
                  ] else
                    Text("No consultation data available")
                ],
              ),

              SizedBox(
                height: 25,
              ),
              Divider(
                height: 1,
                color: secondaryColor,
              ),
              // PaymentModeSelector(
              //   consultationType: consultationController
              //       .selectedConsultation.value!.consultationType,
              // ),
              // const SizedBox(height: 20),
              // Obx(() => Text(selectedServicesController.selectedPayment.value)),
            ],
          ),
        ),
        GlobalTimerFAB(
            doctorId: widget.doctor.doctor.doctorId,
            slot: widget.patient.servicetime),
      ]),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(gradient: appGradient()),
        child: TextButton(
          onPressed: () async {
            final selectedPayment =
                selectedServicesController.selectedPayment.value;

            print("Selected Payment: $selectedPayment");
            String? pdfBase64 =
                widget.pdfBytes != null ? base64Encode(widget.pdfBytes!) : null;

            final branchName =
                consultationcontroller.selectedBranchName.value.isNotEmpty
                    ? consultationcontroller.selectedBranchName.value
                    : "Not Selected";
            final branchId =
                consultationcontroller.selectedBranchId.value.isNotEmpty
                    ? consultationcontroller.selectedBranchId.value
                    : "Not Selected";

            final prefs = await SharedPreferences.getInstance();
            var clinicName = await prefs.getString('hospitalName');
            var hospitalId = await prefs.getString('hospitalId');
            var customerId = await prefs.getString('customerId');

            final bookingDetails = BookingDetailsModel(
              subServiceName: globalServiceId == backeEndCOnsulationID
                  ? selectedServicesController
                      .selectedSubServices.first.subServiceName
                  : "NA",
              subServiceId: globalServiceId == backeEndCOnsulationID
                  ? selectedServicesController
                      .selectedSubServices.first.subServiceId
                  : "NA",
              doctorId: widget.doctor.doctor.doctorId,
              consultationType: consultationController
                  .selectedConsultation.value!.consultationType,
              consultationFee: consultationFee.toDouble(),
              totalFee: globalServiceId == backeEndCOnsulationID
                  ? selectedServicesController
                      .selectedSubServices.first.finalCost
                  : consultationFee + (consultationFee * 0.18) + 0,
              clinicId: hospitalId ?? "",
              doctorDeviceId: widget.doctor.doctor.deviceId,
              clinicAddress: clinic?.address ?? "",
              //TODO:chnage address
              categoryName: globalServiceId == backeEndCOnsulationID
                  ? selectedServicesController
                      .selectedSubServices.first.categoryName
                  : "NA",
              categoryId: globalServiceId == backeEndCOnsulationID
                  ? selectedServicesController
                      .selectedSubServices.first.categoryId
                  : "NA",
              servicename: globalServiceId == backeEndCOnsulationID
                  ? selectedServicesController
                      .selectedSubServices.first.serviceName
                  : "NA",
              serviceId: globalServiceId == backeEndCOnsulationID
                  ? selectedServicesController
                      .selectedSubServices.first.serviceId
                  : "NA",
              clinicName: clinicName ?? "",
              doctorName: widget.doctor.doctor.doctorName,
              // consultationExpiration:
              //     widget.doctor.hospital.consultationExpiration,
              consultationExpiration: clinic?.consultationExpiration ??
                  "0 Days", //TODO:chnage consultationExpiration
              paymentType: selectedPayment,
              visitType: symptomsController.visitType.value,
              symptomsDuration:
                  "${symptomsController.duration.value}", //TODO:develop in UI

              attachments: symptomsController.attachments.value,
              freeFollowUps: clinic?.freeFollowUps ?? 0,
              consentFormPdf: pdfBase64 ?? "",
              doctorRefCode: selectedDoctor ?? "",
              branchname: branchName,
              branchId: branchId,
              customerId: customerId!,
            );
            print(
                '[🏥] Booking via Pay at Hospital ${bookingDetails.toString()}');
            print(
                '[🏥] Booking via Pay at freeFollowUps ${clinic?.freeFollowUps}');
            print('[🏥] Booking via Pay at Hospital ${controller.text}');

            // 📦 Model ready for API
            final postBookingPayload = PostBookingModel(
              patient: widget.patient,
              booking: bookingDetails,
            );
            print(
                "📦 Final Payload: ${jsonEncode(postBookingPayload.toJson())}");
            if (selectedPayment == "Pay at Hospital") {
              // 🏥 DIRECTLY POST BOOKING
              print('[🏥] Booking via Pay at Hospital');
              showDialog(
                context: context,
                barrierDismissible: false, // Prevent closing
                builder: (_) => FullscreenLoader(
                  message: "Processing Booking...",
                  logoPath:
                      "assets/ic_launcher.png", // Provide your app logo path
                ),
              );

              var responseData = await postBookings(postBookingPayload);
              print('[DEBUG] Response Data: $responseData');
              Navigator.of(context, rootNavigator: true).pop();

              if (responseData != null &&
                  responseData['statusCode'] == 201 &&
                  responseData['data'] != null) {
                print('[✅] Booking successful');

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => SuccessScreen(
                        serviceDetails: widget.doctor,
                        clinicData: widget.doctor,
                        paymentId: "pay_at_hospital",
                        patient: widget.patient,
                        mobileNumber: widget.patient.mobileNumber,
                        paymentType: "cash",
                        branchName: branchName),
                  ),
                  (route) => false,
                );
              } else {
                print(
                    '[❌] Booking failed or unexpected response: $responseData');
                ScaffoldMessageSnackbar.show(
                  context: context,
                  message: "Booking failed",
                  type: SnackbarType.error,
                );
                // showSnackbar("Error", "Booking failed", "error");
              }
            } else {
              // 💳 GO TO PAYMENT SCREEN
              print('[💳] Navigating to Razorpay...');

              Get.to(() => RazorpaySubscription(
                    context: context,
                    amount: isServiceConsultation
                        ? (subServiceDetails?.finalCost?.toStringAsFixed(0) ??
                            "0")
                        : (consultationFee + consultationFee * 0.18)
                            .toStringAsFixed(0),
                    onPaymentInitiated: () {
                      ScaffoldMessageSnackbar.show(
                            context: context,
                            message: "Payment Initiated",
                            type: SnackbarType.warning,
                          );
                     
                    },
                    serviceDetails: widget.doctor,
                    patient: widget.patient,
                    bookingDetails: postBookingPayload,
                    mobileNumber: widget.patient.mobileNumber,
                    branchName: branchName,
                  ));

              // }
              // void handleNextScreen(BuildContext context, Map<String, dynamic> payload) async {
              //   final response = await http.get(Uri.parse(
              //       'https://rainbow.exwyn.com/api/generateTransactionId'));

              //   if (response.statusCode == 200) {
              //     final restxnId =
              //         response.body; // assuming plain string or parse accordingly
              //     final txnidData = json.decode(restxnId);
              //     print("txnidData ${restxnId}");

              //     final txnId = txnidData['data'];

              //     var finalPayload = ({
              //           "PatientName": "John",
              //           "EmailAddress": "john@example.com",
              //           "MobileNumber": "9999999999",
              //           "payment_type": "ONLINE",
              //           "price": consultationFee.toString()
              //         }),
              //         payload = FinalPayload.fromJson(finalPayload);

              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => PayUWebViewScreen(
              //           txnId: txnId,
              //           amount: consultationFee.toString(),
              //           payuUrl: "https://test.payu.in/_payment",
              //           serviceDetails: widget.doctor,
              //           mobileNumber: widget.patient.mobileNumber,
              //           context: context,
              //           patient: widget.patient,
              //           bookingDetails: postBookingPayload,
              //           finalPayload: payload, // Use live URL in production
              //         ),
              //       ),
              //     );
              //   } else {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(content: Text('Transaction ID fetch failed')));
              //   }
            }
          },
          child: Obx(() {
            final selectedPayment =
                selectedServicesController.selectedPayment.value;

            final isPayAtHospital =
                selectedPayment.toLowerCase() == 'pay at hospital';
            final buttonText = isPayAtHospital
                ? "BOOK APPOINTMENT (₹ ${isServiceConsultation ? subServiceDetails?.finalCost.toStringAsFixed(0) : (consultationFee + consultationFee * 0.18 + 0).toStringAsFixed(0)})"
                : "BOOK & PAY (₹ ${isServiceConsultation ? subServiceDetails?.finalCost.toStringAsFixed(0) : (consultationFee + consultationFee * 0.18 + 0).toStringAsFixed(0)})";

            return Text(
              buttonText,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            );
          }),
        ),
      ),
    );
  }

  infoRow(String title, dynamic info) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${title} ",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(info)
        ],
      ),
    );
  }

  infoColumn(String title, dynamic info) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${title}: ",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 10,
          ),
          Text(info)
        ],
      ),
    );
  }

  Widget profileCard(String clinicName) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            mainColor,
            secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  "${clinicName}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                Obx(() {
                  final controller = Get.find<Consultationcontroller>();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${controller.selectedBranchName.value.isNotEmpty ? controller.selectedBranchName.value : "Not Selected"}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],
                  );
                })
              ],
            ),
            Divider(
              height: 1,
              color: secondaryColor,
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: doctor!.doctorPicture.isNotEmpty
                      ? Image.memory(
                          base64Decode(doctor!.doctorPicture.split(',').last),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          "https://via.placeholder.com/150",
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                ),

                const SizedBox(width: 12),

                // Text Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        "${doctor!.doctorName}",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        doctor!.qualification,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        doctor!.specialization,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 206, 211, 207),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton(
                            onPressed: () {
                              Get.to(() => DoctorDetailScreen(
                                  doctorData: widget.doctor));
                            },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              side: const BorderSide(
                                  color: Colors.white,
                                  width: 1), // ✅ White border
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // ✅ Rounded corners
                              ),
                            ),
                            child: const Text(
                              "About",
                              style: TextStyle(
                                  color:
                                      Colors.white), // ✅ Optional: white text
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String consultationType = "";

  Future<Widget> _getServiceButton(
      String id, String backeEndCOnsulationID) async {
    print("Fetching consultation for ID: $id");
    Color color = Colors.white;
    int consultationFee = 0;
    String consultationType = '';

    final consultations = await getConsultationDetails();

    // ✅ Search in the list of ConsultationModel
    final matchedConsultation = consultations.firstWhere(
      (c) => c.consultationId == id,
      orElse: () => ConsultationModel(
        consultationId: '',
        consultationType: 'Unknown',
      ),
    );

    consultationType = matchedConsultation.consultationType;

    print("consultationType: $consultationType");

    if (consultationType.toLowerCase().contains('service')) {
      consultationFee = selectedServicesController
          .selectedSubServices.first.finalCost
          .toInt();
    } else if (consultationType.toLowerCase().contains('clinic')) {
      consultationFee = doctor?.doctorFees.inClinicFee ?? 0;
    } else if (consultationType.toLowerCase().contains('online')) {
      consultationFee = doctor?.doctorFees.vedioConsultationFee ?? 0;
    } else {
      consultationFee = 0;
      color = Colors.grey;
    }

    print("consultationFee: $consultationFee");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _serviceButton(consultationType, color, id, consultationFee),
        SlotBookingAndConsltation(
            consultationType, consultationFee, id, backeEndCOnsulationID),
      ],
    );
  }

  Widget _serviceButton(
      String title, Color backgroundColor, String id, int fee) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 6,
                offset: Offset(0, 0),
              )
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Text(
                  "Consultation Type",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: mainColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget SlotBookingAndConsltation(
      String title, int fee, String id, String backeEndCOnsulationID) {
    print("title __ ${title}");
    print("fee __ ${fee}");
    print("id __ ${id}");
    final services;
    if (title == "Services & Treatments") {
      services = selectedServicesController.selectedSubServices;
      print(
          "selectedServicesControllersdds __ ${selectedServicesController.selectedSubServices.first.finalCost}");
    }

    DateTime date = DateTime.parse(widget.patient.serviceDate);
    String dayName = DateFormat('EEEE').format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.patient.monthYear,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${dayName}, ${widget.patient.servicetime}",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Obx(() {
              // Only show sub-services if ST_01
              if (consultationController
                      .selectedConsultation.value?.consultationId ==
                  backeEndCOnsulationID) {
                final services = selectedServicesController.selectedSubServices;
                if (services.isEmpty) {
                  return const Text(
                    "No services selected",
                    style: TextStyle(color: Colors.black),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: services.map((service) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 10),
                      child: Column(
                        children: [
                          Text(
                            service.subServiceName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: mainColor,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Price: ₹ ${service.finalCost.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: mainColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              } else {
                // For other consultation types, show only the consultation fee
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Consultation Fee",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                    Text(
                      "₹ ${fee.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    )
                  ],
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
