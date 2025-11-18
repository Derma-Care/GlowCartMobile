import 'package:get/get.dart';
import 'AboutClinicModel.dart';
import 'AboutclinicService.dart';

class ClinicController extends GetxController {
  final ClinicService _service = ClinicService(); // ✅ Create instance

  var clinic = Rxn<Clinic>();
  var isLoading = false.obs;
  var error = ''.obs;

  Future<void> fetchClinic(String hospitalId) async {
    try {
      isLoading.value = true;
      error.value = '';
      clinic.value =
          await _service.getClinic(hospitalId); // ✅ Call instance method
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
