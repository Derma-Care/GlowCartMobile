import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Booings/BooingService.dart';
import '../../Doctors/ListOfDoctors/DoctorController.dart';
import '../../Doctors/ListOfDoctors/DoctorService.dart';
import '../../Utils/AppointmentCard.dart';
import '../Appoinments/AppointmentService.dart';
import '../Appoinments/GetAppointmentModel.dart';
import '../Appoinments/PostBooingModel.dart';

class OnlineCounsultation extends StatefulWidget {
  final String mobileNumber;
  OnlineCounsultation({required this.mobileNumber});

  @override
  _OnlineCounsultationState createState() => _OnlineCounsultationState();
}

class _OnlineCounsultationState extends State<OnlineCounsultation> {
  final DoctorController doctorController = Get.put(DoctorController());
  final DoctorService doctorService = DoctorService();

  bool isLoading = true;
  List<Getappointmentmodel> doctorBookings = [];
  final AppointmentService appointmentService = AppointmentService();
  @override
  void initState() {
    super.initState();
    print("📞 initState triggered with mobile number: ${widget.mobileNumber}");
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('customerId') ?? "";

    try {
      final bookings = await appointmentService.fetchAppointments(id);
      print("📥 Received bookings: $bookings");

      if (bookings != null && bookings is List<Getappointmentmodel>) {
        setState(() {
          doctorBookings = bookings;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("❌ Error: bookings is not a List<Getappointmentmodel>");
      }
    } catch (e) {
      print("🚨 Exception during fetch: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    print("🔁 Refresh triggered");
    await fetchBookings();
  }

  List<Getappointmentmodel> _filteredBookings() {
    return doctorBookings.where((b) {
      final type = b.consultationType.trim().toLowerCase();
      final status = b.status.trim().toLowerCase();
      print("type: $type, status: $status");

      final isOnlineOrVideo =
          type == 'online consultation' || type == 'video consultation';
      final isPendingOrConfirmed = status == 'pending' || status == 'confirmed';

      return isOnlineOrVideo && isPendingOrConfirmed;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: 'Online Consultation',
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: mainColor,
                size: 40.0,
              ),
            )
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: _filteredBookings().isEmpty
                  ? ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 350),
                        Center(child: Text('No Online Consultations found.')),
                      ],
                    )
                  : ListView.builder(
                      itemCount: _filteredBookings().length,
                      itemBuilder: (context, index) {
                        final booking = _filteredBookings()[index];
                        return AppointmentCard(
                          doctorData: booking,
                        );
                      },
                    ),
            ),
    );
  }

 
}
