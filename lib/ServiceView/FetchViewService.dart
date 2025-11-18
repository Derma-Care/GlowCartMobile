import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ServiceDetail.dart';

class ApiService {
  Future<ServiceDetails?> fetchServiceDetails() async {
    final response = await http.get(Uri.parse(
        'https://example.com/api/service_details')); // Replace with actual API URL

    if (response.statusCode == 200) {
      print("API Response: ${response.body}"); // Log the response body
      return ServiceDetails.fromJson(json.decode(response.body));
    } else {
      print(
          'Failed to load service details with status code: ${response.statusCode}');
      return null;
    }
  }
}
