import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../APIs/FetchServices.dart';
import '../Controller/CustomerController.dart';

import '../Modals/ServiceModal.dart';
import '../Services/CarouselSliderService.dart';

class Serviceselectioncontroller extends GetxController {
  late AnimationController animationController;
  late Animation<Color?> skeletonColorAnimation;
  final CarouselSliderService carouselSliderService = CarouselSliderService();
  bool iamgeloading = true;
  List<String> carouselImages = [];

  final ServiceFetcher serviceFetcher = ServiceFetcher();
  TextEditingController searchController = TextEditingController();

  final RxList<Service> services = <Service>[].obs;
  final RxList<SubServiceAdmin> subservices = <SubServiceAdmin>[].obs;
  final RxList<Service> filteredServices = <Service>[].obs;

  final RxBool isLoading = true.obs;
  

  fetchImages() async {
    iamgeloading = true;

    try {
      final images =
          await carouselSliderService.fetchServiceImages(); // Fetch images

      carouselImages = images;
      iamgeloading = false; // Set loading to false after images are fetched

      print("carouselImages images${carouselImages}");
    } catch (e) {
      print("Error fetching images: $e");

      iamgeloading = false; // Set loading to false even if there's an error
    }
  }

  @override
  void dispose() {
    searchController.removeListener(updateSuggestions);
    searchController.dispose();
    super.dispose();
    animationController.dispose();
  }

  Future<void> fetchServices(String categoryId) async {
    final fetchedServices = await serviceFetcher.fetchServices(categoryId);

    final allSubServices = await Future.wait(
      fetchedServices
          .map((service) => serviceFetcher.fetchsubServices(service.serviceId)),
    );

// Flatten the list of lists
    final fetchedSubServices = allSubServices.expand((e) => e).toList();

    print("fetchedServices ${categoryId}");
    print("fetchedServices fetchedServices ${fetchedServices}");

    services.assignAll(fetchedServices); // ✅ Fix
    subservices.assignAll(fetchedSubServices); // ✅ Fix
    filteredServices.assignAll(fetchedServices); // ✅ Fix

    isLoading.value = false;
  }

  void filterServices(String query) {
    // Your logic to filter services based on query
    final results = services
        .where((service) =>
            service.serviceName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    filteredServices.assignAll(results); // Assuming you're using RxList
  }

//   void navigateToConfirmation(
//       {String? categoryId, String? categoryName, String? serviceId, String? subserviceId }) async {
//     await serviceFetcher.fetchsubServices(serviceId!);

//     try {
//       Service? selectedService = services.firstWhere(
//         (service) => service.serviceId == serviceId,
//       );
//         SubService? selectedSubService = subservices.firstWhere(
//         (service) => service.subServiceId == subserviceId,
//       );

// // Only proceed if found
//       if (selectedService != null) {
//         final selectedServicesController =
//             Get.find<SelectedServicesController>();
//         selectedServicesController.updateSelectedServices([selectedService]);
//          selectedServicesController
//                       .updateSelectedSubServices([selectedSubService!]);
//         // Pass as a list
//         selectedServicesController.categoryId.value = categoryId!;
//         selectedServicesController.categoryName.value = categoryName!;
//       } else {
//         print("Service with ID $serviceId not found.");
//       }
//     } catch (e) {
//       print('Error fetching address: $e');
//       // Handle error
//     }
//   }

  void clearSearch() {
    searchController.clear(); // Clear the search text field
    filteredServices.assignAll(services); // ✅ Fix
  }

  void updateSuggestions() {
    final query = searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filteredServices.value = services
          .where((service) => service.serviceName.toLowerCase().contains(query))
          .toList();
    } else {
      filteredServices.assignAll(services); // ✅ Fix
    }
  }

  onRefresh(String categoryId) async {
    await fetchServices(categoryId);
  }
}
