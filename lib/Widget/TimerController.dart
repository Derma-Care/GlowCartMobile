import 'package:cutomer_app/BottomNavigation/BottomNavigation.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerController extends GetxController {
  final Map<String, RxInt> remainingSecondsMap = {};
  Timer? _timer;

  void startTimer({
    required String doctorId,
    required String slot,
    required BuildContext context, // Pass context for navigation
  }) {
    final key = "$doctorId-$slot";

    // Reset timer for new slot
    remainingSecondsMap[key] = 120.obs;

    // Cancel existing timer
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (remainingSecondsMap[key]!.value > 0) {
        remainingSecondsMap[key]!.value--;
      } else {
        _timer?.cancel();
        // Navigate to BottomNavController after 2 minutes
        final prefs = await SharedPreferences.getInstance();

        if (context.mounted) {
          var username = await prefs.getString('customerName');
          var mobileNumber = await prefs.getString('mobileNumber');
          ScaffoldMessageSnackbar.show(
              context: context,
              message:
                  "⏰ Time is up! $username, your session has ended. Navigating to home.",
              type: SnackbarType.warning);
          await Future.delayed(const Duration(seconds: 3));
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (_) => BottomNavController(
                      mobileNumber: mobileNumber!,
                      username: username!,
                      index: 0,
                    )),
            (route) => false,
          );
        }
      }
    });
  }

  RxInt getRemainingSecondsRx(String doctorId, String slot) {
    final key = "$doctorId-$slot";
    if (!remainingSecondsMap.containsKey(key)) {
      remainingSecondsMap[key] = 0.obs;
    }
    return remainingSecondsMap[key]!;
  }

  void stopTimer(String doctorId, String slot) {
    final key = "$doctorId-$slot";
    remainingSecondsMap[key]?.value = 0;
    _timer?.cancel();
  }
}
