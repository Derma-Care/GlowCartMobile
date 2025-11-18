import 'package:cutomer_app/APIs/FetchServices.dart';
import 'package:cutomer_app/BottomNavigation/Appoinments/AppointmentController.dart';
import 'package:cutomer_app/Clinic/AboutClinicController.dart';
import 'package:cutomer_app/ConfirmBooking/ConsultationController.dart';
import 'package:cutomer_app/Consultations/SymptomsController.dart';
import '../Controller/CustomerController.dart';

import 'package:cutomer_app/Dashboard/DashBoardController.dart';
import 'package:cutomer_app/Dashboard/VisitController.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/DoctorController.dart';
import 'package:cutomer_app/Doctors/Schedules/ScheduleController.dart';
import 'package:cutomer_app/Notification/NotificationController.dart';
import 'package:cutomer_app/TreatmentAndServices/ServiceSelectionController.dart';
import 'package:cutomer_app/TreatmentAndServices/SubserviceController.dart';
import 'package:cutomer_app/VideoCalling/CallController.dart';
import 'package:get/get.dart';

void initializeControllers() {
  // Use lazyPut for safety
  Get.lazyPut(() => DoctorController());
  Get.lazyPut(() => Dashboardcontroller());
  Get.lazyPut(() => Serviceselectioncontroller());
  Get.lazyPut(() => SelectedServicesController());

  Get.lazyPut(() => Consultationcontroller());
  Get.lazyPut(() => ScheduleController());
  Get.lazyPut(() => AppointmentController());
  Get.lazyPut(() => NotificationController());
  Get.lazyPut(() => ServiceFetcher());
  Get.lazyPut(() => CallController());
  Get.lazyPut(() => SymptomsController());
  Get.lazyPut(() => VisitController());
  Get.lazyPut(() => SubServiceController());
  Get.lazyPut(() => ClinicController());
}
