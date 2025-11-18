import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/DotorRef/RefDoctorModal.dart';
import 'package:http/http.dart' as http;

class RefDoctorService {
  final String apiUrl = "${clinicUrl}/getAllReferralDoctors";

  Future<List<RefDoctor>> fetchDoctors() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response status: ${response.statusCode}");
      print("Raw response body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print("Raw response body length 234: ${jsonResponse.toString()}");

        // Ensure 'data' exists and is a List
        if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
          final doctors = (jsonResponse['data'] as List)
              .map((doc) => RefDoctor.fromJson(doc))
              .toList();

          print("Raw response body length: ${doctors.length}");

          return doctors;
        }

        return [];
      } else {
        print("Error fetching doctors: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Exception fetching doctors: $e");
      return [];
    }
  }
}
