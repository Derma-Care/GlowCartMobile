// report_controller.dart
import 'package:cutomer_app/Utils/ShowSnackBar%20copy.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ReportController extends GetxController {
  var selectedIssues = <String>[].obs;
  TextEditingController detailsController = TextEditingController();

  void toggleIssue(String issue) {
    if (selectedIssues.contains(issue)) {
      selectedIssues.remove(issue);
    } else {
      selectedIssues.add(issue);
    }
  }

  void submitReport() {
    final issues = selectedIssues.join(', ');
    final details = detailsController.text.trim();

    Get.back(); // Close bottom sheet

    // ✅ Show toast/snackbar
    showSnackbar(
        "Submitted Report", "Issues: $issues\nDetails: $details", "success");

    // ✅ Clear selections
    selectedIssues.clear();
    detailsController.clear();
  }
}
