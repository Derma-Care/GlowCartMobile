import 'dart:io';
import 'package:cutomer_app/SubserviceAndHospital/HospitalCardModel.dart';
import 'package:get/get.dart';

class SymptomsController extends GetxController {
  var symptoms = ''.obs;
  var duration = ''.obs;
  var visitType = ''.obs;
  var attachments = <File>[].obs;
  Rx<Branch?> selectedBranch = Rx<Branch?>(null);

  void updateSymptoms(String value) {
    symptoms.value = value;
  }

  void updateDuration(String value) {
    duration.value = value;
  }

  void updateVisitType(String value) {
    visitType.value = value;
  }

  void updateBranch(Branch branch) {
    selectedBranch.value = branch;
    print("Controller Branch Updated: ${branch.branchName}");
  }

  void addAttachment(File file) {
    attachments.add(file);
  }

  void removeAttachment(int index) {
    attachments.removeAt(index);
  }

  void clearAttachments() {
    attachments.clear();
  }

  void clearForm() {
    symptoms.value = '';
    duration.value = '';
    attachments.clear(); // ✅ Proper way to clear RxList
    selectedBranch.value = null;
  }
}
