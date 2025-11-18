import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'TimerController.dart';

class GlobalTimerFAB extends StatelessWidget {
  final String doctorId;
  final String slot;

  const GlobalTimerFAB({super.key, required this.doctorId, required this.slot});

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final timerController = Get.find<TimerController>();
    final remaining = timerController.getRemainingSecondsRx(doctorId, slot);

    return Obx(() {
      if (remaining.value <= 0) return const SizedBox.shrink();

      return Positioned(
        bottom: 20,
        right: 16,
        child: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent,
          onPressed: () {},
          icon: const Icon(Icons.timer),
          label: Text(
            formatTime(remaining.value),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );
    });
  }
}
