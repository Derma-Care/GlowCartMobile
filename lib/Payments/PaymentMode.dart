import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/CustomerController.dart';

class PaymentModeSelector extends StatelessWidget {
  final String consultationType;

  const PaymentModeSelector({
    super.key,
    required this.consultationType,
  });

  List<String> getAvailableOptions() {
    final type = consultationType.toLowerCase();
    if (type == 'online consultation' || type == 'video consultation') {
      return ['Online'];
    } else {
      return ['Pay at Hospital', 'Online'];
    }
  }

  IconData getIconForOption(String option) {
    switch (option.toLowerCase()) {
      case 'pay at hospital':
        return Icons.local_hospital;
      case 'online':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SelectedServicesController>();
    final options = getAvailableOptions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 12.0, bottom: 8, top: 16),
          child: Text(
            "Select Payment Mode",
            style: TextStyle(
              color: mainColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // centers horizontally
              children: options.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0), // gap between
                  child: Obx(() {
                    final isSelected =
                        controller.selectedPayment.value == option;
                    return GestureDetector(
                      onTap: () => controller.setPayment(option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected ? mainColor : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: mainColor.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                          ],
                          color:
                              isSelected ? Colors.white : Colors.grey.shade50,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              getIconForOption(option),
                              color: isSelected ? mainColor : Colors.grey,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              option,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? mainColor
                                    : Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected ? mainColor : Colors.grey,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
