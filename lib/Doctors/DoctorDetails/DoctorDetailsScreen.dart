import 'dart:convert';
import 'package:cutomer_app/ConfirmBooking/ConsultationController.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/GradintColor.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Help/Numbers.dart';
import '../../Utils/MapOnGoogle.dart';
import '../ListOfDoctors/DoctorController.dart';
import '../RatingAndFeedback/RatingAndFeedback.dart';
import 'DoctorDetailsController.dart';

class DoctorDetailScreen extends StatefulWidget {
  final HospitalDoctorModel doctorData;

  const DoctorDetailScreen({super.key, required this.doctorData});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  String? hospitalId;
  String? hospitalName;

  final Doctordetailscontroller doctordetailscontroller =
      Doctordetailscontroller();
  final DoctorController doctorController = Get.put(DoctorController());
  final consultationcontroller = Get.find<Consultationcontroller>();

  @override
  void initState() {
    super.initState();
    _loadHospitalData();
  }

  Future<void> _loadHospitalData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hospitalId = prefs.getString('hospitalId');
      hospitalName = prefs.getString('hospitalName');
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctorData.doctor;
    final hospital = widget.doctorData.hospital;

    return Scaffold(
      appBar: CommonHeader(
        title: "Doctor Information",
        onNotificationPressed: () {},
        onSettingPressed: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟩 CARD CONTAINER
            Container(
              decoration: BoxDecoration(
                gradient: appGradient(),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Profile Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: doctor.doctorPicture.isNotEmpty
                            ? MemoryImage(
                                base64Decode(
                                    doctor.doctorPicture.split(',').last),
                              )
                            : null,
                        child: doctor.doctorPicture.isEmpty
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.doctorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor.qualification,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor.specialization,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// Hospital Info Row (Showing from SharedPreferences)
                  if (hospitalId != null && hospitalName != null)
                    Row(
                      children: [
                        const Icon(Icons.local_hospital,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "$hospitalName",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.badge, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "${doctor.experience} years experience",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.schedule, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "${doctor.availableDays}, ${doctor.availableTimes}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Doctor's Profile",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: mainColor, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              doctor.profileDescription,
              style: const TextStyle(color: mainColor),
            ),

            const SizedBox(height: 20),
            const Text(
              "Focus Areas",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: doctor.focusAreas.map((area) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "• $area",
                    style: const TextStyle(color: mainColor),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            const Text(
              "Highlights & Achievements",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: mainColor, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: doctor.highlights.map((highlight) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.greenAccent, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          highlight,
                          style: const TextStyle(color: mainColor),
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            if (doctor.associationsOrMemberships != null)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(
                  "Associations / Memberships",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                      fontSize: 16),
                ),
                Text(
                  "${doctor.associationsOrMemberships}",
                  style: TextStyle(color: mainColor, fontSize: 16),
                ),
              ]),
            const SizedBox(height: 20),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                "Branches",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                    fontSize: 16),
              ),
              Text(
                "${doctor.branches.map((e) => e.branchName)}",
                style: TextStyle(color: mainColor, fontSize: 16),
              ),
            ]),

            const SizedBox(height: 20),

            RatingAndFeedback(
              item: widget.doctorData,
              controller: doctorController,
            ),
          ],
        ),
      ),
    );
  }
}
