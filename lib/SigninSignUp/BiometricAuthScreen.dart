import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/Clinic/AboutClinicController.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/DoctorService.dart';
import 'package:cutomer_app/Firebase/RequestNotificationPermissions.dart';
import 'package:cutomer_app/SigninSignUp/LoginController.dart';
import 'package:cutomer_app/SigninSignUp/LoginService.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/LocationService.dart';
import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
import 'package:cutomer_app/Widget/ControllerInitializer.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../BottomNavigation/BottomNavigation.dart';
import '../SigninSignUp/LoginScreen.dart';
import 'package:http/http.dart' as http;

class BiometricAuthScreen extends StatefulWidget {
  @override
  _BiometricAuthScreenState createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final SiginSignUpController siginSignUpController = SiginSignUpController();
  final LoginApiService _loginApiService = LoginApiService();
  final DoctorService _doctorService = DoctorService();
  final clinicController = Get.find<ClinicController>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    requestFCMPermission();
    getFCMToken();
  }

  /// ✅ Navigate safely to login screen
  void _goToLogin() {
    if (Navigator.canPop(context))
      Navigator.pop(context); // close dialogs if open
    Get.offAll(() => Loginscreen());
  }

  Future<void> _checkBiometrics() async {
    setState(() => _isLoading = true);
    try {
      final canCheckBiometrics = await auth.canCheckBiometrics;
      if (canCheckBiometrics) {
        await _authenticate();
      } else {
        debugPrint("❌ Device doesn't support biometrics.");
        _goToLogin();
      }
    } catch (e) {
      debugPrint("❌ Error checking biometrics: $e");
      _goToLogin();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _authenticate() async {
    setState(() => _isLoading = true);
    try {
      final isAuthenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to proceed',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (!isAuthenticated) {
        debugPrint("❌ Authentication failed.");
        _goToLogin();
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customerId');
      final username = prefs.getString('userName');
      final mobileNumber = prefs.getString('mobileNumber');
      final isAuthenticate = prefs.getBool('isAuthenticated') ?? false;
      final isFirstLoginDone = prefs.getBool('isFirstLoginDone') ?? false;
      final fullname = prefs.getString('customerName');
      debugPrint("🔐 Biometric Authenticated: $isAuthenticated");
      debugPrint("📦 Username: $username");
      debugPrint("📦 Mobile Number: $mobileNumber");
      debugPrint("✅ First Login Completed: $isFirstLoginDone");

      // ✅ Validate stored data
      if (!isAuthenticate || !isFirstLoginDone) {
        debugPrint("❌ Missing user data. Redirecting to login.");
        _goToLogin();
        return;
      }

      final checkCustomerResponse = await http.get(
        Uri.parse('$clinicUrl/customers/$customerId'),
      );
      debugPrint("✅ API Responsed: ${checkCustomerResponse.body}");
      debugPrint("✅ API Responsed url: ${clinicUrl}/customers/${customerId}");
      if (checkCustomerResponse.statusCode != 200) {
        debugPrint("❌ Server Error: ${checkCustomerResponse.statusCode}");
        _goToLogin();
        return;
      }

      final data = json.decode(checkCustomerResponse.body);
      debugPrint("✅ API Response: $data");

      if (data['success'] != true) {
        showSnackbar(
            "Warning", "No user data found. Please log in again.", "warning");
        _goToLogin();
        return;
      }

      // ✅ Show loading dialog and fetch location
      showFetchingLocationDialog(context);
      try {
        await LocationService.fetchAndStoreLocation();
      } catch (e) {
        debugPrint("⚠️ Location fetch failed: $e");
      } finally {
        Navigator.pop(context); // close dialog safely
      }
      initializeControllers();

      final hospitalId = prefs.getString('hospitalId');
      await clinicController.fetchClinic(hospitalId!);
      // ✅ Navigate to bottom navigation
      Get.offAll(() => BottomNavController(
            mobileNumber: mobileNumber!,
            username: fullname!,
            index: 0,
          ));
    } catch (e) {
      debugPrint("❌ Biometric authentication error: $e");
      _goToLogin();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void showFetchingLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false,
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
                  const Text(
                    "Fetching your location...",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please ensure location services are enabled",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [mainColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: _isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    SizedBox(height: 20),
                    Text("Authenticating...",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        size: 80, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text("Secure Access",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 10),
                    const Text("Authenticate to continue",
                        style: TextStyle(fontSize: 16, color: Colors.white70)),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _authenticate,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text("Authenticate"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
