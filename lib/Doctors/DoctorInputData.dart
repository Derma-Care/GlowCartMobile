import 'package:flutter/material.dart';

class DoctorProfileForm extends StatefulWidget {
  const DoctorProfileForm({super.key});

  @override
  State<DoctorProfileForm> createState() => _DoctorProfileFormState();
}

class _DoctorProfileFormState extends State<DoctorProfileForm> {
  final _formKey = GlobalKey<FormState>();

  // Doctor fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController qualificationController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController profileController = TextEditingController();
  final TextEditingController availableDaysController = TextEditingController();
  final TextEditingController availableTimingsController = TextEditingController();
  final TextEditingController treatmentFeeController = TextEditingController();
  final TextEditingController inClinicFeeController = TextEditingController();
  final TextEditingController videoFeeController = TextEditingController();
  final TextEditingController hospitalNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  String selectedGender = "Female";
  List<String> focusAreas = [];
  List<String> careerPath = [];
  List<String> highlights = [];
  List<String> languagesKnown = [];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        "doctor": {
          "name": nameController.text,
          "gender": selectedGender,
          "qualification": qualificationController.text,
          "specialization": specializationController.text,
          "experienceYears": int.parse(experienceController.text),
          "focusAreas": focusAreas,
          "languagesKnown": languagesKnown,
          "profile": profileController.text,
          "availableDays": availableDaysController.text,
          "availableTimings": availableTimingsController.text,
          "fee": {
            "treatmentFee": int.parse(treatmentFeeController.text),
            "inClinicFee": int.parse(inClinicFeeController.text),
            "videoConsultationFee": int.parse(videoFeeController.text),
          },
          "careerPath": careerPath,
          "highlights": highlights,
          "favorites": false,
          "status": {
            "status": "pending",
            "rejectionReason": null,
          },
          "profileImage": "URL" // You can add upload logic later
        },
        "hospital": {
          "name": hospitalNameController.text,
          "address": addressController.text,
          "city": cityController.text,
          "contactNumber": contactController.text,
        }
      };

      print("✅ Doctor Submitted:\n${data}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Doctor profile submitted successfully!")),
      );
    }
  }

  Future<void> _addToListDialog(String title, List<String> targetList) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add $title"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  targetList.add(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  Widget _chipSection(String label, List<String> list, Function() onAddPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: list.map((item) {
            return Chip(
              label: Text(item),
              onDeleted: () => setState(() => list.remove(item)),
            );
          }).toList(),
        ),
        TextButton(onPressed: onAddPressed, child: Text("Add $label"))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Profile Form")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Doctor info
              TextFormField(controller: nameController, decoration: InputDecoration(labelText: "Doctor Name"), validator: (v) => v!.isEmpty ? "Required" : null),
              DropdownButtonFormField(
                value: selectedGender,
                items: ["Male", "Female", "Other"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => selectedGender = val!),
                decoration: InputDecoration(labelText: "Gender"),
              ),
              TextFormField(controller: qualificationController, decoration: InputDecoration(labelText: "Qualification")),
              TextFormField(controller: specializationController, decoration: InputDecoration(labelText: "Specialization")),
              TextFormField(controller: experienceController, decoration: InputDecoration(labelText: "Experience (Years)"), keyboardType: TextInputType.number),
              TextFormField(controller: profileController, decoration: InputDecoration(labelText: "Doctor Bio"), maxLines: 3),
              TextFormField(controller: availableDaysController, decoration: InputDecoration(labelText: "Available Days")),
              TextFormField(controller: availableTimingsController, decoration: InputDecoration(labelText: "Available Timings")),

              // Chip sections
              SizedBox(height: 10),
              _chipSection("Focus Areas", focusAreas, () => _addToListDialog("Focus Area", focusAreas)),
              _chipSection("Languages Known", languagesKnown, () => _addToListDialog("Language", languagesKnown)),
              _chipSection("Career Path", careerPath, () => _addToListDialog("Career Path", careerPath)),
              _chipSection("Highlights", highlights, () => _addToListDialog("Highlight", highlights)),

              SizedBox(height: 10),
              // Fees
              TextFormField(controller: treatmentFeeController, decoration: InputDecoration(labelText: "Treatment Fee"), keyboardType: TextInputType.number),
              TextFormField(controller: inClinicFeeController, decoration: InputDecoration(labelText: "In-Clinic Fee"), keyboardType: TextInputType.number),
              TextFormField(controller: videoFeeController, decoration: InputDecoration(labelText: "Video Consultation Fee"), keyboardType: TextInputType.number),

              SizedBox(height: 20),
              // Hospital Info
              TextFormField(controller: hospitalNameController, decoration: InputDecoration(labelText: "Hospital Name")),
              TextFormField(controller: addressController, decoration: InputDecoration(labelText: "Address")),
              TextFormField(controller: cityController, decoration: InputDecoration(labelText: "City")),
              TextFormField(controller: contactController, decoration: InputDecoration(labelText: "Contact Number")),

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text("Submit Doctor Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
