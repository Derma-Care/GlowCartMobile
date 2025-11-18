import 'dart:async';
import 'dart:convert';

import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../APIs/BaseUrl.dart';
import '../BottomNavigation/BottomNavigation.dart';
import '../Utils/ScaffoldMessageSnacber.dart';
import '../verification/verficationmessage.dart';
import 'package:http/http.dart' as http;

class OTPController extends GetxController {
  final TextEditingController otpController = TextEditingController();

  late Timer timer;
  int start = 60;
  bool canResend = false;
  String otpCode = ""; // Store the OTP code entered
  bool isLoading = false; // To show loading indicator during verification
  int failedAttempts = 0;
  String? verificationId; // Add this field to store the verification ID

  @override
  void listenForCode() async {
    await SmsAutoFill().listenForCode();
  }

  @override
  void dispose() {
    timer.cancel(); // Clean up the timer
    super.dispose();
    SmsAutoFill().unregisterListener();
    otpController.dispose();
  }

  // OTP verification logic
  void verifyOtp(BuildContext context, String otpCode, String PhoneNumberstored,
      String username) {
    isLoading = true; // Show loading indicator

    // Send mobile number and OTP to the backend for verification
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        if (PhoneNumberstored != null) {
          // Replace this with your actual API endpoint
          final response = await http.post(
            Uri.parse('$baseUrl/verify-otp'),
            body: json.encode({
              'mobileNumber': PhoneNumberstored,
              'enteredOtp': otpCode,
            }),
            headers: {'Content-Type': 'application/json'},
          );
          final responseData = json.decode(response.body);
          print("response for send OTP ${response.body}");

          // Check for successful response
          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);
            print("$responseData");

            showSnackbar("Success", "${responseData['message']}", "success");

            if (responseData['registrationCompleted'] == false) {
              print(
                  "hgkjdhkjfhdkjgfdgfd${responseData['registrationCompleted']}");
              DialogHelper.showVerificationDialog(context);

              // Wait for 3 seconds before navigating

              isLoading = false; // Show loading indicator
              timer.cancel();

              await Future.delayed(const Duration(seconds: 3));
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/registerScreen",
                (Route<dynamic> route) => false, // Removes all previous routes
                arguments: [
                  username,
                  PhoneNumberstored,
                ], // Pass arguments
              );
            } else if (responseData['registrationCompleted'] == false) {
              print(
                  "registrationCompleted${responseData['registrationCompleted']}");
              DialogHelper.showVerificationDialog(context);

              isLoading = false; // Show loading indicator
              timer.cancel();

              await Future.delayed(const Duration(seconds: 3));
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/registerScreen",
                (Route<dynamic> route) => false, // Removes all previous routes
                arguments: [
                  username,
                  PhoneNumberstored,
                ], // Pass arguments
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => BottomNavController(
                    mobileNumber: PhoneNumberstored,
                    username: username,
                    index: 0,
                  ),
                ),
                (Route<dynamic> route) =>
                    false, // This will remove all previous routes
              );
            }
          } else {
            showSnackbar("Error", "${responseData['message']}", "error");

            isLoading = false;
            failedAttempts++;
            otpController.clear();

            if (response.statusCode == 400) {
              //  showSnackbar("Error", "${responseData['message']}", "error");
            } else {
              showSnackbar("Error",
                  "Failed to verify OTP. Please try again later", "error");
            }
          }
        }
      } catch (e) {
        showSnackbar("Error", "Server not responding", "error");

        print('Error verifying OTP: $e');

        isLoading = false;
      }
    });
  }

// Helper function to show error messages

  resendOtp(String PhoneNumberstored) async {
    try {
      isLoading = true;
      // Define the API URL
      String apiUrl = '$baseUrl/resend-otp';

      // Ensure the phone number is not null
      final phoneNumber = PhoneNumberstored ?? '';

      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'mobileNumber': phoneNumber, // Send the phone number as a parameter
        }),
      );

      print("response for Resend OTP ${response.body}");

      // Check if the API call was successful
      if (response.statusCode == 200) {
        showSnackbar("Success", "OTP resent to $phoneNumber", "success");

        // Clear the OTP input field

        otpCode = "";
        isLoading = false;

        // Restart the timer
      } else {
        // Show error message if the API call fails
        showSnackbar(
            "Error", "Failed to resend OTP. Please try again.", "error");

        isLoading = false;
      }
    } catch (e) {
      // Handle any errors
      showSnackbar("Error", "Error: $e", "error");

      isLoading = false;
    }
  }
}
