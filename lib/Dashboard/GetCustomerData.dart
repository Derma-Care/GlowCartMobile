// api_service.dart
import 'dart:convert';
import 'package:cutomer_app/Customers/GetCustomerModel.dart';
import 'package:http/http.dart' as http;
import 'package:cutomer_app/APIs/BaseUrl.dart'; // Make sure this is correct

// Define the API call function
Future<GetCustomerModel> fetchUserData(String customerId) async {
  try {
    final response = await http.get(
      Uri.parse('$clinicUrl/customers/$customerId'),
    );
    print("Response Data statusCode url: $clinicUrl/customers/$customerId");
    print("Response Data statusCode: ${response.statusCode}");

    if (response.statusCode == 200) {
      // Decode the response body
      final responseData = json.decode(response.body);

      // Print the entire response data for debugging
      print("Response Data useradat: $responseData");

      // Return the decoded data as a GetCustomerModel instance
      return GetCustomerModel.fromJson(responseData);
    } else {
      throw Exception('Failed to load user data');
    }
  } catch (e) {
    print("Error fetching user data: $e");
    throw Exception('Error fetching user data');
  }
}
