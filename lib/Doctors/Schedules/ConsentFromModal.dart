import 'package:cutomer_app/Doctors/Schedules/consent_form_model.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';

class ConsentFormScreen extends StatelessWidget {
  final ConsentForm consentFormData;

  const ConsentFormScreen({Key? key, required this.consentFormData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String serviceName = consentFormData.subServiceName.isNotEmpty
        ? consentFormData.subServiceName
        : "Consent Form";
    final List<ConsentSection> sections = consentFormData.sections;

    return Scaffold(
      appBar: CommonHeader(
        title: serviceName,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index]; // ✅ Strongly typed
                final String heading = section.heading;
                final List<ConsentQuestion> questions = section.questions;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(
                      heading,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      ),
                    ),
                    children: List.generate(questions.length, (qIndex) {
                      final question = questions[qIndex]; // ✅ model
                      return ListTile(
                        leading: Icon(
                          question.answer
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: question.answer ? Colors.green : Colors.grey,
                        ),
                        title: Text(question.question),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
          // ✅ Note above FAB
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "“I hereby provide my informed consent to undergo the procedure and acknowledge that I have understood the associated pre-procedure, procedure, and post-procedure care and guidelines and the corresponding possible reactions and risks.”"),
              ),
            ),
          ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "By proceeding, you acknowledge that you have read, understood, "
                "and accepted the above consent points.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Back")),
        ],
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
