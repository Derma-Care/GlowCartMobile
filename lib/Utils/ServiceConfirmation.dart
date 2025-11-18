import 'package:flutter/material.dart';

class Serviceconfirmation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Surecare',
        style: TextStyle(
          color: const Color.fromARGB(255, 6, 96, 170),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Are you sure you want to cancel the service?',
          style: TextStyle(fontSize: 14),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              // Adjust width for the button
              height: 40, // Adjust height for the button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 161, 14, 3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  textStyle: TextStyle(fontSize: 14), // Adjust font size
                ),
                onPressed: () {
                  // Add cancel action here
                  Navigator.of(context).pop();
                },
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Container(
              // Adjust width for the button
              height: 40, // Adjust height for the button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6B3FA0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  textStyle: TextStyle(fontSize: 14), // Adjust font size
                ),
                onPressed: () {
                  // Add confirm action here
                  Navigator.of(context).pop();
                },
                child: Text(
                  'CONFIRM',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Usage example:
// Show this dialog using showDialog method in your widget

