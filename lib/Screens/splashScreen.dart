// import 'dart:async';
// import 'dart:io';
// import 'package:cutomer_app/SigninSignUp/BiometricAuthScreen.dart';
// import 'package:cutomer_app/SigninSignUp/LoginScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:get/get.dart';
// import 'package:open_settings_plus/open_settings_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:local_auth/local_auth.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   bool _noInternet = false;
//   bool _animateLogo = false;
//   double _logoOpacity = 1.0;
//   double _backgroundOpacity = 1.0;

//   late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
//   final LocalAuthentication auth = LocalAuthentication();

//   @override
//   void initState() {
//     super.initState();
//     _checkInternetAndInitialize();

//     _connectivitySubscription = Connectivity()
//         .onConnectivityChanged
//         .listen((List<ConnectivityResult> results) {
//       _handleConnectivityChange(results.first);
//     });
//   }

//   @override
//   void dispose() {
//     _connectivitySubscription.cancel();
//     super.dispose();
//   }

//   /// ✅ Navigation Logic
//   Future<void> _navigateNext() async {
//     print("calling _navigateNext");
//     final prefs = await SharedPreferences.getInstance();
//     final isFirstLoginDone = prefs.getBool('isFirstLoginDone') ?? false;

//     bool canCheckBiometrics = await auth.canCheckBiometrics;
//     bool isDeviceSupported = await auth.isDeviceSupported();
//     bool biometricAvailable = false;

//     if (canCheckBiometrics && isDeviceSupported) {
//       final availableBiometrics = await auth.getAvailableBiometrics();
//       biometricAvailable = availableBiometrics.isNotEmpty;
//     }

//     if (!mounted) return;

//     if (!isFirstLoginDone) {
//       print("DEBUG: Navigating to LoginScreen");
//       Get.offAll(() => Loginscreen(),
//           transition: Transition.fadeIn,
//           duration: const Duration(milliseconds: 400));
//     } else if (biometricAvailable) {
//       print("DEBUG: Navigating to BiometricAuthScreen");
//       Get.offAll(() => BiometricAuthScreen(),
//           transition: Transition.fadeIn,
//           duration: const Duration(milliseconds: 400));
//     } else {
//       print("DEBUG: Navigating to LoginScreen (fallback)");
//       Get.offAll(() => Loginscreen(),
//           transition: Transition.fadeIn,
//           duration: const Duration(milliseconds: 400));
//     }
//   }

//   /// ✅ Checks connectivity and triggers animation
//   Future<void> _checkInternetAndInitialize() async {
//     var connectivityResult = await Connectivity().checkConnectivity();
//     _handleConnectivityChange(connectivityResult as ConnectivityResult);
//   }

//   void _handleConnectivityChange(ConnectivityResult result) {
//     if (result == ConnectivityResult.none) {
//       setState(() => _noInternet = true);
//     } else {
//       setState(() => _noInternet = false);

//       // Trigger animations after small delay
//       Future.delayed(const Duration(seconds: 1), () {
//         if (!mounted) return;
//         setState(() {
//           _animateLogo = true;
//           // keep visible instead of disappearing
//           _logoOpacity = 1.0;
//           _backgroundOpacity = 0.0;
//         });
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           AnimatedOpacity(
//             opacity: _backgroundOpacity,
//             duration: const Duration(seconds: 1),
//             curve: Curves.easeOut,
//             child: Container(
//               width: double.infinity,
//               height: double.infinity,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color.fromARGB(255, 238, 221, 214),
//                     Color.fromARGB(255, 192, 99, 82),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//             ),
//           ),
//           if (_noInternet)
//             _buildNoInternetWidget()
//           else
//             AnimatedAlign(
//               alignment:
//                   _animateLogo ? const Alignment(0.0, -0.75) : Alignment.center,
//               duration: const Duration(seconds: 1),
//               curve: Curves.easeOut,
//               child: AnimatedOpacity(
//                 opacity: _logoOpacity,
//                 duration: const Duration(seconds: 1),
//                 curve: Curves.easeOut,
//                 onEnd: () {
//                   // ✅ Navigate only after animation finishes
//                   if (_animateLogo) {
//                     _navigateNext();
//                   }
//                 },
//                 child: Image.asset(
//                   'assets/ic_launcher.png',
//                   height: 150,
//                 ),
//               ),
//             ),
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Text(
//                 "Dermatology center",
//                 style: const TextStyle(fontSize: 18, color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// ✅ No Internet Widget
//   Widget _buildNoInternetWidget() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.white.withOpacity(0.95),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset('assets/wifi.gif', width: 100, height: 100),
//           const SizedBox(height: 20),
//           const Text(
//             'No Internet Connection',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           const Text(
//             'Please check your connection and try again.',
//             style: TextStyle(fontSize: 16, color: Colors.black54),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 30),
//           ElevatedButton(
//             onPressed: _checkInternetAndInitialize,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.teal,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Retry'),
//           ),
//           const SizedBox(height: 40),
//           _buildNetworkSettingsCard(
//             icon: Icons.wifi,
//             title: 'Wi-Fi Settings',
//             onTap: () {
//               if (Platform.isAndroid) {
//                 (OpenSettingsPlus.shared as OpenSettingsPlusAndroid).wifi();
//               } else if (Platform.isIOS) {
//                 (OpenSettingsPlus.shared as OpenSettingsPlusIOS).wifi();
//               }
//             },
//           ),
//           const SizedBox(height: 20),
//           _buildNetworkSettingsCard(
//             icon: Icons.network_cell,
//             title: 'Mobile Data Settings',
//             onTap: () {
//               if (Platform.isAndroid) {
//                 (OpenSettingsPlus.shared as OpenSettingsPlusAndroid)
//                     .dataRoaming();
//               } else if (Platform.isIOS) {
//                 (OpenSettingsPlus.shared as OpenSettingsPlusIOS).wifi();
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNetworkSettingsCard({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       color: Colors.white,
//       child: InkWell(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Icon(icon, color: Colors.blue),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.blueAccent,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:cutomer_app/SigninSignUp/BiometricAuthScreen.dart';
import 'package:cutomer_app/SigninSignUp/LoginScreen.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _moveUpAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // faster
    );

    // Fade out
    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Move up (y-axis) more
    _moveUpAnimation = Tween<double>(begin: 0, end: -200).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Wait 2 seconds before starting the animation
    Future.delayed(const Duration(seconds: 2), () {
      _controller.forward();
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateNext();
      }
    });
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLoginDone = prefs.getBool('isFirstLoginDone') ?? false;

    bool canCheckBiometrics = false;
    bool isDeviceSupported = false;
    bool biometricAvailable = false;

    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
      isDeviceSupported = await auth.isDeviceSupported();
      if (canCheckBiometrics && isDeviceSupported) {
        final availableBiometrics = await auth.getAvailableBiometrics();
        biometricAvailable = availableBiometrics.isNotEmpty;
      }
    } catch (e) {
      print("Biometric check failed: $e");
    }

    if (!mounted) return;

    if (!isFirstLoginDone) {
      Get.offAll(() => Loginscreen());
    } else if (biometricAvailable) {
      Get.offAll(() => BiometricAuthScreen());
    } else {
      Get.offAll(() => Loginscreen());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _moveUpAnimation.value),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Prevents Column from taking full height
            mainAxisAlignment:
                MainAxisAlignment.center, // Centers content vertically
            children: [
              Image.asset(
                'assets/ic_launcher.png',
                height: 150,
              ),
              const SizedBox(
                  height: 16), // Adds some spacing between image and text
              Text(
                "Neha's GlowKart",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                    fontSize: 24),
              )
            ],
          ),
        ),
      ),
    );
  }
}
