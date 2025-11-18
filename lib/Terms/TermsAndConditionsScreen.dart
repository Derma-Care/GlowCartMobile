import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: "Terms and Conditions",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms and Conditions for Pragna Advanced Skin Care',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Welcome to the Pragna Advanced Skin Care App. Please read these Terms and Conditions carefully before using the app.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24.0),
            // Section 1
            const Text(
              '1. Acceptance of Terms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'By accessing or using the Pragna Advanced Skin Care App, you agree to comply with these Terms. If you do not agree, you must uninstall the app and discontinue its use immediately.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 16.0),
            // Section 2
            const Text(
              '2. Use of the App',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'The Pragna Advanced Skin Care App is provided for personal, non-commercial use. You agree not to misuse the app or use it for unlawful purposes.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 16.0),
            // Section 3
            const Text(
              '3. Intellectual Property',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'All content, including text, graphics, and logos, is the property of Pragna Advanced Skin Care and protected under copyright laws. Unauthorized use is strictly prohibited.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 16.0),
            // Section 4
            const Text(
              '4. Disclaimer of Liability',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Pragna Advanced Skin Care is not responsible for any damages or loss resulting from the use of the app. All information is provided "as is" without warranties of any kind.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 16.0),
            // Section 5
            const Text(
              '5. Modifications to Terms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'We reserve the right to update these terms at any time. Continued use of the app signifies your agreement to the updated terms.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 24.0),
            // Footer
            const Text(
              'If you have any questions regarding these Terms and Conditions, feel free to contact our support team.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
