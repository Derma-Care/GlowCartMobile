import 'package:flutter/material.dart';

class DialogHelper {
  static Future<void> showVerificationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Icon with a checkmark
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F7EF), // Light green background
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF3AB96B), // Green check icon color
                  size: 50.0,
                ),
              ),
              const SizedBox(height: 16.0), // Space between the icon and text
          
              // "Mobile number verified!" message
              const Text(
                "Mobile number verified!",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E357B), // Purple text color
                ),
              ),
              const SizedBox(height: 8.0),
          
              // Thank you message
              Text(
                "Thank you for confirming your contact details.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600], // Lighter grey color
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
