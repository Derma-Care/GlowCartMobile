import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../Utils/ShowSnackBar.dart';

// import 'BaseUrl.dart';

class LoginApiService {
  final String endpoint = "customers/login";
  //  'registerOrLogin'; //VerifyUserCredentialsAndGenerateAndSendOtp

  Future<Map<String, dynamic>> sendUserDataWithFCMToken(
      String fullname, String mobileNumber, String token) async {
    print("response for fullname ${fullname}");
    print("response for mobileNumber ${mobileNumber}");

    try {
      if (token == null) {
        print("FCM Token is null. Cannot send data.");
        return {'error': 'FCM Token is null. Cannot send data.'};
      }

      final body = {
        'userName': fullname,
        'password': mobileNumber,
        'deviceId': token,
      };

      print("body.toString() : ${body.toString()}");
      print("loginUrl : $clinicUrl/$endpoint");

      // Send user data and FCM token to backend
      final response = await http.post(
        Uri.parse('$clinicUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userName': fullname,
          'password': mobileNumber,
          'deviceId': token,
        }),
      );

      print("response for statusCode ${response.statusCode}");
      print("response for statusCode body ${response.body}");
      print("response for statusCode body ${body}");

      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("response for login $decoded");

        return decoded;
      } else {
        showSnackbar("Error", "${decoded['message']}", "error");
        return {'error': '${decoded['message']}'};
      }
    } catch (e) {
      showSnackbar("Error", "server not respond", "error");
      return {'error': 'An error occurred: $e'};
    }
  }
}
