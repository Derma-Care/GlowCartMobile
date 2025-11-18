// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:local_auth/local_auth.dart';

// import '../BottomNavigation/BottomNavigation.dart';
// import '../ConfirmBooking/Consultations.dart';

 
// class BiometricAuthScreen extends StatefulWidget {
//   BiometricAuthScreen();
//   @override
//   _BiometricAuthScreenState createState() => _BiometricAuthScreenState();
// }

// class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
//   final LocalAuthentication auth = LocalAuthentication();
//   bool _isAuthenticated = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkBiometrics();
//   }

//   Future<void> saveAuthStatus(bool status) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isAuthenticated', status);
//   }

//   Future<bool> getAuthStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('isAuthenticated') ?? false;
//   }

//   Future<void> _checkBiometrics() async {
//     bool canCheckBiometrics = await auth.canCheckBiometrics;
//     if (canCheckBiometrics) {
//       _authenticate();
//     }
//   }

//   Future<void> _authenticate() async {
//     try {
//       print("Starting authentication...");
//       bool isAuthenticated = await auth.authenticate(
//         localizedReason: 'Please authenticate to proceed',
//         options: const AuthenticationOptions(
//           useErrorDialogs: true,
//           stickyAuth: true,
//         ),
//       );
//       print("Authentication status: $isAuthenticated");

//       if (isAuthenticated) {
//         final prefs = await SharedPreferences.getInstance();
//         final username = prefs.getString('username');
//         final mobileNumber = prefs.getString('mobileNumber');

//         // ✅ Navigate to the actual app screen
//         // Get.offAll(BottomNavController(
//         //   mobileNumber: mobileNumber!,
//         //   username: username!,
//         //   index: 0,
//         // ));
//         Get.offAll(ConsultationsType(
//           mobileNumber: mobileNumber!,
//           username: username!,
//         ));
//       } else {
//         print("Authentication failed or was canceled by the user.");
//       }
//     } catch (e) {
//       print("Authentication error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.teal.shade700, Colors.blue.shade900],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: 20),
//             Column(
//               children: [
//                 Text(
//                   "Powered by",
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white70, // Subtle color for branding
//                     letterSpacing: 1.2,
//                   ),
//                 ),
//                 Text(
//                   "Cheislon Technologies",
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     letterSpacing: 1.5,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 40),
//             Icon(
//               Icons.lock_outline_rounded,
//               size: 80,
//               color: Colors.white,
//             ),
//             SizedBox(height: 20),
//             Text(
//               "Secure Access",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             SizedBox(height: 10),
//             Text(
//               "Authenticate to continue",
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.white70,
//               ),
//             ),
//             SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: _authenticate,
//               icon: Icon(Icons.fingerprint, size: 24),
//               label: Text(
//                 "Authenticate",
//                 style: TextStyle(fontSize: 18),
//               ),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.teal,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
