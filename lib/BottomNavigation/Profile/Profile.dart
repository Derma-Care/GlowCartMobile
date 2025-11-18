import 'dart:convert';

import 'package:cutomer_app/BottomNavigation/Appoinments/PostBooingModel.dart';
import 'package:cutomer_app/BottomNavigation/Profile/ProfileScreens.dart';
import 'package:cutomer_app/Clinic/AboutClinic.dart';
import 'package:cutomer_app/Customers/GetCustomerModel.dart';
import 'package:cutomer_app/Dashboard/DashBoardController.dart';
import 'package:cutomer_app/Dashboard/GetCustomerData.dart';
import 'package:cutomer_app/Reports/CostomerReports.dart';
import 'package:cutomer_app/UserManuval/AppointmentManual.dart';
import 'package:cutomer_app/UserManuval/UserManual.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Doctors/ListOfDoctors/DoctorModel.dart';
import '../../Terms/TermsAndConditionsScreen.dart';

class CustomerProfilePage extends StatefulWidget {
  final String mobileNumber;
  const CustomerProfilePage({
    super.key,
    required this.mobileNumber,
  });

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // clear session
    // ✅ Clear all GetX controllers from memory
    // Get.deleteAll();

    Get.offAllNamed('/login'); // or use Get.offAll(() => Loginscreen());
  }

  final dashboardcontroller = Get.put(Dashboardcontroller());
  @override
  String? customerId;
  String? hospitalId;

  @override
  void initState() {
    super.initState();
    getCustomerId();
    _loadBiometricSetting();
  }

  final LocalAuthentication auth = LocalAuthentication();
  bool _biometricEnabled = false;
  bool _loading = true;

  Future<void> _loadBiometricSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricEnabled = prefs.getBool('isAuthenticated') ?? false;
      _loading = false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // User wants to enable biometrics → ask for authentication
      try {
        bool canCheck = await auth.canCheckBiometrics;
        if (!canCheck) {
          ScaffoldMessageSnackbar.show(
            context: context,
            message: "Biometrics not available",
            type: SnackbarType.error,
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text("Biometrics not available")),
          // );
          return;
        }

        bool didAuthenticate = await auth.authenticate(
          localizedReason: "Enable biometric login",
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (didAuthenticate) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isAuthenticated', true);

          setState(() => _biometricEnabled = true);

          ScaffoldMessageSnackbar.show(
            context: context,
            message: "Biometrics enabled",
            type: SnackbarType.success,
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text("✅ Biometrics enabled")),
          // );
        }
      } catch (e) {
        ScaffoldMessageSnackbar.show(
          context: context,
          message: "Error enabling biometrics: $e",
          type: SnackbarType.error,
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("Error enabling biometrics: $e")),
        // );
      }
    } else {
      // User wants to disable biometrics
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', false);

      setState(() => _biometricEnabled = false);
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Biometrics disabled",
        type: SnackbarType.warning,
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("🚫 Biometrics disabled")),
      // );
    }
  }

// Correct async function
  Future<void> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();

    customerId = prefs.getString('customerId');

    hospitalId = prefs.getString('hospitalId');
    print("Customer ID: $customerId"); // optional debug
    print("hospitalId ID: $hospitalId"); // optional debug
  }

  bool isAvailable = true;
  GetCustomerModel? userData;
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: CommonHeader(
        title: "Profile",
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
          future: getCustomerId(), // Wait until customerId is loaded
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (customerId == null || customerId!.isEmpty) {
              return const Center(child: Text("No customerId found."));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Obx(() {
                    final image = dashboardcontroller.imageFile.value;
                    return GestureDetector(
                      onTap: () => dashboardcontroller.showImagePickerOptions(
                          context, image),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: image != null
                            ? FileImage(image)
                            : const AssetImage('assets/ic_launcher.png')
                                as ImageProvider,
                      ),
                    );
                  }),

                  //  Obx(() {
                  //     final image = dashboardcontroller.imageFile.value;

                  //     return GestureDetector(
                  //       onTap: () {
                  //         if (image != null) {
                  //           Get.to(ImagePreviewScreen(imagePath: image.path));
                  //         } else {
                  //           dashboardcontroller.showImagePickerOptions(context,image);
                  //         }
                  //       },
                  //       child: CircleAvatar(
                  //         radius: 20,
                  //         backgroundColor: Colors.grey[200],
                  //         backgroundImage: image != null
                  //             ? FileImage(image)
                  //             : const AssetImage('assets/surecare_launcher.png')
                  //                 as ImageProvider,
                  //       ),
                  //     );
                  //   }),
                  // CircleAvatar(
                  //   radius: 40,
                  //   child: ClipOval(
                  //     child: Image.asset(
                  //       "assets/DermaText.png",
                  //       width: 100, // adjust size as needed
                  //       height: 100,
                  //       fit: BoxFit.contain,
                  //     ),
                  //   ),
                  // ),

                  FutureBuilder<GetCustomerModel>(
                    future: fetchUserData(
                        customerId ?? ""), // Mobile number passed here
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text("No data available."));
                      } else {
                        userData = snapshot.data!;
                        print("userData: ${userData!.fullName}"); // Debug print

                        return Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('${capitalizeEachWord(userData!.fullName)}',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: mainColor)),
                              Text(
                                '${userData!.customerId}',
                                textAlign: TextAlign.center, // ✅ Correct way
                              )
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  // Cards List
                  buildCardItem(
                      icon: Icons.person,
                      label: "Profile",
                      onTap: () => Get.to(
                          () => ProfileDetailScreen(cusData: userData!))),
                  // Get.to(() => ProfileDetailScreen())),

                  buildCardItem(
                      icon: Icons.help_outline,
                      label: "Privacy Policy",
                      onTap: () => Get.to(() => TermsAndConditionsScreen())),
                  buildCardItem(
                      icon: Icons.help_outline,
                      label: "Reports",
                      onTap: () => Get.to(() => PatientReportScreen(
                            mobileNumber: widget.mobileNumber,
                          ))),
                  buildCardItem(
                      icon: Icons.help_outline,
                      label: "About Clinic",
                      onTap: () =>
                          Get.to(() => ClinicScreen(hospitalId: hospitalId!))),
                  // onTap: () {}),
                  buildCardItem(
                      icon: Icons.help_outline,
                      label: "Help",
                      onTap: () => Get.to(() => HelpScreen())),
                  // onTap: () {}),

                  buildCardItem(
                      icon: Icons.menu_book,
                      label: "App user manual",
                      onTap: () => Get.to(() => AppointmentManualScreen())),

                  buildCardItem(
                      icon: Icons.logout,
                      label: "Logout",
                      onTap: () => {showLogout(context)}),

                  SizedBox(
                    height: 100,
                    child: ListView(
                      children: [
                        SwitchListTile(
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.grey,
                          activeThumbColor: mainColor,
                          secondary: CircleAvatar(
                            backgroundColor: mainColor,
                            child: Icon(
                              Icons.fingerprint, // 👈 Biometric icon
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          title: const Text(
                            "Enable Biometric Login",
                            style: TextStyle(
                              color: mainColor,
                            ),
                          ),
                          subtitle: const Text(
                            "Use fingerprint or face ID to login faster",
                          ),
                          value: _biometricEnabled,
                          onChanged: (value) {
                            _toggleBiometric(value);
                          },
                        ),
                        const Divider(),
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
      bottomNavigationBar: BottomAppBar(
        height: 45,
        color: Colors.white,
        child: Center(
            child: Text(
          "Version 1.1.0",
          style: TextStyle(color: mainColor),
        )),
      ),
    );
  }

  Widget buildCardItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: mainColor,
        child: Icon(icon, color: Colors.white),
      ),
      title:
          Text(label, style: const TextStyle(fontSize: 16, color: mainColor)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: secondaryColor,
      ),
      onTap: onTap,
    );
  }

  showLogout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, size: 40, color: Colors.red),
              const SizedBox(height: 10),
              const Text(
                "Confirm Logout",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("Are you sure you want to logout?"),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the bottom sheet
                      },
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close the bottom sheet
                        await logout(); // Call logout logic
                      },
                      child: const Text("Logout",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
