import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showSnackbar(String title, String message, String type) {
  Color backgroundColor;

  switch (type) {
    case "success":
      backgroundColor = Colors.green;
      break;
    case "error":
      backgroundColor = Colors.red;
      break;
    case "warning":
      backgroundColor = Colors.blue;
      break;
    default:
      backgroundColor = Colors.grey;
  }

  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.TOP,
    backgroundColor: backgroundColor,
    colorText: Colors.white, // Ensure text is visible
    borderRadius: 8,
    margin: const EdgeInsets.all(10),
    duration: const Duration(seconds: 3),
  );
}
