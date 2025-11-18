// import 'dart:convert';

// import 'package:cutomer_app/APIs/BaseUrl.dart';
// import 'package:cutomer_app/Doctors/Schedules/RelationModel.dart';
// import 'package:cutomer_app/Utils/Constant.dart';
// import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Registration/RegisterController.dart';

// class Patientdetailsformcontroller extends GetxController {
//   RxString selectedFor = "Self".obs;
//   RxString selectedGender = "Male".obs;

//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController ageController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController patientMobileNumberController =
//       TextEditingController();
//   final TextEditingController notesController = TextEditingController();
//   final TextEditingController relationController = TextEditingController();
//   Rxn<RelationModel> selectedRelation = Rxn<RelationModel>();
//   String? selectedTitle;
//   String age = "";
//   String? patientId;

//   final formKey = GlobalKey<FormState>();
//   final Color activeColor = mainColor;
//   final Color inactiveColor = Colors.transparent;
//   RxBool isLoadingRelations = false.obs;
//   RxList<RelationModel> relations = <RelationModel>[].obs;

//   // Flag to show manual form
//   RxBool isManualFormVisible = true.obs;

//   void setAge(String value) => age = value;

//   void updateFullName() {
//     final title = selectedTitle ?? '';
//     final first = firstNameController.text.trim();
//     final last = lastNameController.text.trim();

//     final fullName = [
//       if (title.isNotEmpty) title,
//       if (first.isNotEmpty) first,
//       if (last.isNotEmpty) last,
//     ].join(' ');

//     nameController.text = fullName;
//   }

//   Future<void> fetchRelations() async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerId = prefs.getString('customerId');
//     if (customerId == null) return;

//     var apiUrl = '${registerUrl}/bookings/byRelation/$customerId';
//     try {
//       isLoadingRelations.value = true;
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         final body = json.decode(response.body);
//         final data = body["data"] as Map<String, dynamic>;
//         List<RelationModel> allRelations = [];

//         data.forEach((key, value) {
//           if (value is List) {
//             for (var item in value) {
//               allRelations
//                   .add(RelationModel.fromJson(Map<String, dynamic>.from(item)));
//             }
//           }
//         });

//         relations.assignAll(allRelations);
//       }
//     } catch (e) {
//       print("Error fetching relations: $e");
//     } finally {
//       isLoadingRelations.value = false;
//     }
//   }

//   void clearForm() {
//     firstNameController.clear();
//     lastNameController.clear();
//     nameController.clear();
//     relationController.clear();
//     ageController.clear();
//     addressController.clear();
//     patientMobileNumberController.clear();
//     selectedTitle = null;
//     selectedGender.value = "";

//     isManualFormVisible.value = true;
//     patientId = null;
//   }

//   void selectRelation(RelationModel selected) {
//     nameController.text = selected.fullname;
//     relationController.text = selected.relation;
//     patientMobileNumberController.text = selected.mobileNumber;
//     ageController.text = selected.age.replaceAll(" Yrs", "");
//     addressController.text = selected.address;
//     selectedGender.value = selected.gender;
//     patientId = selected.patientId;

//     isManualFormVisible.value = false;
//   }

//   void submitSchedule() {
//     if (formKey.currentState!.validate()) {
//       showSnackbar("Success", "Form Validated", "success");
//     }
//   }
// }

import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/Doctors/Schedules/RelationModel.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Patientdetailsformcontroller extends GetxController {
  RxString selectedFor = "Self".obs;
  RxString selectedGender = "Male".obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController patientMobileNumberController =
      TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController relationController = TextEditingController();
  Rxn<RelationModel> selectedRelation = Rxn<RelationModel>();
  String? selectedTitle;
  String age = "";
  String? patientId;

  final formKey = GlobalKey<FormState>();
  final Color activeColor = mainColor;
  final Color inactiveColor = Colors.transparent;
  RxBool isLoadingRelations = false.obs;
  RxList<RelationModel> relations = <RelationModel>[].obs;

  // Default state: dropdown visible, manual form hidden
  RxBool isManualFormVisible = true.obs;

  void setAge(String value) => age = value;

  void updateFullName() {
    final title = selectedTitle ?? '';
    final first = firstNameController.text.trim();
    final last = lastNameController.text.trim();

    final fullName = [
      if (title.isNotEmpty) title,
      if (first.isNotEmpty) first,
      if (last.isNotEmpty) last,
    ].join(' ');

    nameController.text = fullName;
  }

  Future<void> fetchRelations() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');
    if (customerId == null) return;

    var apiUrl = '${registerUrl}/bookings/byRelation/$customerId';
    try {
      isLoadingRelations.value = true;
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final data = body["data"] as Map<String, dynamic>;
        List<RelationModel> allRelations = [];

        data.forEach((key, value) {
          if (value is List) {
            for (var item in value) {
              allRelations
                  .add(RelationModel.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        });

        relations.assignAll(allRelations);
      }
    } catch (e) {
      print("Error fetching relations: $e");
    } finally {
      isLoadingRelations.value = false;
    }
  }

  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    nameController.clear();
    relationController.clear();
    ageController.clear();
    addressController.clear();
    patientMobileNumberController.clear();
    selectedTitle = null;
    selectedGender.value = "Male";
    patientId = null;
  }

  void selectRelation(RelationModel selected) {
    nameController.text = selected.fullname;
    relationController.text = selected.relation;
    patientMobileNumberController.text = selected.mobileNumber;
    ageController.text = selected.age.replaceAll(" Yrs", "");
    addressController.text = selected.address;
    selectedGender.value = selected.gender;
    patientId = selected.patientId;

    // ✅ Hide manual form once a relation is selected
    // isManualFormVisible.value = false;
  }
}
