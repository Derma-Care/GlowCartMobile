import 'dart:convert';

import 'package:cutomer_app/Doctors/ListOfDoctors/DoctorController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../Utils/Constant.dart';
import '../../Utils/Header.dart';
import '../../Widget/DoctorCard.dart';
import '../RatingAndFeedback/RatingService.dart';

class Doctorscreen extends StatelessWidget {
  final String mobileNumber;
  final String username;
  final String subServiceID;
  final String? hospiatlName;
  final String branchName;
  final String branchId;

  Doctorscreen(
      {required this.mobileNumber,
      required this.username,
      required this.subServiceID,
      this.hospiatlName,
      required this.branchName,
      required this.branchId}) {
    // Trigger fetch after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorController = Get.find<DoctorController>();
      final hospitalId =
          doctorController.selectedServicesController.hospitalId.value;

      if (hospitalId.isNotEmpty && subServiceID.isNotEmpty) {
        doctorController.hospitalId.value = hospitalId;
        doctorController.fetchDoctors(
            hospitalId: hospitalId,
            subServiceId: subServiceID,
            branchId: branchId);
      } else {
        print("❌ Missing hospitalId or subServiceID");
      }
    });
  }

  final DoctorController doctorController = Get.find<DoctorController>();

  @override
  Widget build(BuildContext context) {
    String? base64String;
    if (doctorController.filteredDoctors.isNotEmpty) {
      base64String =
          doctorController.filteredDoctors.first.hospital.hospitalLogo;
    }

    return Scaffold(
      appBar: CommonHeader(
        title: "Doctors ",
        onNotificationPressed: () {},
        onSettingPressed: () {},
      ),
      body: Obx(() {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            buildFilters(doctorController),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: base64String != null
                              ? MemoryImage(base64Decode(base64String))
                              : null,
                          child:
                              base64String == null ? Icon(Icons.person) : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: "Selected Branch: ",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(
                                  text: "${branchName}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                  ),
                                ),
                                // TextSpan(
                                //   text: hospiatlName,
                                //   style: TextStyle(
                                //     fontSize: 16,
                                //     fontWeight: FontWeight.bold,
                                //     color: mainColor,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Doctors",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                mainColor, // You can replace with your desired color
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${doctorController.filteredDoctors.length} ",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (doctorController.isLoading.value) {
                  // 🔄 Show loading indicator
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: SpinKitFadingCircle(
                            color: mainColor,
                            size: 40.0,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Loading doctors...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (doctorController.filteredDoctors.isEmpty) {
                  // ❌ No data
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: 200),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                            child: Text(
                          "No doctors are currently available in the $branchName branch.",
                          textAlign: TextAlign.center,
                        )),
                      ),
                    ],
                  );
                } else {
                  // ✅ Show doctors list
                  return RefreshIndicator(
                    onRefresh: () async {
                      await doctorController.refreshDoctors(
                          subServiceId: subServiceID, branchId: branchId);
                    },
                    child: ListView.builder(
                      itemCount: doctorController.filteredDoctors.length,
                      itemBuilder: (context, index) {
                        return buildDoctorCard(
                            context,
                            doctorController.filteredDoctors[index],
                            doctorController,
                            mobileNumber,
                            username,
                            branchId);
                      },
                    ),
                  );
                }
              }),
            ),
            SizedBox(
              height: 10,
            )
          ],
        );
      }),
    );
  }
}
