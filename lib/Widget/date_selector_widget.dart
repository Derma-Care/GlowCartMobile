import 'package:cutomer_app/Doctors/Schedules/DoctorSlotService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Doctors/Schedules/ScheduleController.dart';
import '../Utils/Constant.dart';

class DateSelectorWidget extends StatelessWidget {
  final ScrollController scrollController;
  final ScheduleController scheduleController;
  final String doctorId;
  final String branchId;

  const DateSelectorWidget({
    super.key,
    required this.scrollController,
    required this.scheduleController,
    required this.doctorId,
    required this.branchId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ Display selected date in yyyy-MM-dd format
        Obx(() {
          final selectedDate = scheduleController.selectedDate.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              selectedDate != null
                  ? "Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"
                  : "Select a Date",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          );
        }),

        // ✅ Horizontal date list
        SizedBox(
          height: 70,
          child: ListView.builder(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: scheduleController.weekDates.length,
            itemBuilder: (context, index) {
              final date = scheduleController.weekDates[index];

              return Obx(() {
                final isSelected =
                    index == scheduleController.selectedDayIndex.value;

                return GestureDetector(
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final hospitalId = prefs.getString('hospitalId')!;
                    final slots = await DoctorSlotService.fetchDoctorSlots(
                      doctorId,
                      hospitalId,
                      branchId,
                    );
                    scheduleController.selectDate(date, slots);
                  },
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? mainColor : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: mainColor),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('dd').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : mainColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat('E').format(date).toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : mainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }
}
