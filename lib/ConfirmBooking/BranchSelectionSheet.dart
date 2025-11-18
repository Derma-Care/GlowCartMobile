import 'package:cutomer_app/Clinic/AboutClinicController.dart';
import 'package:cutomer_app/Consultations/SymptomsController.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BranchSelectionSheet extends StatelessWidget {
  final List<Branch> branches; // ✅ Use Branch model

  const BranchSelectionSheet({super.key, required this.branches});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select a Branch",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(branches.length, (index) {
            final branch = branches[index];
            return ListTile(
              title:
                  Text(branch.branchName, style: const TextStyle(fontSize: 14)),
              leading: const Icon(Icons.local_hospital_outlined,
                  color: Colors.redAccent),
              onTap: () async {
                print("🖐 Branch tapped: ${branch.branchName}");

                // SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                var hospitalId = prefs.getString('hospitalId');
                print("🏥 Hospital ID from prefs: $hospitalId");

                // Get ClinicController and fetch clinic data
                final controller = Get.put(ClinicController());
                await controller
                    .fetchClinic(hospitalId!); // Wait for async fetch

                final clinic = controller.clinic.value;
                print(
                    "📋 Clinic fetched: ${clinic!.name}, branches: ${clinic.branches!.length}");

                // Find the branch using firstWhere
                var selectedBranch = clinic.branches!.firstWhere(
                  (e) => e.branchId == branch.branchId,
                );

                print(
                    "📌 Selected Branch: ${selectedBranch.branchName}, address: ${selectedBranch.address}, contact: ${selectedBranch.contactNumber}");

                // Update SymptomsController
                final scontroller = Get.find<SymptomsController>();
                scontroller.updateBranch(
                    selectedBranch); // Will print: Controller Branch Updated

                // Close the bottom sheet or dialog
                Navigator.pop(context, index);
              },
            );
          }),
        ],
      ),
    );
  }
}
