import 'dart:convert';

import 'package:cutomer_app/BottomNavigation/Appoinments/PostBooingModel.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:cutomer_app/Loading/FullScreeenLoader.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
import 'package:cutomer_app/Widget/GobelTimer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Booings/BooingService.dart';
import '../PatientsDetails/PatientModel.dart';
import '../Screens/BookingSuccess.dart';
import '../Utils/ScaffoldMessageSnacber.dart';

class RazorpaySubscription extends StatefulWidget {
  final VoidCallback? onPaymentInitiated;
  final HospitalDoctorModel serviceDetails;
  final String amount;
  final String mobileNumber;
  final String branchName;
  final BuildContext context;
  final PatientModel patient;
  final PostBookingModel bookingDetails;

  const RazorpaySubscription({
    super.key,
    required this.onPaymentInitiated,
    required this.serviceDetails,
    required this.amount,
    required this.context,
    required this.patient,
    required this.bookingDetails,
    required this.mobileNumber,
    required this.branchName,
  });

  @override
  State<RazorpaySubscription> createState() => _RazorpaySubscriptionState();
}

class _RazorpaySubscriptionState extends State<RazorpaySubscription> {
  var _razorpay = Razorpay();
  Map<String, dynamic> options = {};
  bool _isLoading = true; // To manage loading state
  late String? paymentId;
  @override
  void initState() {
    super.initState();
    print("PayAmount to be customer ${widget.amount}");
    // handleBookAppoint();
    // Payment options
    options = {
      'key': 'rzp_test_sor33NEn9vHr3Q',
      'amount': (double.parse(widget.amount) * 100).toInt(), // Amount in paise

      'name': 'Derma Care',
      'description': 'Service Charges',
      'prefill': {
        'contact': '7842259803',
        'email': 'prashanthr803@gmail.com',
      },
    };

    // Razorpay event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Start payment process
    if (widget.onPaymentInitiated != null) {
      widget.onPaymentInitiated!();
      Future.delayed(Duration.zero, () {
        _razorpay.open(options);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: "Payment Gateway",
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Your main content here
                Center(
                  child: Text(
                    "Payment Details Here",
                    style: TextStyle(fontSize: 18),
                  ),
                ),

                // Timer FAB
                GlobalTimerFAB(
                  doctorId: widget.serviceDetails.doctor.doctorId,
                  slot: widget.bookingDetails.patient.servicetime,
                ),
              ],
            ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing
      builder: (_) => FullscreenLoader(
        message: "Processing Booking...",
        logoPath: "assets/ic_launcher.png", // Provide your app logo path
      ),
    );
    setState(() {
      _isLoading = false;
    });

    showSnackbar(
        "Success", "Payment Successful: ${response.paymentId}", "success");
    paymentId = response.paymentId;
    print("Payment Successful: ${response.paymentId}");
    print("Payment Successful: ${response.orderId}");
    print("Payment Successful: ${response.data}");
    print("Payment Successful: ${response.signature}");

    print("Booking Payload: ${jsonEncode(widget.bookingDetails)}");

    var responseData = await postBookings(widget.bookingDetails);

    print('[DEBUG] Response Data: $responseData');

    if (responseData!['statusCode'] == 201 && responseData['data'] != null) {
      print('[DEBUG] Inside if block');

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (ctx) => SuccessScreen(
              serviceDetails: widget.serviceDetails,
              paymentId: paymentId.toString(),
              patient: widget.patient,
              mobileNumber: widget.mobileNumber,
              paymentType: "online",
              clinicData: widget.serviceDetails,
              branchName: widget.branchName,
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

      print('[DEBUG] Notification scheduled. Navigating to success screen...');
    } else {
      print('[❌] Booking failed or unexpected response: $responseData');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isLoading = false;
    });

    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      ScaffoldMessageSnackbar.show(
        context: context, // Use the new context from builder
        message: "Payment Cancelled by User",
        type: SnackbarType.warning,
        durationInSeconds: 5,
      );
      // Fluttertoast.showToast(msg: "Payment Cancelled by User");

      Navigator.pop(context);

      // (route) => false,

      print("User cancelled the payment.");
    } else {
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Payment Failed: ${response.message}",
        type: SnackbarType.error,
      );
      print("Payment Failed: ${response.message}");
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessageSnackbar.show(
      context: context,
      message: "External Wallet Selected: ${response.walletName}",
      type: SnackbarType.success,
    );
    print("External Wallet Selected: ${response.walletName}");
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clear the Razorpay instance
    super.dispose();
  }
}

// =================PhonePay==============

// import 'dart:convert' show base64Encode, jsonEncode, utf8;
// import 'dart:developer';

// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';

// import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

// import '../Doctors/ListOfDoctors/DoctorModel.dart';
// import '../PatientsDetails/PatientModel.dart';

// class PhonepePg {
//   final VoidCallback? onPaymentInitiated;
//   final HospitalDoctorModel serviceDetails;
//   final String amount;
//   final BuildContext context;
//   final Patientmodel patient;

//   PhonepePg({
//     required this.context,
//     required this.amount,
//     required this.onPaymentInitiated,
//     required this.serviceDetails,
//     required this.patient,
//   });

//   final String merchantId = "PGTESTPAYUAT";
//   final String salt = "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
//   final int saltIndex = 1;
//   final String callbackURL = "https://www.webhook.site/callback-url";
//   final String apiEndPoint = "/pg/v1/pay";

//   Future<void> initSDK() async {
//     try {
//       bool? result =
//           await PhonePePaymentSdk.init("SANDBOX", null, merchantId, true);
//       startTransaction();
//       log("📲 PhonePe SDK Initialized: $result");
//     } catch (e) {
//       log("❌ SDK Init Failed: $e");
//     }
//   }

//   Future<void> startTransaction() async {
//     final transactionId = "TXN${DateTime.now().millisecondsSinceEpoch}";

//     Map<String, dynamic> body = {
//       "merchantId": merchantId,
//       "merchantTransactionId": transactionId,
//       "merchantUserId": "user123", // Dynamic user
//       "amount": amount * 100, // in paise
//       "callbackUrl": callbackURL,
//       "mobileNumber": "7842259803", // Dynamic user
//       "paymentInstrument": {"type": "PAY_PAGE"},
//     };

//     log("🔄 Request Body: $body");

//     String bodyEncoded = base64Encode(utf8.encode(jsonEncode(body)));
//     var byteCodes = utf8.encode(bodyEncoded + apiEndPoint + salt);
//     String checksum = "${sha256.convert(byteCodes)}###$saltIndex";

//     try {
//       var response = await PhonePePaymentSdk.startTransaction(
//         bodyEncoded,
//         callbackURL,
//         checksum,
//         "",
//       );

//       log("✅ SDK Response: $response");

//       if (response is Map && response.containsKey("status")) {
//         final status = response["status"];
//         if (status == "SUCCESS") {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Payment successful")),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Payment failed: ${response["error"]}")),
//           );
//           print("Payment failed: ${response["error"]}");
//         }
//       }
//     } catch (e) {
//       log("❌ Payment Error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Transaction failed: $e")),
//       );
//     }
//   }
// }
