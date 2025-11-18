import 'package:cutomer_app/BottomNavigation/Profile/Profile.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ConfirmBooking/ConsultationServices.dart';
import '../ConfirmBooking/Consultations.dart';
import '../Dashboard/Dashboard.dart';
import '../Doctors/ListOfDoctors/DoctorController.dart';
import 'Appoinments/Appoinments.dart';
import 'Appoinments/AppointmentController.dart';
import 'Profile/Profiles.dart';
import 'OnlineCounsultation/OnlineCounsultation.dart';

class BottomNavController extends StatefulWidget {
  final String mobileNumber;
  final String username;
  final int index;
  final ConsultationModel? consultation;

  const BottomNavController({
    Key? key,
    required this.mobileNumber,
    required this.username,
    required this.index,
    this.consultation,
  }) : super(key: key);

  @override
  _BottomNavControllerState createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  late int _selectedIndex;
  final doctorController = Get.find<DoctorController>();

  final appointmentcontroller = Get.find<AppointmentController>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    print("doctorController.mobileNumber ${widget.mobileNumber}");
    print("doctorController.mobileNumber ${widget.username}");
    _selectedIndex = widget.index;

    // Initialize pages
    _pages = [
      ConsultationsType(
        mobileNumber: widget.mobileNumber,
        username: widget.username,
        // consulationType: widget.consultation!.consultationType,
        // consulationType: widget.consultation!.consultationType,
      ),
      AppointmentPage(
        mobileNumber: widget.mobileNumber,
      ),
      OnlineCounsultation(
        mobileNumber: widget.mobileNumber,
      ),
      CustomerProfilePage(
        mobileNumber: widget.mobileNumber,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [mainColor, secondaryColor],
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color.fromARGB(255, 1, 17, 61),
          unselectedItemColor: Colors.white,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Obx(() => Stack(
                    children: [
                      const Icon(Icons.calendar_month),
                      if (appointmentcontroller.upcomingCountRx.value > 0)
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              appointmentcontroller.upcomingCountRx.value > 10
                                  ? '10+'
                                  : '${appointmentcontroller.upcomingCountRx.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  )),
              label: 'Appointment',
            ),
            BottomNavigationBarItem(
              icon: Obx(() => Stack(
                    children: [
                      const Icon(Icons.video_call),
                      if (appointmentcontroller.videoConsultationCountRx.value >
                          0)
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              appointmentcontroller
                                          .videoConsultationCountRx.value >
                                      10
                                  ? '10+'
                                  : '${appointmentcontroller.videoConsultationCountRx.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  )),
              label: 'Online Consultation',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_2_outlined),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
