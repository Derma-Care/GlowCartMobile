import 'dart:convert';
import 'package:cutomer_app/Toasters/Toaster.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../APIs/BaseUrl.dart';
import '../BottomNavigation/BottomNavigation.dart';
import '../Utils/ScaffoldMessageSnacber.dart';

class customerRatingService {
  // Send customer rating
  Future<Map<String, dynamic>> sendCustomerRating(
      BuildContext context,
      String appointmentId,
      String serviceId,
      int selectedRating,
      String feedback,
      String mobileNumber,
      String userName) async {
    print("Rating appointmentId: $appointmentId");
    print("Rating serviceId: $serviceId");
    print("Rating selectedRating: $selectedRating");
    print("Rating feedback: $feedback");
    print("Rating mobileNumber: $mobileNumber");

    // Construct the JSON body
    final Map<String, dynamic> requestBody = {
      "appointmentId": appointmentId,
      "serviceId": serviceId,
      "rating": selectedRating,
      "feedback": feedback,
      "customerMobileNumber": mobileNumber,
    };

    // Send the POST request
    final response = await http.post(
      Uri.parse('$serverUrl/provider-ratings/$appointmentId/$serviceId'),
      headers: {
        'Content-Type': 'application/json', // Specify JSON content type
      },
      body: json.encode(requestBody), // Encode the body as JSON
    );

    print("Rating Response code: ${response.statusCode}");
    print("Rating Response body: ${response.body}");

    // Decode the JSON response
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Successfully posted the rating
       ScaffoldMessageSnackbar.show(
      context: context,
      message:  responseData['message'],
      type: SnackbarType.error,
    );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (ctx) => BottomNavController(
            mobileNumber: mobileNumber,
            index: 0,
            username: userName,
          ),
        ),
        (route) => false, // Remove all previous routes
      );
      return responseData; // Return the decoded JSON for further use
    } else {
      // Handle error
      print("Failed to submit rating. Status code: ${response.statusCode}");
      throw Exception(responseData['error'] ??
          'Failed to submit rating'); // Use 'error' field if available
    }
  }

  Future<Map<String, dynamic>?> fetchRating(
      String serviceId, String appointmentId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$serverUrl/provider-ratings/$appointmentId/$serviceId/rating-info'),
      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Decode JSON response
        final Map<String, dynamic> data = jsonDecode(response.body);

        print('Rating Data: $data');

        // Check if the response contains the required data
        if (data['success'] == true) {
          // Extract the rating from the nested formData object
          final Map<String, dynamic>? formData = data['formData'];
          final double? rating =
              formData != null ? formData['rating'].toDouble() : null;

          // Extract customerRatingCompleted from the top-level response
          final bool customerRatingCompleted =
              data['customerRatingCompleted'] ?? false;

          // Log the extracted values
          print('Rating: $rating');
          print('Customer Rating Completed: $customerRatingCompleted');

          // Return both values in a Map
          return {
            'rating': rating,
            'customerRatingCompleted': customerRatingCompleted,
          };
        } else {
          // Handle case where no rating is found
          print('No rating found for the specified appointment and service.');
          return {
            'rating': null,
            'customerRatingCompleted': data['customerRatingCompleted'] ?? false,
          };
        }
      } else {
        // Handle non-200 status codes
        print('Failed to load data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // Handle any exceptions
      print('Error occurred while fetching the rating: $e');
      return null;
    }
  }
}
