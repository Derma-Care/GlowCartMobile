import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/Services/serviceb.dart';
import 'package:http/http.dart' as http;

Future<void> fetchUserServices(
    Function setState, bool isLoading, List<Serviceb> services) async {
  try {
    print("Starting API call to fetch services...");

    final response = await http.get(Uri.parse(categoryUrl)); // Replace with actual URL
    print("API call completed. Status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Response data: $data");

      // Check if data is a list of maps
      if (data is List) {
        setState(() {
          services.clear(); // Clear previous data before adding new ones
          services.addAll(
            data.map((serviceData) {
              print('categoryId: ${serviceData['categoryId']}');
              return Serviceb.fromJson({
                'categoryId': serviceData['categoryId'] ?? '',
                'categoryName': serviceData['categoryName'] ?? '',
                'categoryImage': serviceData['categoryImage'] ?? '',
              });
            }).toList(),
          );
          isLoading = false; // Hide the loading indicator
        });
        print("Services fetched and updated successfully.");
      } else {
        print("Error: Expected a list of services but got a different format.");
        // Handle this error appropriately
      }
    } else {
      print("API call failed with status: ${response.statusCode}");
      // Handle non-200 status codes
    }
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    print("Error fetching services data: $e");
  }
}
