import 'dart:convert';
import 'package:http/http.dart' as http;
import 'AboutClinicModel.dart';
import '../APIs/BaseUrl.dart';

class ClinicService {
  Future<Clinic> getClinic(String hospitalId) async {
    final url = '$clinicUrl/getClinic/$hospitalId';
    print("getClinic url: $url");

    final response = await http.get(Uri.parse(url));

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);

      // ✅ Adjust if your API has `data` key
      final clinicJson = jsonBody['data'] ?? jsonBody;

      return Clinic.fromJson(clinicJson);
    } else {
      throw Exception('Failed to load clinic data');
    }
  }
}
