// In your utility or UI file
import 'package:flutter/material.dart';

const Color mainColorSheet = Colors.blue; // Replace with your actual app color

void showReportBottomSheet({
  required BuildContext context,
  required String title,
  required List<ReportOption> options,
  void Function(String selected)? onSelected,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: mainColorSheet,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            ...options.map((option) => GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelected != null) {
                      onSelected(option.title);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 20,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: option.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            option.title,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}
// ReportOption.dart

class ReportOption {
  final String title;
  final Color color;

  ReportOption({required this.title, required this.color, required IconData icon});
}
