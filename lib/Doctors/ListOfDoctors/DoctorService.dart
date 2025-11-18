// import 'dart:convert';

// import 'package:http/http.dart' as http;

// import '../../APIs/BaseUrl.dart';
// import 'DoctorModel.dart';

// // class DoctorService {
// //   String url = "http://192.168.1.6:3000/doctors";

// class DoctorService {
//   String url =
//       "http://${wifiUrl}:3000/services"; // 👈 Use emulator/real device IP

//   Future<List<ServiceModel>> fetchServices() async {
//     print("Calling fetchServices...");

//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         print("Retrieved successfully...");
//         List<dynamic> jsonData = jsonDecode(response.body);
//         return jsonData
//             .map((item) => ServiceModel.fromJson(item))
//             .toList();
//       } else {
//         return Future.error('Error: ${response.statusCode}');
//       }
//     } catch (e, s) {
//       print('Exception: $e');
//       print('StackTrace: $s');
//       return Future.error('Failed to fetch data: $e');
//     }
//   }

//   Future<ServiceModel?> getDoctorById(String doctorId) async {
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         List<dynamic> jsonData = jsonDecode(response.body);

//         var doctorJson = jsonData.firstWhere(
//           (item) => item['id'] == doctorId,
//           orElse: () => null,
//         );

//         if (doctorJson != null) {
//           final doctor = ServiceModel.fromJson(doctorJson);

//           // ✅ Print doctor details
//           print("✅ Doctor Found:");
//           print("ID: ${doctor.id}");
//           print("Name: ${doctor.doctor.name}");
//           print("Specialization: ${doctor.doctor.specialization}");
//           print("Hospital: ${doctor.hospital.name}");
//           print("City: ${doctor.hospital.city}");

//           return doctor;
//         } else {
//           print("❌ Doctor with ID $doctorId not found.");
//           return null;
//         }
//       } else {
//         throw Exception('Failed to load data: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("❌ Error in getDoctorById: $e");
//       return null;
//     }
//   }
// }

// // }

import 'dart:convert';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../APIs/BaseUrl.dart';
import 'DoctorController.dart';

class DoctorService {
  Future<List<HospitalDoctorModel>> fetchDoctorsAndClinic(
      String hospitalId, String subServiceId, String branchId) async {
    print('📡  hospitalId & subServiceId ${hospitalId}, ${subServiceId}');
    final url =
        '$registerUrl/getDoctorsAndClinicDetails/$hospitalId/$subServiceId';
    final curl =
        '$registerUrl/getDoctorsAndClinicDetailsByBranchId/$hospitalId/$branchId/$subServiceId';
    print('📡  GET $url');
    print('📡  GET $curl');

    final res = await http.get(Uri.parse(curl));

    if (res.statusCode != 200) {
      throw Exception('Server error: ${res.statusCode}');
    }

    // --- Decode safely
    late final dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (e) {
      throw FormatException('Response is not valid JSON: $e');
    }

    // --- Normalise to a map that has clinic + doctors -------------------------
    Map<String, dynamic>? root;

    if (decoded is Map<String, dynamic>) {
      // Case 1 or 2
      root = decoded.containsKey('data')
          ? decoded['data'] as Map<String, dynamic>?
          : decoded;
    } else if (decoded is List && decoded.isNotEmpty) {
      // Case 3 – take the first element or merge as you wish
      root = decoded.first as Map<String, dynamic>?;
    }

    if (root == null) {
      throw FormatException(
          'Unexpected payload format – expected an object with clinic & doctors');
    }

    final clinicJson = root['clinic'];
    final doctorsJson = root['doctors'];

    if (clinicJson == null) {
      throw FormatException('Key "clinic" missing in response.');
    }
    if (doctorsJson is! List) {
      throw FormatException('Key "doctors" is not a list.');
    }

    // --- Build models ---------------------------------------------------------
    final doctors = doctorsJson
        .map<HospitalDoctorModel>(
            (doc) => HospitalDoctorModel.fromJson(doc, clinicJson))
        .toList();

    print('📊 Parsed ${doctors.length} doctors.');
    return doctors;
  }

  Future<Map<String, dynamic>?> fetchDoctorByDoctorId(String doctorId) async {
    final url = Uri.parse('${clinicUrl}/doctor/$doctorId');
    print("🔍 [fetchDoctorByDoctorId] Fetching from URL: $url");

    final response = await http.get(url);
    print("📥 [fetchDoctorByDoctorId] Response Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ [fetchDoctorByDoctorId] Response Body: ${data['data']}");
      return data['data'];
    } else {
      print(
          "❌ [fetchDoctorByDoctorId] Failed to fetch doctor. Body: ${response.body}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchclinicByClinicId(String hospitalId) async {
    final url = '${clinicUrl}/getClinic/$hospitalId';
    print("Fetching clinic data from URL: $url");

    final response = await http.get(Uri.parse(url));

    print("Response status code: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Response fetchclinicByClinicId body: ${data['data']}");
      return data['data'];
    } else {
      print("Failed to fetch clinic data. Status code: ${response.statusCode}");
      return null;
    }
  }
}
