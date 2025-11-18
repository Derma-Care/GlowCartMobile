import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';

class ScaffoldMessageSnackbar {
  ScaffoldMessageSnackbar(BuildContext context, SnackbarType error, String s);

  // Generic method to show a snackbar with an optional left-side image
  static void show({
    required BuildContext context,
    required String message,
    required SnackbarType type,
    String subTitle = '',
    String actionLabel = "OK",
    int durationInSeconds = 5,
    String serviceName = '',
    String? imagePath, // Path for optional left-side image
    double imageSize = 32, // Size for the image
  }) {
    Color backgroundColor;
    Color textColor;
    Color iconColor;
    IconData icon;

    // Define styles based on snackbar type
    switch (type) {
      case SnackbarType.success:
        backgroundColor = mainColor;
        textColor = Colors.white;
        iconColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case SnackbarType.error:
        backgroundColor = backgroundColor = mainColor;
        ;
        textColor = Colors.white;
        iconColor = Colors.white;
        icon = Icons.error;
        break;
      case SnackbarType.warning:
        backgroundColor = backgroundColor = mainColor;
        ;
        textColor = Colors.white;
        iconColor = Colors.white;
        icon = Icons.warning;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Row(
          children: [
            // If an image path is provided, display it
            // Padding(
            //   padding: const EdgeInsets.only(right: 8.0),
            //   child: Image.asset(
            //     'assets/white_logo.png',
            //     height: imageSize,
            //     width: imageSize,
            //     fit: BoxFit.cover,
            //   ),
            // ),
            Icon(icon, color: iconColor, size: 28), // Display icon
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (serviceName.isNotEmpty)
                    Text(
                      serviceName,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  Text(
                    message,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.normal),
                  ),
                  if (subTitle.isNotEmpty)
                    Text(
                      subTitle,
                      style: TextStyle(
                          color: textColor.withOpacity(0.8), fontSize: 14),
                    ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          
        ),
        duration: Duration(seconds: durationInSeconds),
     
      ),
    );
  }
}

// Enum for snackbar types
enum SnackbarType { success, error, warning }
