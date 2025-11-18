import 'dart:convert';

import 'package:cutomer_app/Clinic/AboutClinicController.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cutomer_app/VideoCalling/CallController.dart';
import 'package:cutomer_app/VideoCalling/VideoCallScreen.dart';

class HomeScreen extends StatefulWidget {
  final String roomId;
  final String username;
  final String clinicId;
  const HomeScreen(
      {super.key,
      required this.roomId,
      required this.username,
      required this.clinicId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController nameCtrl;
  final CallController callController = Get.put(CallController());

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.username);
  }

  final controller = Get.put(ClinicController());
  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = mainColor;
    final lightBg = Colors.grey.shade100;
    controller.fetchClinic(widget.clinicId);
    final clinic = controller.clinic.value;
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        title: const Text('Video Consultation'),
        centerTitle: true,
        backgroundColor: themeColor,
        elevation: 4,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Branding Section
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(clinic!.hospitalLogo ?? ""),
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Welcome to ${clinic.name} Video Consultation",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),

              // Main Card
              Card(
                color: Colors.white,
                elevation: 8,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Enter Your Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Your Name',
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.meeting_room_outlined,
                                color: themeColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.roomId,
                                // "160039",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessageSnackbar.show(
                              context: context,
                              message: "Please enter your name",
                              type: SnackbarType.warning,
                            );
                            // Get.snackbar('Error', 'Please enter your name',
                            //     backgroundColor: Colors.red.shade100,
                            //     colorText: Colors.red.shade900);
                            return;
                          }

                          callController.setCallInfo(
                            uid: "User_${widget.roomId}",
                            uname: name,
                            cid: widget.roomId,
                          );

                          Get.to(() => CallPage(
                                callID: widget.roomId,
                                // callID: "160039",
                                username: name,
                              ));
                        },
                        icon: const Icon(
                          Icons.videocam_rounded,
                          color: Colors.white,
                        ),
                        label: const Text("Join Call"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 17),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
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
