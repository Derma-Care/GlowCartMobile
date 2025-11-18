import 'dart:convert';
import 'package:cutomer_app/Booings/FollowUpModal.dart';
import 'package:http/http.dart' as http;

import '../APIs/BaseUrl.dart';
import '../BottomNavigation/Appoinments/AppointmentController.dart';
import '../BottomNavigation/Appoinments/PostBooingModel.dart';

Future<Map<String, dynamic>?> postBookings(
    PostBookingModel bookingDetails) async {
  final Url = Uri.parse(BookingUrl); // Replace with your endpoint
  print("response.body Url: ${Url}");

  try {
    final response = await http.post(
      Url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bookingDetails.toJson()),
    );
    print("response.body....: ${response.body}");
    print("response.body....: ${jsonEncode(bookingDetails.toJson())}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Booking posted successfully!');
      print("response.body....: ${response.body}");

      return jsonDecode(response.body); // Return response data
    } else {
      print('Failed to post booking. Status code: ${response.statusCode}');
      return null; // Return null in case of failure
    }
  } catch (e) {
    print("Error posting booking: $e");
    return null; // Return null in case of error
  }
}

Future<Map<String, dynamic>?> followUpBookings(
    FollowUpModal bookingDetails) async {
  final url = Uri.parse(BookingUrl);
  print("request Url: $url");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bookingDetails.toJson()),
    );

    print("response.body....: ${response.body}");
    print("request payload....: ${jsonEncode(bookingDetails.toJson())}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Booking posted successfully!');
      // decode body to Map
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData;
    } else {
      print('Failed to post booking. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print("Error posting booking: $e");
    return null;
  }
}

Future<Map<String, dynamic>?> updateConsentForm(
    Map<String, dynamic> bookingDetails) async {
  final String url = '${clinicUrl}/updateAppointmentBasedOnBookingId';
  print('Request URL: $url');
  print('Request payload: $bookingDetails');

  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(bookingDetails), // ✅ Encode Dart map to JSON
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body); // ✅ Parse JSON response
    } else {
      print('Failed to update consent form: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error updating consent form: $e');
    return null;
  }
}

// Future<bool> updateConsentForm({
//   required String bookingId,
//   required String consentPdfBase64, // <-- use String instead of Uint8List
// }) async {
//   final url = Uri.parse(BookingUrl);
//   print("Request URL: $url");

//   try {
//     // Build request payload
//     final payload = {
//       "bookingId": bookingId,
//       "consentFormPdf": consentPdfBase64,
//     };

//     final response = await http.put(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(payload),
//     );

//     if (response.statusCode == 200) {
//       print("Consent form updated successfully");
//       return true;
//     } else {
//       print("Failed to update consent form: ${response.statusCode}");
//       print("Response body: ${response.body}");
//       return false;
//     }
//   } catch (e) {
//     print("Error updating consent form: $e");
//     return false;
//   }
// }

Future<List<Map<String, dynamic>>> getBookingsByMobileNumber(
    String mobileNumber) async {
  print("dshffdfjsd ${mobileNumber}");
  // final String mobileNumber = "7842259802";
  final url = Uri.parse(
      '$BookingUrl/$mobileNumber'); // Adjust param name as per your API

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("expected response format: $data");

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("Unexpected response format: $data");
        return [];
      }
    } else {
      print("Failed to fetch bookings. Status code: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("❌ Error fetching bookings: $e");
    return [];
  }
}

// Future<List<BookingDetailsModel>> getDetailByDoctorId(String doctorId) async {
//   final url = Uri.parse('http://$wifiUrl:3000/bookings?doctorId=$doctorId');

//   try {
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       return data.map((json) => BookingDetailsModel.fromJson(json)).toList();
//     } else {
//       print("❌ Error: ${response.statusCode}");
//       return [];
//     }
//   } catch (e) {
//     print("❌ Exception: $e");
//     return [];
//   }
// }
