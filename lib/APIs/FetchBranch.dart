import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:cutomer_app/SubserviceAndHospital/HospitalCardModel.dart';
 
import 'package:http/http.dart' as http;

class BranchService {
  Future<Branch> getBranchById(String branchId) async {
    final response =
        await http.get(Uri.parse("$clinicUrl/getBranchesByClinicId/$branchId"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Branch.fromJson(data);
    } else {
      throw Exception("Failed to fetch branch");
    }
  }
}
