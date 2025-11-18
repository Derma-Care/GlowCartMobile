import 'package:cutomer_app/Doctors/ListOfDoctors/DoctorController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utils/Constant.dart';
import '../../Utils/Header.dart';
import '../../Widget/DoctorCard.dart';

class ConsulationDoctorScreen extends StatelessWidget {
  final String mobileNumber;
  final String username;
  // final String subServiceID;
  // final String hospiatlName;

  ConsulationDoctorScreen({
    required this.mobileNumber,
    required this.username,
    // required this.subServiceID,
    // required this.hospiatlName
  }) {
    // Trigger fetch after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorController = Get.find<DoctorController>();
      final hospitalId = "H_6";

      // print("❌ Missing hospitalId or subServiceID ${hospitalId}");
      // print("❌ Missing hospitalId or subServiceID ${subServiceID}");

      if (hospitalId.isNotEmpty) {
        doctorController.hospitalId.value = hospitalId;
        // doctorController.fetchDoctors(
        //   hospitalId: "H_9",
        //   subServiceId: "683ad13a3fd93777eef8d7b0",
        // );
      } else {
        print("❌ Missing hospitalId or subServiceID");
      }
    });
  }

  final DoctorController doctorController = Get.find<DoctorController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: "Doctors & Hospitals",
        onNotificationPressed: () {},
        onSettingPressed: () {},
      ),
      body: Obx(() {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildFilters(doctorController),
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
                        Icon(Icons.local_hospital, color: mainColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: "Selected Subservice: ",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(
                                  // text: hospiatlName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
              child: RefreshIndicator(
                onRefresh: () async {
                  // doctorController.refreshDoctors(subServiceId: subServiceID);
                },
                child: doctorController.filteredDoctors.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 200),
                          Center(child: Text("No doctors found")),
                        ],
                      )
                    : ListView.builder(
                        itemCount: doctorController.filteredDoctors.length,
                        itemBuilder: (context, index) {
                          // return buildDoctorCard(
                          //     context,
                          //     doctorController.filteredDoctors[index],
                          //     doctorController,
                          //     mobileNumber,username);
                        },
                      ),
              ),
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
