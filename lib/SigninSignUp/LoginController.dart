import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';
import 'package:cutomer_app/Clinic/AboutClinicController.dart';
import 'package:cutomer_app/OTP/FireBaseOtp.dart';

import 'package:cutomer_app/SigninSignUp/BiometricPermissionScreen.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/LocationService.dart';
import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
import 'package:cutomer_app/Widget/ControllerInitializer.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginService.dart';

class SiginSignUpController extends GetxController {
  var getOTPButton = "GET OTP".obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final LoginApiService _loginapiService = LoginApiService();
  final clinicController = Get.find<ClinicController>();

  bool agreeToTerms = true; // Initialize to false to require agreement
  String? phoneNumber;

  String? validatedata(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "Please enter your $fieldName";
    }
    if (value.length < 3) {
      return "$fieldName must be at least 3 characters long";
    }
    if (value.length > 20) {
      return "$fieldName must not exceed 20 characters";
    }

    // final alphabetRegex = RegExp(r"^[a-zA-Z\s]+$"); // Only letters & spaces
    // if (!alphabetRegex.hasMatch(value)) {
    //   return "Only alphabets are allowed in $fieldName";
    // }
    return null; // ✅ Valid input
  }

  String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "Please enter your $fieldName";
    }
    if (value.length < 1) {
      return "$fieldName must be at least 1 day long";
    }
    if (value.length > 3) {
      return "$fieldName must not exceed 2 number";
    }

    return null; // ✅ Valid input
  }

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your age";
    }

    final numericRegex = RegExp(r'^\d+$'); // Only digits
    if (!numericRegex.hasMatch(value)) {
      return "Age must be a number";
    }

    final age = int.tryParse(value);
    if (age == null || age <= 0) {
      return "Enter a valid age";
    }
    if (age > 120) {
      return "Age must be less than or equal to 120";
    }

    return null; // ✅ Valid
  }

  String? validateMobileNumber(String? value) {
    value = value?.trim();
    if (value == null || value.isEmpty) {
      return "Enter a valid mobile number";
    } else if (!GetUtils.isPhoneNumber(value)) {
      return "Enter a valid mobile number";
    } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return "Mobile number must start with 6-9";
    } else if (value.length != 10) {
      return "Mobile number must be exactly 10 digits long";
    }
    return null; // No error
  }

  void submitForm(BuildContext context) async {
    final fullname = "000101_CR_00005";
    final mobileNumber = mobileController.text.trim();

    if (formKey.currentState!.validate() && agreeToTerms) {
      getOTPButton.value = "Signing...";
      isLoading.value = true;

      await Future.delayed(const Duration(seconds: 2));

      try {
        String? token = await FirebaseMessaging.instance.getToken();

        final id = await FirebaseInstallations.instance.getId();
        final deviceid = await FirebaseInstallations.instance.getToken();
        print('Installation ID: $id');
        // FCM Token (used for sending push notifications)
        final fcmToken = await FirebaseMessaging.instance.getToken();

        print('FCM Token1: $fcmToken');
        print("FCM Token: $token");
        print("FCM deviceid: $deviceid");

        // Optional: Listen for token refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          print("Token refreshed: $newToken");
          // You could resend the token here if needed
        });
        final response = await _loginapiService.sendUserDataWithFCMToken(
            fullname, mobileNumber, token ?? "");

        if (response['status'] == 200) {
          getOTPButton.value = "SIGN IN";

          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('username', fullname);
          await prefs.setString('mobileNumber', mobileNumber);
          await prefs.setString('fcm', token ?? "");

          print("funmnmndhjshdhsa $token");
          final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
          final isFirstTimeAuthenticated =
              prefs.getBool('isFirstLoginDone') ?? true;

          print("isFirstTimeAuthenticated ${isFirstTimeAuthenticated}");

          // ✅ User is registered
          if (isFirstTimeAuthenticated) {
            showSnackbar("Success",
                "OTP has been sent successfully to $mobileNumber", "success");

            Get.offAll(() => OTPLoginScreen(
                  mobileNumber: mobileNumber,
                  fullname: fullname,
                  deviceId: token,
                ));
          } else {
            Get.to(() => EnableBiometricScreen(
                  mobileNumber: mobileNumber,
                  fullname: fullname,
                ));
          }
        }
      } catch (e) {
        print("Error during login: $e");
        getOTPButton.value = "SIGN IN";
      } finally {
        isLoading.value = false;
        getOTPButton.value = "SIGN IN";
      }
    }
  }

  void showFetchingLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false, // prevent closing dialog
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                    strokeWidth: 4,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Fetching your location...",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please ensure location services are enabled",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ✅ Request Location Permission & Get Current Location
}
