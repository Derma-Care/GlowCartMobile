// ignore_for_file: public_member_api_docs, sort_constructors_first
//yYlr0giZXIFiCkwvlrpEXvcuvMZp8JfU

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cutomer_app/Booings/BooingService.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:cutomer_app/BottomNavigation/Appoinments/PostBooingModel.dart';
// import 'package:cutomer_app/Doctors/ListOfDoctors/DoctorModel.dart';
import 'package:cutomer_app/PatientsDetails/PatientModel.dart';
import 'package:cutomer_app/Screens/BookingSuccess.dart';

import 'final_payload.dart';

class PayUWebViewScreen extends StatefulWidget {
  final FinalPayload finalPayload;
  final String txnId;
  final String amount;
  final String payuUrl;
  final HospitalDoctorModel serviceDetails;
  final String mobileNumber;
  final BuildContext context;
  final PatientModel patient;
  final PostBookingModel bookingDetails;

  const PayUWebViewScreen({
    Key? key,
    required this.finalPayload,
    required this.txnId,
    required this.amount,
    required this.payuUrl,
    required this.serviceDetails,
    required this.mobileNumber,
    required this.context,
    required this.patient,
    required this.bookingDetails,
  }) : super(key: key);

  @override
  State<PayUWebViewScreen> createState() => _PayUWebViewScreenState();
}

class _PayUWebViewScreenState extends State<PayUWebViewScreen> {
  bool loading = true;
  String hash = '';

  final String key = "MG51e2";
  final String salt =
      "yYlr0giZXIFiCkwvlrpEXvcuvMZp8JfU"; // ⛔️ Replace with your test/production salt
  final String productInfo = "Video Consultation";
  final String successUrl = "https://rainbow.exwyn.com/api/payment/success";
  final String failureUrl = "https://rainbow.exwyn.com/api/payment/failure";

  //   final String successUrl = "https://13.233.9.23/api/payment/success";
  // final String failureUrl = "https://13.233.9.23/api/payment/failure";

  @override
  void initState() {
    super.initState();
    _generateLocalHash();
    print("successUrl : ${successUrl}");
    print("failureUrl : ${failureUrl}");
  }

  void _generateLocalHash() {
    final String firstname = widget.finalPayload.patientName ?? '';
    final String email = widget.finalPayload.emailAddress ?? '';
    final String txnId = widget.txnId;
    final String amount = widget.amount;

    final String rawHash =
        "$key|$txnId|$amount|$productInfo|$firstname|$email|||||||||||$salt";

    final bytes = utf8.encode(rawHash);
    final digest = sha512.convert(bytes);

    setState(() {
      hash = digest.toString();
    });
  }

  void _onNavigationChanged(String url) async {
    if (url.startsWith(successUrl)) {
      var responseData = await postBookings(widget.bookingDetails);

      print('[DEBUG] Response Data: $responseData');

      if (responseData!['statusCode'] == 201 && responseData['data'] != null) {
        print('[DEBUG] Inside if block');

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (ctx) => SuccessScreen(
                serviceDetails: widget.serviceDetails,
                paymentId: widget.txnId.toString(),
                patient: widget.patient,
                mobileNumber: widget.mobileNumber,
                paymentType: "online",
                clinicData: widget.serviceDetails,
                branchName: '',
              ),
            ),
            (route) => false);

        //Testing
        final testVideoCallTime = DateTime.now().add(Duration(minutes: 6));

        //original
        // Assume these are coming from your bookingDetails or responseData
        final serviceDate =
            widget.bookingDetails.patient.serviceDate; // e.g., "2025-06-29"
        final serviceTime =
            widget.bookingDetails.patient.servicetime; // e.g., "08:00 PM"

// Combine and parse to DateTime
        final String combinedDateTimeStr = '$serviceDate $serviceTime';
        print('[📅] Combined Date & Time string: $combinedDateTimeStr');

        final DateTime videoCallTime =
            DateFormat('yyyy-MM-dd hh:mm a').parse(combinedDateTimeStr);
        print('[✅] Parsed video call DateTime: $videoCallTime');

        print('[📞] Scheduling alert at: $testVideoCallTime');

        try {
          print('[🧪] Before scheduling');
          // await scheduleVideoCallNotification(
          //   title: 'Doctor Video Call',
          //   body: 'Your video call with the doctor starts in 5 minutes.',
          //   videoCallTime: videoCallTime,
          // );
          print('[✅] After scheduling');
        } catch (e) {
          print('[❌] Failed to schedule video call: $e');
        }

        print(
            '[DEBUG] Notification scheduled. Navigating to success screen...');
      } else {
        print('[❌] Booking failed or unexpected response: $responseData');
      }

      // Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(
      //       builder: (ctx) => SuccessScreen(
      //           serviceDetails: widget.serviceDetails,
      //           paymentId: widget.txnId.toString(),
      //           patient: widget.patient,
      //           mobileNumber: widget.mobileNumber,
      //           paymentType: "online"),
      //     ),
      //     (route) => false);

      // Navigator.pushReplacementNamed(context, '/thankyou');
    } else if (url.contains("failure")) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Payment Failed')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstname = widget.finalPayload.patientName ?? '';
    final email = widget.finalPayload.emailAddress ?? '';
    final phone = widget.finalPayload.mobileNumber ?? '';

    final postData =
        "key=$key&txnid=${widget.txnId}&amount=${widget.amount}&productinfo=$productInfo"
        "&firstname=$firstname&email=$email&phone=$phone"
        "&surl=$successUrl&furl=$failureUrl&hash=$hash";

    print("jshadjshdhjsd ${postData}");

    return Scaffold(
      appBar: CommonHeader(
        title: "PayU Payment",
      ),
      body: hash.isNotEmpty
          ? WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(
                  Uri.parse(widget.payuUrl),
                  method: LoadRequestMethod.post,
                  body: Uint8List.fromList(utf8.encode(postData)),
                  headers: {
                    "Content-Type": "application/x-www-form-urlencoded"
                  },
                )
                ..setNavigationDelegate(
                    NavigationDelegate(onPageStarted: _onNavigationChanged)),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
