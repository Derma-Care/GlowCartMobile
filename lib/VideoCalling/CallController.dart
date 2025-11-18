// call_controller.dart
import 'package:get/get.dart';

class CallController extends GetxController {
  var userID = ''.obs;
  var userName = ''.obs;
  var callID = ''.obs;

  void setCallInfo({
    required String uid,
    required String uname,
    required String cid,
  }) {
    userID.value = uid;
    userName.value = uname;
    callID.value = cid;
  }
}