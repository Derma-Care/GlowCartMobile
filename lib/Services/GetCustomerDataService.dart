import 'dart:convert';

import '../APIs/BaseUrl.dart';

import 'package:http/http.dart' as http;

class CustomerDataBasicInfo {
  // Change return type to Future<Map<String, dynamic>> since you're returning parsed JSON
  Future<Map<String, dynamic>?> fetchCustomerDataData(String mobileNumber) async {
    String url = "$serverUrl/admin/getBasicCustomerDetails/$mobileNumber";
    print("Requesting: $url");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print("Response Status provider: ${response.statusCode}");
      print("Response Body provider: ${response.body}");

      if (response.statusCode == 200) {
        // Parse and return the data if the response is successful
        final data = jsonDecode(response.body);
        return data; // Return the data as a map
      } else {
        print("Error: ${response.reasonPhrase}");
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print("Exception caught: $e");
      return null; // Return null if an exception occurs
    }
  }
}
