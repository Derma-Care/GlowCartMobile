import 'package:cutomer_app/Modals/ServiceModal.dart';
import 'package:get/get.dart';

class SubServiceController extends GetxController {
  // Observable selected sub-service
  Rx<SubServiceAdmin?> selectedSubService = Rx<SubServiceAdmin?>(null);

  // List of sub-services (if you want to manage multiple)
  RxList<SubServiceAdmin> subServices = <SubServiceAdmin>[].obs;

  // Set selected sub-service
  void setSelectedSubService(SubServiceAdmin subService) {
    selectedSubService.value = subService;
  }

  // Clear selected sub-service
  void clearSelection() {
    selectedSubService.value = null;
  }

  // Add sub-service to the list
  void addSubService(SubServiceAdmin subService) {
    subServices.add(subService);
  }

  // Remove sub-service from the list
  void removeSubService(String subServiceId) {
    subServices.removeWhere((s) => s.subServiceId == subServiceId);
  }
}
