import 'dart:convert';
import 'package:cutomer_app/SubserviceAndHospital/HospitalCardModel.dart';
import 'package:http/http.dart' as http;
import 'package:cutomer_app/APIs/BaseUrl.dart';

class HospitalService {
  Future<List<HospitalCardModel>> fetchHospitalCards(
      String hospitalID, String subServiceId, double lat, double long) async {
    final url = Uri.parse(
        '$registerUrl/getBranchesInfoBySubServiceId/$hospitalID/$subServiceId/$lat/$long');
    print('📤 Sending GET request to: $url');

    try {
      final response = await http.get(url);
      print('📥 Response status: ${response.statusCode}');

      final decoded = json.decode(response.body);
      print('🔓 Full Decoded Response Type: ${decoded.runtimeType}');
      print('🔓 Full Decoded Response Content: $decoded');

      if (response.statusCode == 200) {
        // ✅ Your API returns `data` as a Map, not a List
        if (decoded is Map && decoded.containsKey('data')) {
          final Map<String, dynamic> data = decoded['data'];
          print('📦 Single hospital object found');

          List<HospitalCardModel> result = [];

          String base64Logo = '';
          try {
            final logo = data['hospitalLogo'] ?? '';
            if (logo.startsWith('http')) {
              final imageResponse = await http.get(Uri.parse(logo));
              final contentType = imageResponse.headers['content-type'] ?? '';
              if (imageResponse.statusCode == 200 &&
                  contentType.startsWith('image/')) {
                base64Logo = base64Encode(imageResponse.bodyBytes);
              } else {
                print('⚠️ Invalid image content from URL: $logo');
              }
            } else if (logo.length > 100) {
              base64Logo = logo;
            } else {
              print('⚠️ Invalid logo format or too short: $logo');
            }
          } catch (imgErr) {
            print('❌ Error handling logo: $imgErr');
          }

          // Print hospital info for debugging
          print("🏥 Hospital Name: ${data['hospitalName']}");
          print("📍 Branch Count: ${(data['branches'] as List?)?.length ?? 0}");
          if (data['branches'] != null) {
            for (var branch in data['branches']) {
              print("  🔗 Branch Name: ${branch['branchName']}");
              print("  🌐 Virtual Tour: ${branch['virtualClinicTour']}");
            }
          }

          // ✅ Build HospitalCardModel using your model
          result.add(HospitalCardModel.fromJson({
            ...data,
            "hospitalLogo": base64Logo,
          }));

          return result;
        } else {
          print('⚠️ API response does not have a valid "data" object.');
          throw Exception('Unexpected API response format: $decoded');
        }
      } else {
        final errorMsg = decoded['message'] ?? 'Failed to load hospital data.';
        print('❌ Backend message: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('🔥 Exception caught: $e');
      throw Exception('Error fetching hospital data: ${e.toString()}');
    }
  }
}
