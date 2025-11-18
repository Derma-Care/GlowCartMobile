import 'dart:convert';
import 'dart:typed_data';
import '../Modals/ServiceModal.dart';
import 'BaseUrl.dart';
import 'package:http/http.dart' as http;

class ServiceFetcher {
  Future<List<Service>> fetchServices(String categoryId) async {
    print("🔄 Sending request to categoryId: $categoryId");

    final url = '$getServiceByCategoriesID/$categoryId';

    try {
      print("🔄 Sending request to URL: $url");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print("📦 API response status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 302) {
        final decodedResponse = json.decode(response.body);
        print("🧩 Decoded JSON: $decodedResponse");

        if (decodedResponse['data'] is List) {
          final List<dynamic> data = decodedResponse['data'];
          print("✅ Data length: ${data.length}");

          return data.map<Service>((json) {
            try {
              return Service.fromJson(json);
            } catch (e) {
              print("❌ Error parsing service: $e");
              return Service(
                serviceId: '',
                serviceName: '',
                categoryName: '',
                categoryId: '',
                description: '',
                serviceImage: Uint8List(0),
              );
            }
          }).toList();
        } else {
          print('❗ Error: "data" is not a list');
          return [];
        }
      } else {
        print('❗ Error: ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      print('❌ Exception fetching services: $e');
      return [];
    }
  }

  Future<List<SubServiceAdmin>> fetchsubServices(String serviceId) async {
    final url = '$getSubServiceByServiceID/$serviceId';
    print("🔄 Sending request to URL: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("📦 Response status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 302) {
        final decodedResponse = json.decode(response.body);
        final List<dynamic> data = decodedResponse['data'];

        if (data != null && data is List) {
          // Flatten subServices from each category object
          final allSubServices = data
              .expand((category) => category['subServices'] as List<dynamic>)
              .map((json) {
                try {
                  return SubServiceAdmin.fromJson(json);
                } catch (e) {
                  print("❌ Parse error: $e");
                  return null;
                }
              })
              .whereType<SubServiceAdmin>()
              .toList();

          return allSubServices;
        } else {
          print("❗ 'data' is not a list");
          return [];
        }
      } else {
        print("❗ HTTP error: ${response.reasonPhrase}");
        return [];
      }
    } catch (e) {
      print("❌ Exception during fetch: $e");
      return [];
    }
  }
}
