// import 'package:cutomer_app/Controller/CustomerController.dart';
// import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'DoctorService.dart';

// class DoctorController extends GetxController {
//   final DoctorService doctorService = DoctorService();

//   RxList<HospitalDoctorModel> allServices = <HospitalDoctorModel>[].obs;
//   RxList<HospitalDoctorModel> allDoctorsFlat = <HospitalDoctorModel>[].obs;
//   RxList<HospitalDoctorModel> filteredDoctors = <HospitalDoctorModel>[].obs;
//   RxInt appointmentCount = 0.obs;

//   RxString selectedGender = 'All'.obs;
//   RxString selectedCity = 'All'.obs;
//   RxBool selectedRecommended = false.obs; // ✅ RxBool

//   RxBool showFavoritesOnly = false.obs;
//   RxBool sortByAZ = false.obs;
//   RxDouble selectedRating = 0.0.obs;

//   RxList<String> cityList = <String>[].obs;
//   RxString doctorId = "".obs;
//   RxBool isLoading = false.obs;
//   RxString hospitalId = ''.obs;

//   // final selectedServicesController = Get.find<SelectedServicesController>();
//   // final selectedServicesController = Get.put(SelectedServicesController());
//   late final selectedServicesController =
//       Get.find<SelectedServicesController>();
//   @override
//   void onInit() {
//     super.onInit();

//     // fetchDoctors();
//     // ✅ Only fetch if not already loaded
//   }

//   // void setDoctorId(String id) async {
//   //   doctorId.value = id;

//   //   final doctor = await doctorService.getDoctorById(id, "");
//   //   if (doctor != null) {
//   //     // ✅ Example: Update appointmentCount based on doctor logic
//   //     appointmentCount.value = doctor.doctor.bookingSlots.length;
//   //   }
//   // }

//   Future<void> fetchDoctors(
//       {required String hospitalId, required String subServiceId}) async {
//     print("🌀 Fetching doctors from API...");

//     try {
//       isLoading.value = true;

//       final hospitalIdToUse = selectedServicesController.hospitalId.value;
//       print("🏥 Using hospitalId: $hospitalIdToUse");

//       final services =
//           await doctorService.fetchDoctorsAndClinic(hospitalId, subServiceId);
//       allServices.value = services;

//       final List<HospitalDoctorModel> extractedDoctors = [];

//       final List<HospitalDoctorModel> doctors =
//           await doctorService.fetchDoctorsAndClinic(hospitalId, subServiceId);

//       allDoctorsFlat.value = doctors;

// // You can still get cityList from doctor.hospital
//       final cities = doctors.map((d) => d.hospital.city).toSet().toList();
//       cityList.value = ['All', ...cities];

//       applyFilters();

//       allDoctorsFlat.value = extractedDoctors;

//       // Get unique cities
//       // final cities =
//       //     extractedDoctors.map((d) => d.hospital.city).toSet().toList();
//       // cityList.value = ['All', ...cities];

//       applyFilters();
//     } catch (e) {
//       print("❌ Fetch error: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // void toggleFavorite(HospitalDoctorModel doctorModel) {
//   //   doctorModel.doctor. = !doctorModel.doctor.favorites;
//   //   allDoctorsFlat.refresh();
//   //   applyFilters();
//   // }

//   void applyFilters() {
//     List<HospitalDoctorModel> filtered = List.from(allDoctorsFlat);

//     if (selectedGender.value != 'All') {
//       filtered = filtered
//           .where((d) => d.doctor.gender == selectedGender.value)
//           .toList();
//     }

//     if (selectedCity.value != 'All') {
//       filtered =
//           filtered.where((d) => d.hospital.city == selectedCity.value).toList();
//     }
//     if (selectedRecommended.value) {
//       filtered = filtered.where((d) => d.hospital.recommended == true).toList();
//     }

//     // if (showFavoritesOnly.value) {
//     //   filtered = filtered.where((d) => d.doctor.favorites).toList();
//     // }

//     // if (selectedRating.value > 0.0) {
//     //   filtered = filtered
//     //       .where((d) => d.doctor.overallRating >= selectedRating.value)
//     //       .toList();
//     // }

//     if (sortByAZ.value) {
//       filtered
//           .sort((a, b) => a.doctor.doctorName.compareTo(b.doctor.doctorName));
//     }

//     filteredDoctors.value = filtered;
//   }

//   void refreshDoctors({required String subServiceId}) async {
//     isLoading.value = true;
//     await fetchDoctors(
//         hospitalId: hospitalId.value, subServiceId: subServiceId);
//     isLoading.value = false;
//   }
// }

import 'package:cutomer_app/ConfirmBooking/ConsultationController.dart';
import 'package:cutomer_app/Controller/CustomerController.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:cutomer_app/Doctors/RatingAndFeedback/RatingService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DoctorService.dart';

class DoctorController extends GetxController {
  final DoctorService doctorService = DoctorService();

  // Lists for doctors
  RxList<HospitalDoctorModel> allServices = <HospitalDoctorModel>[].obs;
  RxList<HospitalDoctorModel> allDoctorsFlat = <HospitalDoctorModel>[].obs;
  RxList<HospitalDoctorModel> filteredDoctors = <HospitalDoctorModel>[].obs;

  // Doctor ratings and comments
  RxMap<String, double> doctorRatings = <String, double>{}.obs;
  RxMap<String, int> doctorCommentCounts = <String, int>{}.obs;

  // Filters
  RxString selectedGender = 'All'.obs;
  RxString selectedCity = 'All'.obs;
  RxBool selectedRecommended = false.obs;
  RxBool showFavoritesOnly = false.obs;
  RxBool sortByAZ = false.obs;
  RxDouble selectedRating = 0.0.obs;

  // Other info
  RxList<String> cityList = <String>[].obs;
  RxBool isLoading = false.obs;
  RxString hospitalId = ''.obs;

  late final selectedServicesController =
      Get.find<SelectedServicesController>();

  @override
  void onInit() {
    super.onInit();
  }

  /// Fetch doctors from API for a specific hospital, subService, and branch
  Future<void> fetchDoctors({
    required String hospitalId,
    required String subServiceId,
    required String branchId,
  }) async {
    try {
      isLoading.value = true;

      // ✅ Clear previous data to avoid duplicates
      allDoctorsFlat.clear();
      allServices.clear();
      filteredDoctors.clear();
      doctorRatings.clear();
      // doctorCommentCounts.clear();
      cityList.clear();

      print("🌀 Fetching doctors for branchId: $branchId");

      final List<HospitalDoctorModel> doctors = await doctorService
          .fetchDoctorsAndClinic(hospitalId, subServiceId, branchId);

      print("📊 Doctors fetched: ${doctors.length}");

      // ✅ Remove duplicates based on doctorId
      final uniqueDoctors = <String, HospitalDoctorModel>{};
      for (var doctor in doctors) {
        uniqueDoctors[doctor.doctor.doctorId] = doctor;
      }

      allDoctorsFlat.value = uniqueDoctors.values.toList();
      allServices.value = List.from(allDoctorsFlat);

      // Fetch ratings asynchronously
      final ratingFutures = allDoctorsFlat.map((doctorModel) async {
        final dId = doctorModel.doctor.doctorId;
        final consultationcontroller = Get.find<Consultationcontroller>();

        final hId = consultationcontroller.selectedBranchId.value;
        // final hId = doctorModel.hospital.hospitalId;

        try {
          final rating = await fetchAndSetRatingSummary(hId, dId);
          doctorRatings[dId] = rating.overallDoctorRating;
          doctorCommentCounts[dId] = rating.comments.length;
        } catch (e) {
          print("⚠️ Failed to fetch rating for $dId: $e");
        }
      }).toList();

      await Future.wait(ratingFutures);

      // Populate city list
      final cities =
          allDoctorsFlat.map((d) => d.hospital.city).toSet().toList();
      cityList.addAll(['All', ...cities]);

      // Apply filters to populate filteredDoctors
      applyFilters();
    } catch (e) {
      print("❌ Fetch error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter doctors based on selected filters
  void applyFilters() {
    var filtered = List<HospitalDoctorModel>.from(allDoctorsFlat);

    if (selectedGender.value != 'All') {
      filtered = filtered
          .where((d) => d.doctor.gender == selectedGender.value)
          .toList();
    }

    if (selectedCity.value != 'All') {
      filtered =
          filtered.where((d) => d.hospital.city == selectedCity.value).toList();
    }

    if (selectedRecommended.value) {
      filtered = filtered.where((d) => d.hospital.recommended == true).toList();
    }

    if (selectedRating.value > 0) {
      filtered = filtered.where((d) {
        final rating = doctorRatings[d.doctor.doctorId] ?? 0.0;
        return rating >= selectedRating.value;
      }).toList();
    }

    if (sortByAZ.value) {
      filtered
          .sort((a, b) => a.doctor.doctorName.compareTo(b.doctor.doctorName));
    }

    filteredDoctors.value = filtered;
  }

  /// Refresh doctors for a branch
  Future<void> refreshDoctors({
    required String subServiceId,
    required String branchId,
  }) async {
    await fetchDoctors(
      hospitalId: hospitalId.value,
      subServiceId: subServiceId,
      branchId: branchId,
    );
  }
}
