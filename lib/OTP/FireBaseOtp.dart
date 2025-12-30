import 'dart:async';
import 'dart:convert';
import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';
import 'package:cutomer_app/Registration/RegisterScreen.dart';
import 'package:cutomer_app/SigninSignUp/BiometricPermissionScreen.dart';
import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/Constant.dart';
import '../Utils/CopyRigths.dart';
import '../ConfirmBooking/Consultations.dart';
import '../SigninSignUp/LoginScreen.dart';
import '../Utils/Header.dart'; // Your CommonHeader widget
import '../APIs/BaseUrl.dart'; // where your `registerUrl` is defined

class OTPLoginScreen extends StatefulWidget {
  final String mobileNumber;
  final String? fullname;
  final String? deviceId;

  const OTPLoginScreen({
    super.key,
    required this.mobileNumber,
    this.fullname,
    this.deviceId,
  });

  @override
  _OTPLoginScreenState createState() => _OTPLoginScreenState();
}

class _OTPLoginScreenState extends State<OTPLoginScreen> {
  final TextEditingController otpController = TextEditingController();
  String verificationId = '';
  bool codeSent = false;
  bool isLoading = false;
  bool canResend = false;
  int timerSeconds = 60;
  int failedAttempts = 0;
  Timer? _timer;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    sendOTP();
    startTimer();
  }

  void startTimer() {
    canResend = false;
    timerSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timerSeconds > 0) {
          timerSeconds--;
        } else {
          canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> sendOTP() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91${widget.mobileNumber}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        print("Auto-verified");
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: ${e.message}");
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          codeSent = true;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  //resend otp

  Future<void> resendOtp(String mobileNumber, String deviceId) async {
    print("Resend Otpn: ${deviceId}");
    print("~ ${mobileNumber}");
    final url = Uri.parse('$registerUrl/resendOtp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'mobileNumber': mobileNumber,
          'deviceId': deviceId,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        print('OTP resent successfully');
        // You can show a success message
      } else {
        print('Failed to resend OTP: ${responseData['message']}');
        // Show error message from backend
      }
    } catch (e) {
      print('Error resending OTP: $e');
      // Handle network error
    }
  }

  //verfy oTP
  Future<void> verifyOTP(String otp) async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$registerUrl/verifyOtp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "mobileNumber": widget.mobileNumber,
          "otp": otp,
        }),
      );

      print("otps: ${widget.mobileNumber}, ${otp}");

      final responseData = json.decode(response.body);
      print("otps: ${responseData}");

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Now check if user exists in your database
        final checkUserResponse = await http.get(
          Uri.parse('$registerUrl/getBasicDetails/${widget.mobileNumber}'),
        );
        final prefs = await SharedPreferences.getInstance();
        final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
        await prefs.setBool('isFirstLoginDone', true);

        final token = prefs.getString('fcm');
        if (checkUserResponse.statusCode == 200) {
          final data = json.decode(checkUserResponse.body);
          if (data['success'] == true && data['data'] != null) {
            final isFirstTimeAuthenticated =
                prefs.getBool('isFirstLoginDone') ?? true;

            if (isAuthenticated && isFirstTimeAuthenticated) {
              showSnackbar(
                  "Success",
                  "OTP has been sent successfully to ${widget.mobileNumber}",
                  "success");

              Get.offAll(() => BottomNavController(
                    mobileNumber: widget.mobileNumber,
                    username: widget.fullname ?? '',
                    index: 0,
                  ));
            } else {
              Get.to(() => EnableBiometricScreen(
                  mobileNumber: widget.mobileNumber,
                  fullname: widget.fullname ?? '',
                  deviceId: token));
            }
          } else {
            Get.offAll(() => BottomNavController(
                  mobileNumber: widget.mobileNumber,
                  username: widget.fullname ?? '',
                  index: 0,
                ));
          }
        } else {
          Get.offAll(() => BottomNavController(
                mobileNumber: widget.mobileNumber,
                username: widget.fullname ?? '',
                index: 0,
              ));
        }

        showSnackbar("Success", "Login successful", "success");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Login successful")),
        // );
      } else {
        showSnackbar(
            "Error", "${responseData['message'] ?? 'Invalid OTP'}", "error");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(responseData['message'] ?? 'Invalid OTP')),
        // );
      }
    } catch (e) {
      showSnackbar("Error", "Something went wrong: $e", "error");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Something went wrong: $e")),
      // );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonHeader(title: 'Verify Phone Number'),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                Image.asset('assets/ic_launcher.png', width: 120),
                SizedBox(height: 24),
                Text(
                  "Enter the OTP sent to +91-${widget.mobileNumber}",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Pinput(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  length: 6,
                  onCompleted: verifyOTP,
                  defaultPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '00:${timerSeconds.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: failedAttempts >= 2
                      ? () => Get.toNamed('/gethelp')
                      : (canResend
                          ? () {
                              // sendOTP();
                              resendOtp(widget.mobileNumber, widget.deviceId!);
                              startTimer();
                            }
                          : null),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: failedAttempts >= 2
                              ? "You have made 2 unsuccessful attempts. "
                              : "Didn't receive OTP? Resend ",
                          style: TextStyle(
                            color: (canResend || failedAttempts >= 2)
                                ? Colors.red
                                : Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        if (failedAttempts >= 2)
                          TextSpan(
                            text: "Get Help",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (isLoading) ...[
                  SizedBox(height: 10),
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 5),
                  Text(
                    "Validating OTP...",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
                TextButton(
                  onPressed: () => Get.to(Loginscreen()),
                  child: Text(
                    'Change Mobile Number',
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Copyrights(),
              ],
            ),
          ),
        )
        // : Center(child: CircularProgressIndicator()),
        );
  }
}
