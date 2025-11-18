import 'dart:convert';
import 'package:cutomer_app/APIs/BaseUrl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RelationDropdown extends StatefulWidget {
  const RelationDropdown({super.key});

  @override
  State<RelationDropdown> createState() => _RelationDropdownState();
}

class _RelationDropdownState extends State<RelationDropdown> {
  List<Map<String, dynamic>> allRelations = [];
  Map<String, dynamic>? selectedRelation;

  @override
  void initState() {
    super.initState();
    fetchRelations();
  }

  Future<void> fetchRelations() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');
    var apiUrl = '${registerUrl}/bookings/byRelation/${customerId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded["data"] as Map<String, dynamic>;

        // Flatten all relation groups (Self, Brother, Sister, etc.)
        List<Map<String, dynamic>> tempList = [];
        data.forEach((key, value) {
          if (value is List) {
            for (var item in value) {
              tempList.add({
                "relation": item["relation"],
                "fullname": item["fullname"],
                "mobileNumber": item["mobileNumber"],
                "age": item["age"],
                "address": item["address"],
                "gender": item["gender"],
              });
            }
          }
        });

        setState(() {
          allRelations = tempList;
        });
      } else {
        debugPrint("❌ Failed to load: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching relations: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Relation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: allRelations.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<Map<String, dynamic>>(
                decoration: const InputDecoration(
                  labelText: "Select Relation",
                  border: OutlineInputBorder(),
                ),
                value: selectedRelation,
                items: allRelations.map((relation) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: relation,
                    child: Text(
                        "${relation["fullname"]} (${relation["relation"]})"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedRelation = value);
                  debugPrint("✅ Selected: ${value?["fullname"]}");
                  debugPrint("📞 Mobile: ${value?["mobileNumber"]}");
                  debugPrint("🏠 Address: ${value?["address"]}");
                },
              ),
      ),
    );
  }
}
