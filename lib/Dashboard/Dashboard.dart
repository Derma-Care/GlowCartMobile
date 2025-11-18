import 'dart:math';
import 'package:cutomer_app/ConfirmBooking/Consultations.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:cutomer_app/Inputs/CustomInputField.dart';
import 'package:cutomer_app/Services/serviceb.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../BottomNavigation/Appoinments/AppointmentController.dart';
import '../ConfirmBooking/ConsultationController.dart';
import '../ConfirmBooking/ConsultationServices.dart';
import '../Modals/ServiceCard.dart';
import '../Utils/AppointmentCard.dart';
import '../Utils/Constant.dart';
import '../Utils/GradintColor.dart';
import 'DashBoardController.dart';

class DashboardScreen extends StatefulWidget {
  final String mobileNumber;
  final String username;

  const DashboardScreen({
    super.key,
    required this.mobileNumber,
    required this.username,
  });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final Dashboardcontroller dashboardcontroller =
      Get.put(Dashboardcontroller());
  final controller = Get.put(AppointmentController());
  final queryController = TextEditingController();
  late final AnimationController _rotationController;
  late List<Serviceb> filteredServices; // ✅ Keep filtered list

  bool showLabel = false;
  bool isFabVisible = true;
  late ScrollController _scrollController;
  bool isOpaque = false;
  final consultationcontroller = Get.find<Consultationcontroller>();
  void _onFabTapped() {
    if (!showLabel) {
      setState(() => showLabel = true);
    } else {
      Navigator.pop(context); // Do actual navigation if label is already shown
    }
  }

  @override
  void initState() {
    super.initState();
    filteredServices = [];
    queryController.addListener(_filterServices); // ✅ Listen for changes
    _rotationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.userScrollDirection ==
                ScrollDirection.reverse &&
            isFabVisible) {
          setState(() {
            isFabVisible = false;
          });
        } else if (_scrollController.position.userScrollDirection ==
                ScrollDirection.forward &&
            !isFabVisible) {
          setState(() {
            isFabVisible = true;
          });
        }
      });

    // Now call async logic separately
    loadInitialData();
  }

  void _filterServices() {
    final query = queryController.text.toLowerCase();
    setState(() {
      filteredServices = dashboardcontroller.services
          .where(
              (service) => service.categoryName.toLowerCase().contains(query))
          .toList();
    });
  }

  void loadInitialData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? firstConsultationId = prefs.getString('firstConsultationId');
    String? firstConsultationType = prefs.getString('firstConsultationType');

    if (firstConsultationId != null && firstConsultationType != null) {
      ConsultationModel consultation = ConsultationModel(
        consultationType: firstConsultationType,
        consultationId: firstConsultationId,
      );

      consultationcontroller.setConsultation(consultation);

      print('Stored ID: $firstConsultationId');
      print('Stored Type: $firstConsultationType');
    } else {
      print('No consultation stored yet.');
    }

    dashboardcontroller.loadSavedImage();
    dashboardcontroller.fetchUserServices();

    setState(() {
      filteredServices = dashboardcontroller.services; // ✅ Show all initially
    });
    dashboardcontroller.fetchAppointments(widget.mobileNumber);
    dashboardcontroller.fetchImages();
    controller.fetchBookings();
    dashboardcontroller.storeUserData(widget.mobileNumber, widget.username);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    queryController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: "Services & Treatments",
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CustomTextField(
              controller: queryController,
              labelText: 'Search Categories',
              showClearIcon: true, // ✅ Enable clear icon
              onChanged: (value) {
                setState(() {}); // ✅ Rebuild so clear icon appears/disappears
                _filterServices();
              },
              onClear: () {
                queryController.clear(); // ✅ Clear text
                setState(() {
                  filteredServices =
                      dashboardcontroller.services; // ✅ Reset list
                });
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (dashboardcontroller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (dashboardcontroller.services.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/nonetwork.jpg",
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.6,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Image failed to load',
                            style: TextStyle(color: Colors.red),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        dashboardcontroller.statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      FloatingActionButton(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                        onPressed: () async {
                          _rotationController.repeat(); // Start spinning
                          await dashboardcontroller
                              .onRefresh(widget.mobileNumber);
                          _rotationController.reset(); // Stop spinning
                        },
                        tooltip: 'Refresh',
                        child: AnimatedBuilder(
                          animation: _rotationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationController.value * 2 * pi,
                              child: child,
                            );
                          },
                          child: const Icon(Icons.refresh),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: () =>
                      dashboardcontroller.onRefresh(widget.mobileNumber),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(height: 20),
                        // CommonCarouselAds(
                        //   media: dashboardcontroller.carouselImages,
                        //   height: 170,
                        // ),
                        const SizedBox(height: 20),
                        // if (controller.inProgressBookings.isNotEmpty) ...[
                        //   Padding(
                        //     padding: EdgeInsets.all(16.0),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Text(
                        //           "Active Appointments",
                        //           style: TextStyle(
                        //               fontSize: 18,
                        //               fontWeight: FontWeight.bold),
                        //         ),
                        //         Text("${controller.inProgressBookings.length}")
                        //       ],
                        //     ),
                        //   ),
                        //   Obx(() {
                        //     print(
                        //         'In-progress bookings count: ${controller.inProgressBookings.length}');

                        //     if (controller.inProgressBookings.isEmpty) {
                        //       // 👈 Fix here
                        //       return const Center(
                        //           child: Text('No in-progress appointments'));
                        //     }

                        //     return SingleChildScrollView(
                        //       scrollDirection: Axis.horizontal,
                        //       child: Row(
                        //         children: List.generate(
                        //           min(3, controller.inProgressBookings.length),
                        //           (index) {
                        //             final appointment =
                        //                 controller.inProgressBookings[index];
                        //             return Padding(
                        //               padding: const EdgeInsets.symmetric(
                        //                   horizontal: 8.0),
                        //               child: SizedBox(
                        //                 width:
                        //                     MediaQuery.of(context).size.width *
                        //                         0.95,
                        //                 child: AppointmentCard(
                        //                     doctorData: appointment),
                        //               ),
                        //             );
                        //           },
                        //         ),
                        //       ),
                        //     );
                        //   }),
                        // ],

                        const SizedBox(height: 10),
                        Center(
                          child: GradientText(
                            'Derma Services And Treatments',
                            gradient: const LinearGradient(
                              colors: [mainColor, secondaryColor],
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 10),
                        filteredServices.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    "No services found for '${queryController.text}'",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: mainColor),
                                  ),
                                ),
                              )
                            : GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: filteredServices.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 1,
                                  mainAxisSpacing: 5,
                                ),
                                itemBuilder: (context, index) {
                                  final service = filteredServices[index];
                                  return ServiceCard(
                                    mobileNumber: widget.mobileNumber,
                                    username: widget.username,
                                    service: service,
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                );
              }
            }),
          ),
        ],
      ),
      // floatingActionButton: isFabVisible
      //     ? AnimatedOpacity(
      //         duration: Duration(milliseconds: 300),
      //         opacity: isOpaque ? 1.0 : 0.4,
      //         child: FloatingActionButton.extended(
      //           onPressed: () {
      //             if (!showLabel) {
      //               setState(() {
      //                 showLabel = true;
      //                 isOpaque = true;
      //               });
      //             } else {
      //               // Navigator.pop(context); // or your logic
      //               Get.to(ConsultationsType(
      //                 mobileNumber: widget.mobileNumber,
      //                 username: widget.username,
      //               ));
      //             }
      //           },
      //           icon: Icon(Icons.arrow_back_ios_new_rounded),
      //           label: AnimatedSwitcher(
      //             duration: Duration(milliseconds: 300),
      //             transitionBuilder: (child, animation) =>
      //                 ScaleTransition(scale: animation, child: child),
      //             child: showLabel
      //                 ? Text("Consultations", key: ValueKey("label"))
      //                 : SizedBox.shrink(key: ValueKey("empty")),
      //           ),
      //         ),
      //       )
      //     : null
    );
  }
}
