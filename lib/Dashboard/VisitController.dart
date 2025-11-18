import 'package:cutomer_app/BottomNavigation/Appoinments/GetAppointmentModel.dart';
import 'package:get/get.dart';

class VisitController extends GetxController {
  var bookings = <Getappointmentmodel>[].obs;
final loading = false.obs;

  void setBookings(List<Getappointmentmodel> newBookings) {
    bookings.assignAll(newBookings);
  }
}
