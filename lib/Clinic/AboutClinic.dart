// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cutomer_app/Clinic/AboutClinicController.dart';
import 'package:cutomer_app/Utils/Header.dart';

class ClinicScreen extends StatefulWidget {
  final String hospitalId;

  const ClinicScreen({super.key, required this.hospitalId});
  @override
  State<ClinicScreen> createState() => _ClinicScreenState();
}

class _ClinicScreenState extends State<ClinicScreen> {
  final controller = Get.put(ClinicController());

  Future<void> _openLink(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not open $url");
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   getCustomerId();
  // }

  // String? hospitalId;

  // Future<void> getCustomerId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   hospitalId = prefs.getString('hospitalId');

  //   print("Customer ID: $hospitalId"); // optional debug
  // }

  @override
  Widget build(BuildContext context) {
    controller.fetchClinic(widget.hospitalId);

    return Scaffold(
      appBar: CommonHeader(title: "Clinic Details"),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty) {
          return Center(child: Text("Error: ${controller.error}"));
        }

        final clinic = controller.clinic.value;
        if (clinic == null) {
          return const Center(child: Text("No clinic data found"));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              /// ✅ Show logo or fallback icon
              clinic.hospitalLogo != null && clinic.hospitalLogo!.isNotEmpty
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            base64Decode(clinic.hospitalLogo!),
                            height: 80,
                          ),
                        ),
                        const SizedBox(
                            width: 12), // space between image and text
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // center horizontally
                            children: [
                              Text(
                                clinic.name,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                clinic.address,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const Icon(Icons.image_not_supported,
                      size: 80, color: Colors.grey),

              const SizedBox(height: 16),

              /// ✅ Clinic Info

              Text("City: ${clinic.city}"),
              Text("Rating: ⭐ ${clinic.hospitalOverallRating}"),
              Text("Contact: ${clinic.contactNumber}"),

              if (clinic.website != null && clinic.website!.isNotEmpty)
                GestureDetector(
                  onTap: () => _openLink(clinic.website!),
                  child: Text(
                    "${clinic.website}",
                    style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                ),

              const Divider(height: 30),

              /// ✅ Branches with Map
              if (clinic.branches != null && clinic.branches!.isNotEmpty) ...[
                Text("Branches",
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: clinic.branches!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final branch = clinic.branches![index];

                      double? lat = double.tryParse(branch.latitude);
                      double? lng = double.tryParse(branch.longitude);

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(branch.branchName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(branch.address),
                              Text("City: ${branch.city}"),
                              Text("Contact: ${branch.contactNumber}"),

                              /// Virtual Clinic Tour Link
                              if (branch.virtualClinicTour.isNotEmpty)
                                GestureDetector(
                                  onTap: () =>
                                      _openLink(branch.virtualClinicTour),
                                  child: const Text(
                                    "🔗 Virtual Clinic Tour",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 10),

                              /// ✅ Show Map if Lat/Lng present
                              if (lat != null && lng != null)
                                SizedBox(
                                  height: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(lat, lng),
                                        zoom: 15,
                                      ),
                                      markers: {
                                        Marker(
                                          markerId: MarkerId(branch.branchId),
                                          position: LatLng(lat, lng),
                                          infoWindow: InfoWindow(
                                            title: branch.branchName,
                                            snippet: branch.address,
                                          ),
                                        ),
                                      },
                                      zoomControlsEnabled: false,
                                      myLocationButtonEnabled: false,
                                    ),
                                  ),
                                )
                              else
                                const Text("📍 Location not available"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else
                const Text("No branches available"),
            ],
          ),
        );
      }),
    );
  }
}
