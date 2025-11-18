import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void _selectDate(BuildContext context) async {
  // Configure the dialog to avoid overflow issues
  List<DateTime?>? selectedDates = await showCalendarDatePicker2Dialog(
    useSafeArea: true,
    context: context,
    config: CalendarDatePicker2WithActionButtonsConfig(
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(Duration(days: 6570)), // 18 years back
      calendarType: CalendarDatePicker2Type.single,
      animateToDisplayedMonthDate: true,
      controlsHeight: 50, // Control height adjustment
      dayTextStyle: const TextStyle(fontSize: 14), // Reduce day font size
      selectedDayTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      selectedDayHighlightColor: Colors.deepPurple,
      centerAlignModePicker: true, // Center-align controls in picker
    ),
    dialogSize: const Size(
        double.infinity, 350), // Adjust dialog size to avoid overflow
    value: [
      DateTime.now().subtract(Duration(days: 6570))
    ], // Default initial date
  );
}
