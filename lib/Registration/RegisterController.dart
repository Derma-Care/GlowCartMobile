import 'package:cutomer_app/Registration/RegisterAPI.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../BottomNavigation/BottomNavigation.dart';
import '../ConfirmBooking/Consultations.dart';
import 'RegisterModel.dart';
import '../Utils/ScaffoldMessageSnacber.dart';
import '../Utils/ShowSnackBar copy.dart';
import '../Utils/capitalizeFirstLetter.dart';

class Registercontroller extends GetxController {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController referralController = TextEditingController();

  //API
  final ApiService apiService = ApiService();
  String selectedGender = 'Male'; // Default value

  String bloodGroup = 'select';
  String? errorMessage;

  @override
  final List<String> genderOptions = ['Male', 'Female', 'Others'];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }

  /// **🔹 Validate Email Address**
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Field should not be empty";
    }

    final emailRegex = RegExp(
        r"^(?=.*[a-zA-Z])[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]*[a-zA-Z]+[a-zA-Z0-9!#$%&'*+/=?^_`{|}~.-]*@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$");

    if (!emailRegex.hasMatch(value)) {
      return "Please enter a valid email ID";
    }
    return null; // ✅ Valid Email
  }

  String? validateDOB(String? value) {
    if (value == null || value.isEmpty) return 'Please enter date of birth';

    final parts = value.split('/');
    if (parts.length != 3) return 'Enter date as DD/MM/YYYY';

    final String dayStr = parts[0];
    final String monthStr = parts[1];
    final String yearStr = parts[2];

    final int? day = int.tryParse(dayStr);
    final int? month = int.tryParse(monthStr);
    final int? year = int.tryParse(yearStr);

    final int currentYear = DateTime.now().year;

    if (day == null || month == null || year == null) {
      return 'Invalid date format';
    }

    if (day < 1 || day > 31) return 'Day must be between 1 and 31';
    if (month < 1 || month > 12) return 'Month must be between 1 and 12';
    if (yearStr.length != 4) return 'Year must be 4 digits';
    if (year > currentYear) return 'Year cannot be in the future';

    return null; // ✅ Valid
  }

  Future<void> submitForm(
      BuildContext context, dynamic fullName, dynamic mobileNumber) async {
    print("Iam calling from Basic Details....");
    if (formKey.currentState!.validate()) {
      context.loaderOverlay.show(); // Show loading overlay

      String formattedDate = DateFormat('dd-MM-yyyy')
          .format(DateFormat('dd/MM/yyyy').parse(dateOfBirthController.text));

      final RegisterModel user = RegisterModel(
        fullName: fullName,
        mobileNumber: mobileNumber,
        emailId: emailController.text,
        referCode: referralController.text,
        gender: selectedGender,
        dateOfBirth: formattedDate,
      );

      try {
        final response = await apiService.registerUser(user);
        // print("Iam calling from Basic Details....${response.bod}");

        if (response['status'] == 200) {
          context.loaderOverlay.hide(); // Hide loading overlay
          showSnackbar("Success", "${response['message']}", "success");
          Get.offAll(ConsultationsType(
            mobileNumber: mobileNumber,
            username: fullName,
          ));
        } else {
          // Handle cases where the server responds with an error status
          showSnackbar("Error", "${response['message']}", "errror");
          // showSnackbar(
          //     "Error",
          //     "${response['message'] ?? "Failed to register. Please try again."}",
          //     "errror");
        }
        if (response['status'] == 409) {
          // context.loaderOverlay.hide(); // Hide loading overlay
          showSnackbar("Error", "${response['message']}", "error");
        }
      } catch (e) {
        context.loaderOverlay.hide(); // Hide loading overlay on error
        showSnackbar("Error",
            "Server did not respond. Please check your connection.", "error");

        print("Error: $e"); // Log the error for debugging
      } finally {
        context.loaderOverlay.hide(); // Hide loading overlay
      }
    } else {
      context.loaderOverlay.hide();
      // Optionally provide feedback for validation errors
      showSnackbar("Warning", "Please fill in all required fields correctly.",
          "warning");
    }
  }
}
