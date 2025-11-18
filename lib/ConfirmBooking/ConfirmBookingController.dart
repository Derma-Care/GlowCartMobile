// import 'package:get/get.dart';

// import '../Controller/CustomerController.dart';
// import 'ConsultationController.dart';

// class Confirmbookingcontroller extends GetxController {
//   int? consultationFee;
//   bool isProcessing = false;
//   int serviceCost = 0; // service pricing + consultation fee
//   int discountedCost = 0; // service pricing + consultation fee
//   int discount = 0; // total discount from service only
//   double taxAmount = 0.0;
// // tax from controller
//   int totalCost = 0;
//   final selectedServicesController = Get.find<SelectedServicesController>();
//   final consultationController = Get.find<Consultationcontroller>();
//   calculations() {
//     // Get values from SelectedServicesController
//     final selectedServices = selectedServicesController.selectedServices;

//     final int rawServiceCost = selectedServices.fold(
//         0, (sum, service) => sum + service.pricing.toInt());

//     final int discountedServiceCost = selectedServices.fold(
//         0, (sum, service) => sum + service.discountedCost.toInt());

//     final int serviceDiscount = rawServiceCost - discountedServiceCost;

//     final double tax =
//         selectedServices.fold(0.0, (sum, item) => sum + item.taxAmount);

//     // Final assignments
//     serviceCost = rawServiceCost +
//         (consultationFee ?? 0); // Show total (incl. consult fee)
//     discountedCost = discountedServiceCost +
//         (consultationFee ?? 0); // Show total (incl. consult fee)

//     discount = serviceDiscount;
//     taxAmount = tax;
//     totalCost = discountedServiceCost +
//         (consultationFee ?? 0) +
//         taxAmount.toInt(); // if you want int
//   }
// }
