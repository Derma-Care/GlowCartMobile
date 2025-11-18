import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';
import 'package:cutomer_app/ConfirmBooking/Consultations.dart';
import 'package:cutomer_app/OTP/FireBaseOtp.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Needed import

class EnableBiometricScreen extends StatefulWidget {
  final mobileNumber;
  final fullname;
  final String? deviceId;

  const EnableBiometricScreen(
      {super.key, this.mobileNumber, this.fullname, this.deviceId});
  @override
  _EnableBiometricScreenState createState() => _EnableBiometricScreenState();
}

class _EnableBiometricScreenState extends State<EnableBiometricScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  // Future<void> enableBiometric() async {
  //   bool canCheck = await auth.canCheckBiometrics;
  //   if (canCheck) {
  //     Get.to(ConsultationsType(
  //       mobileNumber: widget.mobileNumber,
  //       username: widget.fullname ?? '',
  //     ));
  //   } else {
  //     Get.snackbar("Error", "Biometric not available");
  //   }
  // }

  Future<void> _authenticate() async {
    try {
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to enable biometrics',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isFirstLoginDone', true); // ✅ Store first login
        await prefs.setBool(
            'isAuthenticated', true); // ✅ Store biometric enabled

        // ✅ Show success and navigate or close screen

        showSnackbar("Success", "Biometric authentication enabled", "success");
        Get.offAll(BottomNavController(
          mobileNumber: widget.mobileNumber,
          username: widget.fullname,
          index: 0,
        ));

        // Navigator.pop(context); // Or navigate to home/dashboard
      }
    } catch (e) {
      print("Biometric auth error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            Column(
              children: [
                Text(
                  "Enable Biometrics",
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Secure your account with biometric access",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 40),
                // Icon(Icons.fingerprint, size: 120, color: Colors.blueAccent),
                Image.asset(
                  'assets/fin.gif',
                  height: 120,
                  width: 120,
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: mainColor),
                        foregroundColor: Colors.limeAccent,
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isFirstLoginDone', true);
                        await prefs.setBool('isAuthenticated', false);
                        // Get.to(ConsultationsType(
                        //   mobileNumber: widget.mobileNumber,
                        //   username: widget.fullname ?? '',
                        // ));
                        Get.offAll(BottomNavController(
                          mobileNumber: widget.mobileNumber,
                          username: widget.fullname,
                          index: 0,
                        ));
                      },
                      child: Text("Skip", style: TextStyle(color: mainColor)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _authenticate,
                      child: Text(
                        "Allow",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
