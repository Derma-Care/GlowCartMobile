// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:flutter/material.dart';

import 'package:cutomer_app/Doctors/Schedules/consent_form_model.dart';
import 'package:cutomer_app/Utils/Header.dart';

class UserDataConsentScreen extends StatelessWidget {
  final String patientname;
  const UserDataConsentScreen({
    Key? key,
    required this.patientname,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: "Patient Data Privacy",
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "Consent for Collection and Use of Medical Information",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                        "“I, ${capitalizeEachWord(patientname)}, hereby give my voluntary and informed consent for the collection, storage, and use of my medical records, personal health information, and diagnostic images for purposes including research, education, training, and improving medical services. I understand that all information will be handled in accordance with applicable privacy laws and regulations, and that my identity will be protected unless I provide separate written authorization. I acknowledge that participation is voluntary and that I may withdraw my consent at any time, without affecting the medical care I receive.”"),
                  ],
                ),
              ),
              // ✅ Note above FAB
              SizedBox(
                height: 20,
              ),
              TextButton(
                  onPressed: () => Navigator.pop(context), child: Text("Back")),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Navigator.pop(context),
      //   backgroundColor: Colors.blueAccent,
      //   child: const Icon(Icons.arrow_back, color: Colors.white),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
