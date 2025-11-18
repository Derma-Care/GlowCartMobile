import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DateInputFormatter extends TextInputFormatter {
  final int maxYear = DateTime.now().year;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll('/', '');

    if (text.length > 8) text = text.substring(0, 8);

    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);

      if ((i == 1 || i == 3) && i != text.length - 1) {
        buffer.write('/');
      }
    }

    String formatted = buffer.toString();
    List<String> parts = formatted.split('/');

    // Validate parts
    if (parts.length >= 1 && parts[0].length == 2) {
      int day = int.tryParse(parts[0]) ?? 0;
      if (day > 31 || day < 1) {
        return oldValue; // Invalid day
      }
    }

    if (parts.length >= 2 && parts[1].length == 2) {
      int month = int.tryParse(parts[1]) ?? 0;
      if (month > 12 || month < 1) {
        return oldValue; // Invalid month
      }
    }

    if (parts.length == 3 && parts[2].length == 4) {
      int year = int.tryParse(parts[2]) ?? 0;
      if (year > maxYear) {
        return oldValue; // Year in the future
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
