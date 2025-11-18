import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AppointmentService.dart';
import 'GetAppointmentModel.dart';
import '../../Dashboard/DashBoardController.dart';

class AppointmentController extends GetxController {
  // Observables
  final RxList<Getappointmentmodel> doctorBookings =
      <Getappointmentmodel>[].obs;
  final RxList<Getappointmentmodel> inProgressBookings =
      <Getappointmentmodel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedTab = 'UPCOMING'.obs;
  final RxInt upcomingCountRx = 0.obs;
  final RxInt videoConsultationCountRx = 0.obs;

  // Services and dashboard controller
  final AppointmentService appointmentService = AppointmentService();
  final dashboardController = Get.find<Dashboardcontroller>();

  @override
  void onInit() {
    super.onInit();

    // Fetch bookings whenever mobileNumber is available
    // ever(dashboardController.mobileNumber, (val) {
    //   if (val != null && val.isNotEmpty) {
    fetchBookings();
    //   }
    // });
  }

  // Fetch all bookings
  Future<void> fetchBookings() async {
    // final mobileNumber = dashboardController.mobileNumber.value.trim();

    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    var usermobilenumber = await prefs.getString('mobileNumber');
    if (usermobilenumber!.isEmpty) return;

    final id = prefs.getString('customerId') ?? "";
    print("📥 fetchBookings ${id}");

    try {
      final response = await appointmentService.fetchAppointments(id);
      print("📥 fetchBookings – raw list length: ${response.length}");

      if (response.isNotEmpty) {
        doctorBookings.assignAll(response);

        // In-progress bookings
        inProgressBookings.assignAll(
          doctorBookings
              .where((b) => b.status.toLowerCase().trim() == 'in_progress')
              .toList(),
        );

        // Upcoming count (excluding online/video consultations)
        upcomingCountRx.value = doctorBookings.where((b) {
          final status = b.status.toLowerCase().trim();
          final type = b.consultationType.toLowerCase().trim();
          return (status == 'confirmed') &&
              type != 'online consultation' &&
              type != 'video consultation';
        }).length;

        // Video consultation count
        videoConsultationCountRx.value = doctorBookings.where((b) {
          final type = b.consultationType.toLowerCase().trim();
          final status = b.status.toLowerCase().trim();
          return type == 'online consultation' && status != 'completed';
        }).length;

        print(
            "📊 Upcoming: ${upcomingCountRx.value}, Video: ${videoConsultationCountRx.value}, InProgress: ${inProgressBookings.length}");
      } else {
        doctorBookings.clear();
        inProgressBookings.clear();
        upcomingCountRx.value = 0;
        videoConsultationCountRx.value = 0;
      }
    } catch (e) {
      print("❌ Error in fetchBookings(): $e");
      doctorBookings.clear();
      inProgressBookings.clear();
      upcomingCountRx.value = 0;
      videoConsultationCountRx.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  // Filter bookings based on selected tab
  List<Getappointmentmodel> get filteredBookings {
    if (selectedTab.value == 'UPCOMING') {
      return doctorBookings.where((b) {
        final status = b.status.toLowerCase().trim();
        final type = b.consultationType.toLowerCase().trim();
        return (status ==
                'confirmed') && //if need in-progress appointmnets  || status == 'in_progress'
            !(type == 'online consultation' || type == 'video consultation');
      }).toList();
    } else if (selectedTab.value == 'COMPLETED') {
      return doctorBookings
          .where((b) => b.status.toLowerCase().trim() == 'completed')
          .toList();
    } else if (selectedTab.value == 'IN_PROGRESS') {
      return inProgressBookings;
    } else {
      return doctorBookings;
    }
  }

  // Change tab
  void changeTab(String tab) async {
    selectedTab.value = tab;
    await fetchBookings();
  }

  // Refresh bookings manually
  Future<void> refreshBookings() async {
    await fetchBookings();
  }
}
