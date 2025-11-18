import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Inputs/CustomInputField.dart';
import '../../Inputs/CustomTextAera.dart';
import '../../Utils/Constant.dart';
import '../../Utils/GradintColor.dart';
import '../../Widget/CommentCOntroller.dart';
import 'ReportController.dart';

class Doctordetailscontroller extends GetxController {
  TextEditingController moreDetails = TextEditingController();

  Widget iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget buildTimingAndContactSection({
    required String timing,
    required VoidCallback onCall,
    required VoidCallback onDirection,
    required String hospitalNumber,
    required String days,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // color: Colors.white,

        border: Border.all(
            color: const Color.fromARGB(255, 255, 255, 255), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Mon-Sat Timings
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                    // color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        days,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      Text(
                        timing,
                        style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Sunday Closed
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    // color: Colors.white,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sunday",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Closed",
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(
                    Icons.phone,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Contact Clinic",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      width: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDirection,
                  icon:
                      const Icon(Icons.near_me, size: 18, color: Colors.white),
                  label: const Text(
                    "Get Direction",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget buildReportContactSection(
  //     BuildContext context, TextEditingController title) {
  //   return Column(
  //     children: [
  //       GestureDetector(
  //         onTap: () => showReportBottomSheet(context),
  //         child: Container(
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.withOpacity(0.3),
  //                 spreadRadius: 1,
  //                 blurRadius: 6,
  //                 offset: const Offset(0, 3),
  //               ),
  //             ],
  //             border: Border.all(
  //                 color: const Color.fromARGB(140, 158, 158, 158), width: 1),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: const [
  //               Text(
  //                 "Report an issue",
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   color: mainColor,
  //                   fontSize: 16,
  //                 ),
  //               ),
  //               Icon(Icons.flag, color: Colors.red),
  //             ],
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 20),
  //     ],
  //   );
  // }

  void showReportBottomSheet(BuildContext context) {
    final ReportController controller = Get.put(ReportController());

    final List<Map<String, dynamic>> issues = [
      {"icon": Icons.call, "label": "Wrong Contact Number"},
      {"icon": Icons.location_city, "label": "Wrong Address"},
      {"icon": Icons.lock_clock, "label": "Wrong Timings"},
      {"icon": Icons.currency_rupee, "label": "Wrong Consultation Fee"},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select an issue",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: mainColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Issues with checkboxes
                Obx(() => Column(
                      children: issues.map((item) {
                        final label = item["label"];
                        final icon = item["icon"];
                        return CheckboxListTile(
                          title: Text(label),
                          secondary: Icon(icon, color: Colors.redAccent),
                          controlAffinity: ListTileControlAffinity.trailing,
                          value: controller.selectedIssues.contains(label),
                          onChanged: (_) => controller.toggleIssue(label),
                        );
                      }).toList(),
                    )),

                const SizedBox(height: 20),

                CustomTextAera(
                  controller: controller.detailsController,
                  labelText: 'Enter More Details',
                ),

                const SizedBox(height: 20),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: appGradient(),
                  ),
                  child: TextButton(
                    onPressed: controller.submitReport,
                    child: const Text(
                      "SUBMIT",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
