import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cutomer_app/APIs/BaseUrl.dart';
import '../BottomNavigation/Appoinments/BookingModal.dart';
import '../Toasters/Toaster.dart';

class AppointmentAPI {
  Future<List<AppointmentData>> fetchAppointments(String mobileNumber) async {
    print("Fetching appointments for mobile number: $mobileNumber");
    final url = '$registerUrl/getBookedServices/$mobileNumber';
// getBookedServices
    try {
      // Make the GET request
      final response = await http.get(Uri.parse(url));
      print("Response status code: ${response.statusCode}");

      // Check the body of the response before proceeding
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          // Parse the response data if status code is 200
          final Map<String, dynamic> responseData = json.decode(response.body);

          // Check if the 'data' key exists in the response
          if (responseData.containsKey('data')) {
            final List<dynamic> data = responseData['data'] ?? [];
            print("Booking Data: $data");

            // Map the data to a list of Appointment objects
            List<AppointmentData> allAppointments = data.map((json) {
              return AppointmentData(
                appointmentId: json['appointmentId'],
                patientName: json['patientName'],
                relationShip: json['relationShip'],
                patientNumber: json['patientNumber'],
                gender: json['gender'],
                emailId: json['emailId'],
                age: json['age'],
                customerNumber: json['customerNumber'],
                categoryName: json['categoryName'],
                servicesAdded: (json['servicesAdded'] as List)
                    .map((item) => ServiceAdded.fromJson(item))
                    .toList(),
                totalPrice: json['totalPrice'],
                totalDiscountAmount: json['totalDiscountAmount'],
                totalTax: json['totalTax'],
                payAmount: json['payAmount'],
                bookedAt: json['bookedAt'],
                totalDiscountedAmount: json['totalDiscountedAmount'],
              );
            }).toList();

            print("Appointments fetched: $allAppointments");

            // Return the list of appointments to be used elsewhere
            return allAppointments;
          } else {
            print("Error: 'data' key not found in the response.");
            showErrorToast(msg: "No appointments data found.");
            return [];
          }
        } catch (e) {
          // This will catch errors related to the JSON decoding or mapping
          print('Error during JSON parsing: $e');
          showErrorToast(msg: "Failed to parse appointment data");
          return [];
        }
      } else {
        print('Error: ${response.reasonPhrase}');
        showErrorToast(
            msg: "Failed to fetch appointments: ${response.reasonPhrase}");
        return [];
      }
    } catch (e) {
      // This will catch network errors or any other issues
      print('Failed to fetch appointments: $e');
      showErrorToast(msg: "Server not responding");
      return [];
    }
  }
}
