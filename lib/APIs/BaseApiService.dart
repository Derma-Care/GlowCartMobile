// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

// class BaseApiService extends GetConnect {
//   @override
//   void onInit() {
//     httpClient.timeout = const Duration(seconds: 10);

//     /// ✅ Add Global Request Interceptor
//     httpClient.addRequestModifier<void>((request) async {
//       // Check Internet before every API call
//       var connectivityResult = await Connectivity().checkConnectivity();
//       if (connectivityResult == ConnectivityResult.none) {
//         Get.to(() => const NoInternetScreen());
//         // Cancel request
//         throw Exception('No Internet');
//       }

//       // Optionally add headers like auth token
//       request.headers['Content-Type'] = 'application/json';
//       return request;
//     });

//     /// ✅ Add Global Response Interceptor
//     httpClient.addResponseModifier((request, response) {
//       if (response.statusCode == 401 || response.statusCode == 403) {
//         Get.offAll(() => const SessionExpiredScreen());
//       } else if (response.statusCode == 500 ||
//           response.statusCode == 502 ||
//           response.statusCode == 503) {
//         Get.to(() => const ServerDownScreen());
//       }
//       return response;
//     });

//     /// ✅ Add Global Error Interceptor
//     httpClient.addResponseModifier((request, response) {
//       if (response.status.connectionError) {
//         Get.to(() => const NoInternetScreen());
//       }
//       return response;
//     });

//     super.onInit();
//   }
// }

// class NoInternetScreen extends StatelessWidget {
//   const NoInternetScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.wifi_off, size: 80, color: Colors.red),
//             const SizedBox(height: 16),
//             const Text("No Internet Connection",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 final result = await Connectivity().checkConnectivity();
//                 if (result != ConnectivityResult.none) {
//                   Get.back(); // Return to previous screen
//                 }
//               },
//               child: const Text("Retry"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ServerDownScreen extends StatelessWidget {
//   const ServerDownScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.cloud_off, size: 80, color: Colors.orange),
//             const SizedBox(height: 16),
//             const Text("Server Down, please try later",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => Get.back(),
//               child: const Text("Try Again"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SessionExpiredScreen extends StatelessWidget {
//   const SessionExpiredScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
//             const SizedBox(height: 16),
//             const Text("Session Expired",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 Get.offAllNamed('/login');
//               },
//               child: const Text("Login Again"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
