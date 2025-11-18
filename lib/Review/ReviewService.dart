import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/Toasters/Toaster.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;

Future<void> submitCustomerRating(
    {required double doctorRating,
    required double branchRating,
    required String feedback,
    required String branchId,
    required String doctorId,
    required String customerMobileNumber,
    required String appointmentId,
    required String hospitalId,
    required String patientId,
    required String patientName}) async {
  final url = Uri.parse('${registerUrl}/submitCustomerRating');

  final Map<String, dynamic> payload = {
    "doctorRating": doctorRating,
    "branchRating": branchRating,
    "feedback": feedback,
    "doctorId": doctorId,
    "customerMobileNumber": customerMobileNumber,
    "appointmentId": appointmentId,
    "hospitalId": hospitalId,
    "patientId": patientId,
    "patientName": patientName,
    "branchId": branchId,
  };

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );
    print('✅ Rating submitted successfully: ${payload}');
    if (response.statusCode == 200) {
      showSuccessToast(msg: "Rating submitted successfully ${doctorId}");
      print('✅ Rating submitted successfully: ${response.body}');

      // ✅ Close current screen (like .pop())
    } else {
      print('❌ Failed to submit rating: ${response.statusCode}');
      print('🔍 Response: ${response.body}');
    }
  } catch (e) {
    print('🚨 Error submitting rating: $e');
  }
}
