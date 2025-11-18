import 'package:get/get.dart';

import '../Modals/ServiceModal.dart';
import '../Services/SubServiceServices.dart';
import '../TreatmentAndServices/ServiceSelectionScreen.dart'; // Adjust the import based on your project structure

class SelectedServicesController extends GetxController {
  // Observable list of selected services
  var selectedServices = <Service>[].obs;
  var selectedSubServices = <SubService>[].obs;
  var selectedSubServicesNmae = <SubServiceAdmin>[].obs;
  RxString categoryId = "".obs;
  RxString categoryName = "".obs;
  RxString hospitalId = ''.obs; // ✅ Correct spelling

  // Method to update the; selected services
  void updateSelectedServices(List<Service> services) {
    selectedServices.assignAll(services);
  }

  void updateSelectedSubServices(List<SubService> subservices) {
    selectedSubServices.assignAll(subservices);
  }
  void updateSelectedSubServicesName(List<SubServiceAdmin> selectedSubServicesNmae) {
    selectedSubServicesNmae.assignAll(selectedSubServicesNmae);
  }

  void setHospitalId(String id) {
    print("Setting hospitalId to: $id");
    try {
      hospitalId.value = id;
      print("Setting hospitalId tos: ${hospitalId.value}");
    } catch (e) {
      print("❌ Error setting hospitalId: $e");
    }
  }


  // Default to Online
  var selectedPayment = 'Online'.obs;

  void setPayment(String value) {
    selectedPayment.value = value;
  }

  void clearAll() {
    print("🔄 Clearing all selected service data...");
    selectedServices.clear();
    selectedSubServices.clear();
    categoryId.value = "";
    categoryName.value = "";
    hospitalId.value = "";
    print(
        "✅ Cleared: ${selectedServices.length}, ${selectedSubServices.length}");
  }

  // Method to remove a service from the selected list
  void removeService(int index) {
    selectedServices.removeAt(index);
  }
}

class LocationController extends GetxController {
  var subLocality = ''.obs; // Observable to hold subLocality

  void setSubLocality(String subLoc) {
    subLocality.value = subLoc;
  }
}
