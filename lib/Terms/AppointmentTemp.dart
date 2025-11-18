import 'package:flutter/material.dart';

class AppointmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Appointment Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ongoing Appointment View Start OTP
            _buildSectionTitle("Ongoing Appointment View Start OTP"),
            _buildOtpInput(context, "Start OTP"),
            const SizedBox(height: 20),

            // Job Status Feedback Capture
            _buildSectionTitle("Job Status Feedback Capture"),
            _buildFeedbackForm(context),
            const SizedBox(height: 20),

            // End Job OTP
            _buildSectionTitle("End Job OTP"),
            _buildOtpInput(context, "End OTP"),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // Handle submit logic here
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4C3C7D),
      ),
    );
  }

  // OTP Input Widget
  Widget _buildOtpInput(BuildContext context, String hint) {
    return TextField(
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        hintText: hint,
        counterText: "",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  // Feedback Form Widget
  Widget _buildFeedbackForm(BuildContext context) {
    return TextFormField(
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Enter your feedback here...",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
