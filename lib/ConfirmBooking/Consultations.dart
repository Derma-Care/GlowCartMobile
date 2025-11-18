import 'dart:math';
import 'package:cutomer_app/ConfirmBooking/ConsultationServices.dart';
import 'package:cutomer_app/Dashboard/DashBoardController.dart';
import 'package:cutomer_app/Dashboard/Dashboard.dart';
import 'package:cutomer_app/Dashboard/ImagePreview.dart';
import 'package:cutomer_app/Dashboard/VisitType.dart';
import 'package:cutomer_app/Notification/NotificationController.dart';
import 'package:cutomer_app/Notification/Notifications.dart';
import 'package:cutomer_app/Screens/RefferalCode.dart';
import 'package:cutomer_app/Utils/CommonCarouselAds.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/CopyRigths.dart';
import 'package:cutomer_app/Utils/GradintColor.dart';
import 'package:cutomer_app/Utils/capitalizeFirstLetter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Consultations/SymptomsForm.dart';
import 'ConsultationController.dart';

class ConsultationsType extends StatefulWidget {
  final String mobileNumber;
  final String username;

  const ConsultationsType({
    super.key,
    required this.mobileNumber,
    required this.username,
  });

  @override
  ConsultationsTypeState createState() => ConsultationsTypeState();
}

class ConsultationsTypeState extends State<ConsultationsType> {
  final consultationcontroller = Get.find<Consultationcontroller>();
  final dashboardcontroller = Get.put(Dashboardcontroller());
  List<ConsultationModel> _consultations = [];
  bool loading = true;
  String? cityName;
  double? latitude;
  double? longitude;
  String? fullname;
  String selectedVisitType = "First Time"; // 👈 store visit type here
  final NotificationController notificationController = Get.find();
  @override
  void initState() {
    super.initState();
    _loadLocation();
    dashboardcontroller.setMobileNumber(widget.mobileNumber);
    _loadConsultations();
  }

  Future<void> _loadConsultations() async {
    setState(() => loading = true);
    final consultations = await getConsultationDetails();
    setState(() {
      _consultations = consultations;
      loading = false;
    });
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      cityName = prefs.getString('cityName');
      latitude = prefs.getDouble('latitude');
      longitude = prefs.getDouble('longitude');
      fullname = prefs.getString('customerName');
    });

    print("City loaded: $cityName");
    print("Lat: $latitude, Lng: $longitude");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : _consultations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("No service available",
                          style: TextStyle(color: mainColor)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadConsultations,
                        child: const Text("Refresh"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        CommonCarouselAds(
                          media: dashboardcontroller.carouselImages,
                          height: 170,
                        ),
                        const SizedBox(height: 10),
                        if (cityName != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 2,
                                  color: secondaryColor.withAlpha(45)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on,
                                    color: mainColor, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  "You're in : $cityName",
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: mainColor),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        VisitType(
                          consulationType:
                              _consultations.first.consultationType,
                          mobileNumber: widget.mobileNumber,
                          username: widget.username,
                          onVisitTypeChanged: (String value) {
                            setState(() {
                              selectedVisitType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                          children: [
                            _mainCard(
                              "Services & Treatments",
                              "assets/treat.jpg",
                              () {
                                consultationcontroller
                                    .setConsultation(_consultations.first);
                                Get.to(DashboardScreen(
                                  mobileNumber: widget.mobileNumber,
                                  username: fullname!,
                                  // consulationType: "Services & Treatments",
                                ));
                              },
                            ),
                            _mainCard(
                              "Consultations",
                              "assets/consult.jpg",
                              () => _showConsultationOptions(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

      // bottomNavigationBar: BottomAppBar(
      //   color: Colors.transparent,
      //   elevation: 0,
      //   child:
      // ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace:
          Container(decoration: BoxDecoration(gradient: appGradient())),
      title: Row(children: [
        Obx(() {
          final image = dashboardcontroller.imageFile.value;
          return GestureDetector(
            onTap: () {
              if (image != null) {
                Get.to(ImagePreviewScreen(imagePath: image.path));
              } else {
                dashboardcontroller.showImagePickerOptions(context, image);
              }
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage: image != null
                  ? FileImage(image)
                  : const AssetImage('assets/ic_launcher.png') as ImageProvider,
            ),
          );
        }),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hi, Welcome Back",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            // Username Text
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // max width
              child: Text(
                capitalizeFirstLetter(widget.username),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                maxLines: 2, // limit to 2 lines
                overflow:
                    TextOverflow.ellipsis, // add ellipsis if text too long
              ),
            ),
          ],
        ),
        const Spacer(),
        Obx(() {
          final count = Get.find<NotificationController>().unreadCount.value;
          return Obx(() => Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Get.to(() => NotificationScreen());
                    },
                  ),
                  if (notificationController.unreadCount.value > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          notificationController.unreadCount.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ));
        }),
        GestureDetector(
          onTap: () => Get.to(() => ReferralWalletPage()),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.wallet, color: Colors.white),
                onPressed: () {},
              ),
              const Positioned(
                right: 0,
                top: -2,
                child: Text('💰 2000',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _mainCard(String title, String imagePath, VoidCallback onTap) {
    final isDisabled = selectedVisitType == "Follow-Up"; // 👈 check visit type

    return GestureDetector(
      onTap: isDisabled ? null : onTap, // 👈 disable tap
      child: Opacity(
        opacity: isDisabled ? 0.4 : 1.0, // 👈 visually show it's disabled
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: mainColor),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  void _showConsultationOptions() {
    final clinicOptions = _consultations
        .where((e) => e.consultationType.toLowerCase().contains('clinic'))
        .toList();
    final onlineOptions = _consultations
        .where((e) => e.consultationType.toLowerCase().contains('online'))
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (clinicOptions.isNotEmpty)
                ...clinicOptions.map((c) => ListTile(
                      leading:
                          const Icon(Icons.local_hospital, color: mainColor),
                      title: Text(c.consultationType),
                      onTap: () {
                        Navigator.pop(context);
                        consultationcontroller.setConsultation(c);
                        Get.to(() => SymptomsForm(
                              mobileNumber: widget.mobileNumber,
                              username: widget.username,
                              consulationType: c.consultationType,
                            ));
                      },
                    )),
              if (onlineOptions.isNotEmpty)
                ...onlineOptions.map((c) => ListTile(
                      leading: const Icon(Icons.video_call, color: mainColor),
                      title: Text(c.consultationType),
                      onTap: () {
                        Navigator.pop(context);
                        consultationcontroller.setConsultation(c);
                        Get.to(() => SymptomsForm(
                              mobileNumber: widget.mobileNumber,
                              username: widget.username,
                              consulationType: c.consultationType,
                            ));
                      },
                    )),
            ],
          ),
        );
      },
    );
  }
}
