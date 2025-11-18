import 'dart:convert';
import 'package:cutomer_app/ConfirmBooking/BranchSelectionSheet.dart';
import 'package:cutomer_app/ConfirmBooking/ConsultationController.dart';
import 'package:cutomer_app/Controller/CustomerController.dart';
import 'package:cutomer_app/Doctors/DoctorDetails/DoctorDetailsScreen.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/DoctorController.dart';
import 'package:cutomer_app/Doctors/Schedules/Schedule.dart';
import 'package:cutomer_app/Inputs/CustomDropdownField.dart';
import 'package:cutomer_app/Modals/ServiceModal.dart';
import 'package:cutomer_app/Services/SubServiceServices.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:cutomer_app/Widget/DoctorCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import '../Services/GetHospiatlsAndDoctorWithSubService.dart';
import '../Utils/Header.dart';
import 'package:http/http.dart' as http;

class ConsultationPrice extends StatefulWidget {
  final String mobileNumber;
  final String username;
  final String consulationType;
  final String symptoms;

  const ConsultationPrice({
    super.key,
    required this.mobileNumber,
    required this.username,
    required this.consulationType,
    required this.symptoms,
  });

  @override
  _ConsultationPriceState createState() => _ConsultationPriceState();
}

class _ConsultationPriceState extends State<ConsultationPrice> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  bool showRecommendedOnly = false;
  bool sortByAZ = false;
  String selectedGender = "All";
  double selectedRating = 0.0;
  bool isChecked = false;
  List<HospitalDoctorModel> hospitalDoctors = [];
  List<HospitalDoctorModel> bestDoctorList = []; // ✅ Store best doctor result
  bool isLoading = false;
  bool isfLoading = false;
  String? selectedBranch;
  String? selectedDoctorName;
  final consultationcontroller = Get.find<Consultationcontroller>();
  @override
  void initState() {
    super.initState();
    _loadAllDoctors();
  }

  Future<void> _loadAllDoctors() async {
    setState(() => isfLoading = true);
    try {
      final value = await fetchHospitalDoctor();
      setState(() {
        hospitalDoctors = value;
        isfLoading = false;
      });
    } catch (e) {
      setState(() => isfLoading = false);
      print("❌ Error: $e");
    }
  }

  Future<void> _loadBestDoctor(String value) async {
    setState(() => isLoading = true);
    try {
      final result = await fetchBestHospitalDoctor(widget.symptoms);
      setState(() {
        bestDoctorList = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessageSnackbar.show(
        context: context,
        message: "Failed to fetch best doctor: $e",
        type: SnackbarType.error,
      );
      // Get.snackbar("Error", "Failed to fetch best doctor: $e");
    }
  }

  String cleanBase64(String base64String) {
    if (base64String.contains(',')) {
      return base64String.split(',')[1];
    }
    return base64String;
  }

  List<String> get uniqueBranches {
    final allBranches = hospitalDoctors
        .expand((item) => item.doctor.branches)
        .map((b) => b.branchName)
        .toList();
    return allBranches.toSet().toList();
  }

  List<String> get filteredDoctorNames {
    if (selectedBranch == null) {
      return hospitalDoctors
          .map((item) => item.doctor.doctorName)
          .toSet()
          .toList();
    }
    return hospitalDoctors
        .where((item) =>
            item.doctor.branches.any((b) => b.branchName == selectedBranch))
        .map((item) => item.doctor.doctorName)
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredData =
        (isChecked ? bestDoctorList : hospitalDoctors).where((item) {
      final matchesSearch =
          item.hospital.name.toLowerCase().contains(searchText.toLowerCase()) ||
              item.doctor.doctorName
                  .toLowerCase()
                  .contains(searchText.toLowerCase());
      final isRecommended = !showRecommendedOnly ||
          (item.hospital.recommended == true ||
              item.hospital.recommended?.toString().toLowerCase() == "true");
      final matchesGender = selectedGender == "All" ||
          item.doctor.gender.toLowerCase() == selectedGender.toLowerCase();
      final matchesRating = item.doctor.doctorAverageRating >= selectedRating;
      final matchesBranch = selectedBranch == null ||
          item.doctor.branches.any((b) => b.branchName == selectedBranch);
      final matchesDoctor = selectedDoctorName == null ||
          item.doctor.doctorName == selectedDoctorName;

      return matchesSearch &&
          isRecommended &&
          matchesGender &&
          matchesRating &&
          matchesBranch &&
          matchesDoctor;
    }).toList();

    return Scaffold(
      appBar: CommonHeader(title: "Doctors for You"),
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                buildFilters(),

                // 🔹 Branch Dropdown + Doctor Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomDropdownField<String>(
                      value: selectedBranch,
                      labelText: "Select Branch",
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Row(
                            children: [
                              Icon(Icons.apartment, size: 18, color: mainColor),
                              SizedBox(width: 6),
                              Text("All Branches",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        ...uniqueBranches.map((branch) {
                          return DropdownMenuItem<String>(
                            value: branch,
                            child: Row(
                              children: [
                                Icon(Icons.location_city,
                                    size: 18, color: mainColor),
                                SizedBox(width: 6),
                                Text(branch),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedBranch = value;
                          selectedDoctorName = null;
                        });
                      },
                    ),
                    if (selectedBranch != null)
                      CustomDropdownField<String>(
                        value: selectedDoctorName,
                        labelText: "Select Doctor",
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Row(
                              children: [
                                Icon(FontAwesomeIcons.stethoscope,
                                    size: 18, color: mainColor),
                                SizedBox(width: 6),
                                Text("All Doctors",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          ...filteredDoctorNames.map((name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Row(
                                children: [
                                  Icon(Icons.person_outline,
                                      size: 18, color: mainColor),
                                  SizedBox(width: 6),
                                  Text(name),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) =>
                            setState(() => selectedDoctorName = value),
                      ),
                  ],
                ),

                // ✅ Any Doctor Checkbox -> Calls Best Doctor API
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) async {
                        if (value == true) {
                          setState(() => isChecked = true);

                          // ✅ If branch is selected, fetch best doctor only for that branch
                          if (selectedBranch != null) {
                            await _loadBestDoctor(selectedBranch!);
                          } else {
                            await _loadBestDoctor(
                                "best"); // fallback: overall best doctor
                          }
                        } else {
                          setState(() {
                            isChecked = false;
                            bestDoctorList.clear();
                          });
                        }
                      },
                    ),
                    Text("Any Doctor"),
                  ],
                ),

                Expanded(
                  child: isfLoading
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SpinKitFadingCircle(color: mainColor, size: 40.0),
                              SizedBox(height: 12),
                              Text("Loading doctors...",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54)),
                            ],
                          ),
                        )
                      : filteredData.isEmpty
                          ? const Center(child: Text("No results found."))
                          : ListView.builder(
                              itemCount: filteredData.length,
                              itemBuilder: (context, index) {
                                final item = filteredData[index];
                                final doctor = item.doctor;
                                final hospital = item.hospital;

                                final isVideo =
                                    widget.consulationType.toLowerCase() ==
                                            "video consultation" ||
                                        widget.consulationType.toLowerCase() ==
                                            "online consultation";

                                final cost = isVideo
                                    ? doctor.doctorFees.vedioConsultationFee
                                    : doctor.doctorFees.inClinicFee;

                                final branchesText = doctor.branches.isNotEmpty
                                    ? doctor.branches
                                        .map((b) => b.branchName)
                                        .join(", ")
                                    : hospital.city;

                                return InkWell(
                                  onTap: () async {
                                    // ✅ Check doctor availability first
                                    if (!doctor.doctorAvailabilityStatus) {
                                      // assuming you have a boolean field `isAvailable`

                                      ScaffoldMessageSnackbar.show(
                                        context: context,
                                        message: "Doctor not available",
                                        type: SnackbarType.warning,
                                      );

                                      return; // exit early, don't open branch bottom sheet
                                    }

                                    final branches = doctor.branches;

                                    if (branches.isEmpty) {
                                      consultationcontroller
                                          .selectedBranchName.value = '';
                                      consultationcontroller
                                          .selectedBranchId.value = '';

                                      await _loadBestDoctor(widget.symptoms);
                                      if (bestDoctorList.isNotEmpty) {
                                        Get.to(() => ScheduleScreen(
                                              doctorData: item,
                                              mobileNumber: widget.mobileNumber,
                                              username: widget.username,
                                              branchId: consultationcontroller
                                                  .selectedBranchId.value,
                                            ));
                                      }
                                      return;
                                    }

                                    // ✅ Show bottom sheet and pass List<Branch>
                                    final selectedIndex =
                                        await showModalBottomSheet<int>(
                                      context: context,
                                      builder: (context) {
                                        return BranchSelectionSheet(
                                            branches: branches);
                                      },
                                    );

                                    if (selectedIndex != null) {
                                      final selectedBranch =
                                          branches[selectedIndex];
                                      consultationcontroller.selectedBranchName
                                          .value = selectedBranch.branchName;
                                      consultationcontroller.selectedBranchId
                                          .value = selectedBranch.branchId;

                                      await _loadBestDoctor(widget.symptoms);
                                      if (bestDoctorList.isNotEmpty) {
                                        Get.to(() => ScheduleScreen(
                                              doctorData: item,
                                              mobileNumber: widget.mobileNumber,
                                              username: widget.username,
                                              branchId: consultationcontroller
                                                  .selectedBranchId.value,
                                            ));
                                      }
                                    }

                                    if (selectedIndex != null) {
                                      final selectedBranch =
                                          branches[selectedIndex];

                                      consultationcontroller.selectedBranchName
                                          .value = selectedBranch.branchName;
                                      consultationcontroller.selectedBranchId
                                          .value = selectedBranch.branchId;

                                      await _loadBestDoctor(widget.symptoms);
                                      if (bestDoctorList.isNotEmpty) {
                                        Get.to(() => ScheduleScreen(
                                              doctorData: item,
                                              mobileNumber: widget.mobileNumber,
                                              username: widget.username,
                                              branchId: consultationcontroller
                                                  .selectedBranchId.value,
                                            ));
                                      }
                                    }
                                  },
                                  child:
                                      buildDoctorCard(item, cost, branchesText),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDoctorCard(
      HospitalDoctorModel item, dynamic cost, String branchesText) {
    final doctor = item.doctor;
    final hospital = item.hospital;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: doctor.doctorAvailabilityStatus ? Colors.white : Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 3,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.only(topLeft: Radius.circular(14)),
                  child: doctor.doctorPicture != null &&
                          doctor.doctorPicture.isNotEmpty
                      ? Image.memory(
                          base64Decode(cleanBase64(doctor.doctorPicture)),
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover)
                      : Image.asset("assets/ic_launcher.png",
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover),
                ),
              ),
              Flexible(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ✅ Doctor name wrapped in 2 lines
                          Expanded(
                            child: Text(
                              doctor.doctorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              maxLines: 2, // Wrap into 2 lines
                              overflow:
                                  TextOverflow.ellipsis, // Adds ... if exceeds
                            ),
                          ),

                          // ✅ About button
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, // Removes inner padding
                              minimumSize:
                                  Size(0, 0), // Removes default min size
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              Get.to(DoctorDetailScreen(doctorData: item));
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 6.0),
                              child: Text(
                                "About",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                          "${doctor.qualification} • ${doctor.experience} yrs exp",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(branchesText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black87)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: Colors.orange),
                          const SizedBox(width: 2),
                          Text(
                              "${doctor.doctorAverageRating.toStringAsFixed(1)}/5",
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 10),
                          const Icon(Icons.local_hospital_outlined,
                              size: 14, color: Colors.redAccent),
                          const SizedBox(width: 2),
                          Text("${hospital.hospitalOverallRating}/5",
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Text(widget.consulationType,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12))),
                Text("₹${cost ?? 'N/A'}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: mainColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        spacing: 15,
        runSpacing: 10,
        children: [
          FilterChip(
            label: Text("A-Z",
                style: TextStyle(color: sortByAZ ? Colors.white : mainColor)),
            selectedColor: mainColor,
            selected: sortByAZ,
            showCheckmark: false,
            side: BorderSide(color: mainColor),
            onSelected: (val) => setState(() => sortByAZ = val),
          ),
          FilterChip(
            label: Icon(Icons.male,
                color: selectedGender == "Male" ? Colors.white : mainColor),
            selectedColor: mainColor,
            selected: selectedGender == "Male",
            showCheckmark: false,
            side: BorderSide(color: mainColor),
            onSelected: (val) =>
                setState(() => selectedGender = val ? "Male" : "All"),
          ),
          FilterChip(
            label: Icon(Icons.female,
                color: selectedGender == "Female" ? Colors.white : mainColor),
            selectedColor: mainColor,
            selected: selectedGender == "Female",
            showCheckmark: false,
            side: BorderSide(color: mainColor),
            onSelected: (val) =>
                setState(() => selectedGender = val ? "Female" : "All"),
          ),
          FilterChip(
            label: Icon(Icons.star,
                color: selectedRating >= 4.5 ? Colors.white : mainColor),
            selectedColor: mainColor,
            selected: selectedRating >= 4.5,
            showCheckmark: false,
            side: BorderSide(color: mainColor),
            onSelected: (val) =>
                setState(() => selectedRating = val ? 4.5 : 0.0),
          ),
        ],
      ),
    );
  }
}
