import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pinput/pinput.dart';
import '../Utils/Constant.dart';
import '../Utils/CopyRigths.dart';
import 'OTPController.dart';

class Otpscreencustomer extends StatefulWidget {
  final String PhoneNumberstored;
  final String username;
  const Otpscreencustomer({
    super.key,
    required this.PhoneNumberstored,
    required this.username,
  });

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<Otpscreencustomer> {
  OTPController otpController = OTPController();
  void initState() {
    super.initState();
    startTimer(); // Start the timer
    otpController.listenForCode();
  }

  void startTimer() {
    otpController.start = 60; // Reset timer to 30 seconds
    otpController.canResend = false; // Disable resend button initially

    otpController.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (otpController.start > 0) {
          otpController.start--;
        } else {
          otpController.canResend =
              true; // Enable resend button after countdown
          timer.cancel(); // Stop the timer
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
            ),
            ClipRRect(
              child: Image.asset(
                'assets/surecare_launcher.png', // Ensure this path is correct
                width: 150,

                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'OTP',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  // Space for the image
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'We have sent you an OTP to your mobile number. Please check your messages and enter the OTP to proceed.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                            height: 1.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  //   text messages with phone_number
                  Padding(
                    padding: const EdgeInsets.only(left: 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'A 6 digit code has been sent to ${widget.PhoneNumberstored}',
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // Pinput for OTP input  think 6 boxes
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Pinput(
                      controller: otpController.otpController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      autofocus: true,
                      length: 6,
                      onChanged: (value) {
                        setState(() {
                          otpController.otpCode = value;
                        });
                      },
                      onCompleted: (pin) {
                        // Verify OTP when completed
                        otpController.verifyOtp(context, pin,
                            widget.PhoneNumberstored, widget.username);
                      },
                      defaultPinTheme: PinTheme(
                        width: 50,
                        height: 50,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          // Change border color to a darker shade
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 50,
                        height: 50,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20.0),
                  Text(
                    '00:${otpController.start.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: mainColor),
                  ),

                  //this section includes 3 otp try error message UI
                  const SizedBox(height: 10.0),
                  TextButton(
                    onPressed: otpController.failedAttempts >= 2
                        ? () {
                            // Navigate to Get Help screen when clicked
                            Navigator.pushReplacementNamed(context, '/gethelp');
                          }
                        : (otpController.canResend
                            ? () {
                                otpController
                                    .resendOtp(widget.PhoneNumberstored);
                                startTimer();
                              }
                            : null), // Resend button logic
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: otpController.failedAttempts >= 2
                                  ? "You have made '2' unsuccessful attempts. Need assistance? "
                                  : "Didn't receive OTP? Resend ",
                              style: TextStyle(
                                fontSize: 16.0,
                                color: otpController.canResend ||
                                        otpController.failedAttempts >= 2
                                    ? const Color.fromARGB(255, 255, 0, 0)
                                    : Colors.grey,
                              ),
                            ),
                            if (otpController.failedAttempts >= 2)
                              TextSpan(
                                text: " Get Help",
                                style: const TextStyle(
                                  height: 1.5,
                                  fontSize: 20.0,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Navigate to help page
                                    Navigator.pushReplacementNamed(
                                        context, '/gethelp');
                                  },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (otpController.isLoading)
                    Column(
                      children: [
                        SpinKitWave(
                          color: Colors.green, // Use a static color
                          size: 20.0, // Adjust size as needed
                        ),
                        Text(
                          "Validating OTP...",
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Navigate back
                    },
                    child: const Text(
                      'Change Mobile Number',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.0,
                        color: mainColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize
                    .min, // Ensures the column takes minimal vertical space
                children: [
                  if (otpController.isLoading)
                    const CircularProgressIndicator(), // Show loader if loading
                  if (!otpController.isLoading) Copyrights()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
