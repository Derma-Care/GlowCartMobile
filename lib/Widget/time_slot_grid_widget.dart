// lib/Widget/TimeSlotGridWidget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../Doctors/Schedules/ScheduleController.dart';
import '../Utils/Constant.dart';
import '../Utils/GradintColor.dart';
import '../Widget/Bottomsheet.dart';

class TimeSlotGridWidget extends StatefulWidget {
  final ScheduleController scheduleController;
  const TimeSlotGridWidget({super.key, required this.scheduleController});

  @override
  State<TimeSlotGridWidget> createState() => _TimeSlotGridWidgetState();
}

class _TimeSlotGridWidgetState extends State<TimeSlotGridWidget> {
  bool showAllRows = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.scheduleController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Available Time",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.help, size: 20),
              onPressed: () {
                showReportBottomSheet(
                  context: context,
                  title: "Slots",
                  options: [
                    ReportOption(
                        icon: Icons.block,
                        title: "Booked Slot",
                        color: Colors.grey),
                    ReportOption(
                        icon: Icons.check_circle,
                        title: "Selected Slot",
                        color: mainColor),
                    ReportOption(
                        icon: Icons.access_time,
                        title: "Available Slot",
                        color: Colors.white),
                  ],
                  onSelected: (selected) {},
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                children: [
                  SpinKitFadingCircle(color: mainColor, size: 40),
                  const SizedBox(height: 12),
                  const Text("Fetching Slots..."),
                ],
              ),
            );
          }

          if (controller.currentSlots.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "No available slots",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final totalRows = (controller.currentSlots.length / 4).ceil();
          final visibleRows =
              showAllRows ? totalRows : (totalRows > 2 ? 2 : totalRows);

          return Column(
            children: [
              ...List.generate(visibleRows, (rowIndex) {
                final start = rowIndex * 4;
                final end = (start + 4 < controller.currentSlots.length)
                    ? start + 4
                    : controller.currentSlots.length;
                final rowSlots = controller.currentSlots.sublist(start, end);

                return Row(
                  children: List.generate(4, (i) {
                    if (i >= rowSlots.length) {
                      return const Expanded(child: SizedBox(height: 48));
                    }

                    final slot = rowSlots[i];
                    final index = start + i;
                    final isBooked = slot.slotbooked;
                    final isSelected = slot.tempSelected ||
                        (index == controller.selectedSlotIndex.value);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: GestureDetector(
                          onTap: () {
                            if (!isBooked) {
                              controller.selectSlott(index, slot.slot);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? Colors.grey.shade300
                                  : isSelected
                                      ? mainColor
                                      : Colors.white,
                              border: Border.all(
                                  color: isBooked ? Colors.grey : mainColor),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              slot.slot,
                              style: TextStyle(
                                color: isBooked
                                    ? Colors.grey
                                    : isSelected
                                        ? Colors.white
                                        : mainColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
              if (totalRows > 2)
                TextButton(
                  onPressed: () => setState(() => showAllRows = !showAllRows),
                  child: Text(
                    showAllRows ? "View Less" : "View More",
                    style: TextStyle(color: mainColor),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}
