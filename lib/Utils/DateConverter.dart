import 'package:intl/intl.dart';

String formatDate(String date) {
  try {
    final parsedDate = DateFormat("dd-MM-yyyy").parse(date);
    return DateFormat("dd MMM yyyy").format(parsedDate);
  } catch (e) {
    print("Date parsing error: $e");
    return "Invalid Date";
  }
}

DateTime parseDate(String dateStr) {
  // Define the date format as 'dd-MM-yyyy'
  DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  return dateFormat.parse(dateStr); // Parse the string into DateTime
}

String formatDateTime(String date) {
  DateTime parsedDate;
  try {
    // Convert the input to uppercase to handle both lowercase and uppercase AM/PM correctly
    String formattedDateInput = date.toUpperCase();

    // Parse the date string with both date and time (dd-MM-yyyy hh:mm:ss a format)
    parsedDate = DateFormat('dd-MM-yyyy hh:mm:ss a').parse(formattedDateInput);
  } catch (e) {
    // If the date format is incorrect, return an error
    return "Invalid date format";
  }

  // Format the date and time in the desired format (including AM/PM)
  String formattedDateTime =
      DateFormat('EE, dd MMMM yyyy, hh:mm a').format(parsedDate);

  return formattedDateTime;
}

String formatTime(String time24h) {
  final parsedTime = DateFormat("HH:mm").parse(time24h); // e.g., "14:30"
  return DateFormat("h:mm a").format(parsedTime); // e.g., "2:30 PM"
}
