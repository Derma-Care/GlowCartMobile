import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/Modals/ServiceModal.dart';
import 'package:http/http.dart' as http;

Future<SubService?> fetchSubServiceDetails(
    String hospitalId, String subServiceId) async {
  final url = '$getSubServiceByServiceIDHospitalID/$hospitalId/$subServiceId';
  print('🔍 Calling: $url');

  try {
    final response = await http.get(Uri.parse(url));
    print('🔁 Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 302) {
      final decoded = json.decode(response.body);
      print('📦 Full Response JSON: $decoded');

      final data = decoded['data'];
      if (data != null) {
        print('✅ SubService Name: ${data['subServiceName']}');
        return SubService.fromJson(data);
      } else {
        print("❗ 'data' not found");
        return null;
      }
    } else {
      print('❌ HTTP error: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('❌ Exception: $e');
    return null;
  }
}
