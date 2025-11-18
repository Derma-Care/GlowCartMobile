import 'dart:convert';
import 'package:cutomer_app/APIs/FetchBranch.dart';
import 'package:cutomer_app/ConfirmBooking/ConsultationController.dart';
import 'package:cutomer_app/Inputs/CustomDropdownField.dart';
import 'package:cutomer_app/Inputs/CustomInputField.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Consultations/SymptomsController.dart';
import '../Modals/ServiceModal.dart';
import '../SubserviceAndHospital/HospitalCardModel.dart';
import '../Utils/Constant.dart';
import '../Utils/Header.dart';
import '../ServiceView/ServiceDetailPage.dart';
import 'HospitalService.dart';

class HospitalCardScreen extends StatefulWidget {
  final String mobileNumber;
  final String username;
  final String categoryName;
  final String categoryId;
  final String serviceId;
  final String serviceName;
  final SubServiceAdmin? selectedService;
  final Service services;

  const HospitalCardScreen({
    super.key,
    required this.categoryName,
    required this.categoryId,
    required this.serviceId,
    required this.serviceName,
    required this.mobileNumber,
    required this.username,
    required this.selectedService,
    required this.services,
  });

  @override
  _HospitalCardScreenState createState() => _HospitalCardScreenState();
}

class _HospitalCardScreenState extends State<HospitalCardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  String? selectedCity;
  Branch? selectedBranch;
  List<HospitalCardModel> hospitalCards = [];
  bool isLoading = true;
  final consultationcontroller = Get.find<Consultationcontroller>();
  String? branchId;
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<SymptomsController>()) {
      Get.put(SymptomsController());
    }
    selectedBranch = null;
    fetchHospitalCards();
  }

  void fetchHospitalCards() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();

    final double? lat = prefs.getDouble('latitude');
    final double? long = prefs.getDouble('longitude');
    branchId = await prefs.getString('branchId');
    // await prefs.setString('hospitalId', data['hospitalId'] ?? "");
    final clinicId = await prefs.getString('hospitalId');

    try {
      final data = await HospitalService().fetchHospitalCards(
          clinicId!, widget.selectedService!.subServiceId, lat!, long!);
      setState(() {
        hospitalCards = data;
        isLoading = false;
      });
    } catch (e, stacktrace) {
      setState(() => isLoading = false);
      print("Error fetching hospital cards: $e\n$stacktrace");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtered hospital cards based on search, city, and branch

    final filteredCards = hospitalCards.where((card) {
      final matchesSearch = searchText.isEmpty ||
          card.hospitalName.toLowerCase().contains(searchText.toLowerCase()) ||
          card.subServiceName
              .toLowerCase()
              .contains(searchText.toLowerCase()) ||
          card.branches.any((branch) =>
              branch.branchName
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) ||
              branch.city.toLowerCase().contains(searchText.toLowerCase()));

      final matchesCity = selectedCity == null || // ✅ null means "All Cities"
          card.branches.any((branch) => branch.city == selectedCity);

      final matchesBranch =
          selectedBranch == null || // ✅ null means "All Branches"
              card.branches
                  .any((branch) => branch.branchId == selectedBranch!.branchId);

      return matchesSearch && matchesCity && matchesBranch;
    }).toList();

    // Unique cities for dropdown
    final cities = hospitalCards
        .expand((card) => card.branches.map((b) => b.city))
        .toSet()
        .toList();

    // Branches for selected city dropdown
    final filteredBranches = selectedCity == null
        ? []
        : hospitalCards
            .expand((card) => card.branches)
            .where((b) => b.city == selectedCity)
            .toSet()
            .toList();

    return Scaffold(
      appBar: CommonHeader(title: "Hospitals & Branches"),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search field

            CustomTextField(
              controller: _searchController,
              labelText: "Search Hospital / City / Branch",
              prefixIcon: const Icon(Icons.search),
              showClearIcon: true,
              onChanged: (val) => setState(() => searchText = val),
              onClear: () => setState(() => searchText = ""),
            ),

            // TextField(
            //   controller: _searchController,
            //   decoration: InputDecoration(
            //     hintText: "Search Hospital / City / Branch",
            //     prefixIcon: Icon(Icons.search),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            // ),

            // City Dropdown
            if (cities.isNotEmpty)
              CustomDropdownField<String>(
                value: selectedCity,
                labelText: "Select City",
                icon: Icons.location_city,
                items: [
                  const DropdownMenuItem<String>(
                    value: null, // ✅ Represents "Show All"
                    child: Text("All Cities"),
                  ),
                  ...cities.map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      ))
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCity =
                        value; // ✅ value will be null if "All Cities" selected
                    selectedBranch = null; // Reset branch when city changes
                  });
                },
              ),
// Branch Dropdown
            if (filteredBranches.isNotEmpty)
              CustomDropdownField<Branch>(
                value: selectedBranch,
                labelText: "Select Branch",
                icon: Icons.location_on,
                items: [
                  const DropdownMenuItem<Branch>(
                    value: null, // ✅ Represents "Show All"
                    child: Text("All Branches"),
                  ),
                  ...filteredBranches.map((branch) {
                    return DropdownMenuItem<Branch>(
                      value: branch,
                      child: Text(branch.branchName),
                    );
                  }).toList()
                ],
                onChanged: (value) async {
                  setState(() {
                    selectedBranch = value;
                    if (value != null)
                      selectedCity = value.city; // keep city in sync
                  });

                  if (value != null) {
                    // final prefs = await SharedPreferences.getInstance();
                    // await prefs.setString('branchId', value.branchId);
                    // await prefs.setString('branchName', value.branchName);
                    // final branch = await BranchService().getBranchById(value.branchId);
                    // consultationcontroller.selectedBranchName.value =
                    //     value.branchName;
                    // consultationcontroller.selectedBranchId.value =
                    //     value.branchId;
                    // Get.find<SymptomsController>().updateBranch(branch);
                  }
                },
              ),

            const SizedBox(height: 10),

            // Hospital Cards
            Expanded(
              child: isLoading
                  ? const Center(
                      child: SpinKitFadingCircle(color: mainColor, size: 40))
                  : filteredCards.isEmpty
                      ? const Center(child: Text("No hospitals found."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredCards.length,
                          itemBuilder: (context, index) {
                            final card = filteredCards[index];

                            // Filter branches for display inside this card
                            // Inside ListView.builder
                            final displayedBranches =
                                card.branches.where((branch) {
                              final matchesSearchBranch = searchText.isEmpty ||
                                  branch.branchName
                                      .toLowerCase()
                                      .contains(searchText.toLowerCase()) ||
                                  branch.city
                                      .toLowerCase()
                                      .contains(searchText.toLowerCase());

                              final matchesCityBranch = selectedCity == null ||
                                  branch.city == selectedCity;

                              final matchesSelectedBranch = selectedBranch ==
                                      null ||
                                  branch.branchId == selectedBranch!.branchId;

                              return matchesSearchBranch &&
                                  matchesCityBranch &&
                                  matchesSelectedBranch;
                            }).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hospital Header (always navigable)
                                GestureDetector(
                                  // onTap: () {
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (_) => ServiceDetailsPage(
                                  //         mobileNumber: widget.mobileNumber,
                                  //         username: widget.username,
                                  //         selectedService:
                                  //             widget.selectedService!.serviceId,
                                  //         hospitalName: card.hospitalName,
                                  //         hospitalId: card.hospitalId,
                                  //       ),
                                  //     ),
                                  //   );
                                  // },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(
                                          base64Decode(card.hospitalLogo),
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, _, __) =>
                                              Image.asset(
                                                  'assets/ic_launcher.png',
                                                  width: 80,
                                                  height: 80),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(card.hospitalName,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    color: Colors.amber,
                                                    size: 18),
                                                const SizedBox(width: 4),
                                                Text(
                                                    "${card.hospitalOverallRating.toStringAsFixed(1)}/5",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.miscellaneous_services,
                                              color: Colors.amber,
                                              size: 18),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              "${card.serviceName}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500),
                                              maxLines:
                                                  2, // ✅ allow max 2 lines
                                              overflow: TextOverflow
                                                  .ellipsis, // ✅ show "..." if still too long
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                        width: 8), // space between columns
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.biotech,
                                              color: Colors.amber, size: 18),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              "${card.subServiceName}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () async {
                                        final Uri url = Uri.parse(card.website);
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Could not launch ${card.website}")));
                                        }
                                      },
                                      icon: const Icon(Icons.language,
                                          color: mainColor),
                                      label: const Text(
                                        "Visit Website",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: mainColor),
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text:
                                                  "₹${card.price.toStringAsFixed(0)} ",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                  decoration: TextDecoration
                                                      .lineThrough)),
                                          TextSpan(
                                              text:
                                                  "(${card.discountPercentage.toStringAsFixed(0)}% OFF)",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "₹${card.discountedCost.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Branches
                                // Branches
                                ...displayedBranches.map((branch) {
                                  return GestureDetector(
                                    onTap: () async {
                                      // ✅ Update Controller
                                      consultationcontroller.selectedBranchName
                                          .value = branch.branchName;
                                      consultationcontroller.selectedBranchId
                                          .value = branch.branchId;

                                      // ✅ Persist selection in SharedPreferences
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      // await prefs.setString(
                                      //     'branchId', branch.branchId);
                                      // await prefs.setString('branchName', branch.branchName);

                                      // ✅ Update SymptomsController (already in your code)
                                      // Update controller
                                      final scontroller =
                                          Get.find<SymptomsController>();
                                      scontroller.updateBranch(branch);
                                      // Navigate to ServiceDetailsPage with this branch's hospital info
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ServiceDetailsPage(
                                            mobileNumber: widget.mobileNumber,
                                            username: widget.username,
                                            selectedService: widget
                                                .selectedService!.subServiceId,
                                            hospitalName: card.hospitalName,
                                            hospitalId: card.hospitalId,
                                            branchId: branch
                                                .branchId, // Pass branchId if needed
                                            branchName: branch.branchName,
                                          ),
                                        ),
                                      );

                                      // Update selected branch in controller
                                     
                                   
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        color: const Color.fromARGB(
                                            255, 240, 239, 239),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(branch.branchName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: mainColor)),
                                              // Text(branch.branchId,
                                              //     style: const TextStyle(
                                              //         fontWeight:
                                              //             FontWeight.w600,
                                              //         color: mainColor)),
                                              // Text(branchId!,
                                              //     style: const TextStyle(
                                              //         fontWeight:
                                              //             FontWeight.w600,
                                              //         color: mainColor)),
                                              if (branch.branchId == branchId)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.green.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  child: const Text(
                                                      "Main Branch",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.green)),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(branch.address),
                                          const SizedBox(height: 2),
                                          Text("City: ${branch.city}"),
                                          const SizedBox(height: 2),
                                          Text("📞 : ${branch.contactNumber}"),
                                          const SizedBox(height: 2),
                                          Text("✉️ ${branch.email}"),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton.icon(
                                                onPressed: () async {
                                                  final Uri url = Uri.parse(
                                                      branch.virtualClinicTour);
                                                  if (await canLaunchUrl(url)) {
                                                    await launchUrl(url,
                                                        mode: LaunchMode
                                                            .externalApplication);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                "Could not launch ${card.website}")));
                                                  }
                                                },
                                                icon: const Icon(
                                                    Icons.video_camera_front,
                                                    color: mainColor),
                                                label: const Text(
                                                  "Virtual Clinic Tour",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: mainColor),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(Icons.location_on,
                                                      size: 16,
                                                      color:
                                                          mainColor), // 📍 Location icon
                                                  SizedBox(
                                                      width:
                                                          4), // small spacing
                                                  Text(
                                                    "${branch.kms}",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: mainColor,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),

                                const SizedBox(height: 10),

                                // Price & Discount

                                const SizedBox(height: 8),

                                // Website

                                const Divider(height: 20),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
