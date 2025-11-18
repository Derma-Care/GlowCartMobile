import 'dart:convert';
import 'dart:typed_data';
import 'package:cutomer_app/Controller/CustomerController.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:cutomer_app/Modals/ServiceModal.dart';
import 'package:cutomer_app/Services/SubServiceServices.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cutomer_app/ServiceView/FetchViewService.dart';
import 'package:flutter/material.dart';
import '../APIs/BaseUrl.dart';
import '../APIs/FetchServices.dart';
import '../Doctors/ListOfDoctors/DoctorScreen.dart';
import '../Loading/SkeletonLoder.dart';
import '../TreatmentAndServices/ServiceSelectionController.dart';
import '../Utils/ConvertMinToHours.dart';
import '../Utils/GradintColor.dart';
import '../Utils/Header.dart';
import 'ServiceDetail.dart';

class ServiceDetailsPage extends StatefulWidget {
  final String mobileNumber;
  final String username;
  final String hospitalName;
  final String hospitalId;
  final String branchId;
  final String branchName;

  const ServiceDetailsPage({
    super.key,
    required this.mobileNumber,
    required this.username,
    required this.selectedService,
    required this.hospitalName,
    required this.hospitalId,
    required this.branchId,
    required this.branchName,
  });

  final String selectedService;

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage>
    with TickerProviderStateMixin {
  late ApiService apiService;
  SubService? subServiceDetails;
  late TabController _tabController;
  bool isLoading = false;

  late AnimationController _animationController;
  late Animation<Color?> _skeletonColorAnimation;
  final Serviceselectioncontroller serviceselectioncontroller =
      Get.put(Serviceselectioncontroller());
  final serviceFetcher = Get.put(ServiceFetcher());
  Set<int> visitedTabs = {};

  @override
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    visitedTabs.add(0);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {
          visitedTabs.add(_tabController.index);
        });
      }
    });

    apiService = ApiService();
    loadSubService();

    // animation for skeleton
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _skeletonColorAnimation = ColorTween(
      begin: Colors.grey[300],
      end: Colors.grey[100],
    ).animate(_animationController);
  }

  void _nextTab() {
    if (_tabController.index < 2) {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  late int requiredTabs = 0;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void loadSubService() async {
    print("calling....");
    print("hospitalId....${widget.hospitalId}");
    print("selectedService....${widget.selectedService}");

    final result =
        await fetchSubServiceDetails(widget.hospitalId, widget.selectedService);
    print("selectedService....@@@${result}");

    setState(() {
      subServiceDetails = result;
    });
  }

  String formatDuration(int? totalMinutes) {
    if (totalMinutes == null) return '';

    if (totalMinutes < 60) {
      return '$totalMinutes mins';
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      if (minutes == 0) {
        return '$hours hr';
      } else {
        return '$hours hr $minutes mins';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int requiredTabs = 0;
    if (subServiceDetails?.preProcedureQA?.isNotEmpty ?? false) requiredTabs++;
    if (subServiceDetails?.procedureQA?.isNotEmpty ?? false) requiredTabs++;
    if (subServiceDetails?.postProcedureQA?.isNotEmpty ?? false) requiredTabs++;

    // 🔹 Step 2: Figure out availability
    bool procedureAvailable = requiredTabs > 0;

    // 🔹 Step 3: Check if all tabs are read
    bool allTabsRead =
        !procedureAvailable || visitedTabs.length >= requiredTabs;

    // bool procedureAvailable =
    //     (subServiceDetails?.preProcedureQA?.isNotEmpty ?? false) ||
    //         (subServiceDetails?.procedureQA?.isNotEmpty ?? false) ||
    //         (subServiceDetails?.postProcedureQA?.isNotEmpty ?? false);

    // bool allTabsRead = procedureAvailable &&
    //     requiredTabs > 0 &&
    //     visitedTabs.length >= requiredTabs;

    if (subServiceDetails == null) {
      // Show loading indicator while data is being fetched
      return Scaffold(
        appBar: CommonHeader(
          title: "Service & Treatment Details",
          onNotificationPressed: () {},
          onSettingPressed: () {},
        ),
        body: Center(
          child: SpinKitFadingCircle(
            color: mainColor,
            size: 40.0,
          ),
        ),
      );
    }
    return Scaffold(
      appBar: CommonHeader(
        title: "Service & Treatment Details",
        onNotificationPressed: () {},
        onSettingPressed: () {},
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_hospital,
                    color: mainColor, // or mainColor if defined
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${widget.hospitalName} (${widget.branchName})",
                      style: TextStyle(
                        color: mainColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              subServiceDetails!.subServiceImage.isNotEmpty
                  ? Image.memory(
                      subServiceDetails!.subServiceImage,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    )
                  : Container(
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Center(child: Text("No Image")),
                    ),
              const SizedBox(height: 16),

              Text(
                subServiceDetails!.viewDescription,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Category Name:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subServiceDetails!.categoryName,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Service Name:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subServiceDetails!.serviceName,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              const Text(
                'Procedure Name:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                // widget.selectedService.subServiceName,
                subServiceDetails!.subServiceName,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              const Text(
                'Procedure Duration:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ("${subServiceDetails!.minTime} Min"),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Description Q&A
              if ((subServiceDetails?.preProcedureQA?.isNotEmpty ?? false) ||
                  (subServiceDetails?.procedureQA?.isNotEmpty ?? false) ||
                  (subServiceDetails?.postProcedureQA?.isNotEmpty ?? false))
                Builder(
                  builder: (context) {
                    final List<Tab> tabs = [];
                    final List<Widget> tabViews = [];

                    if (subServiceDetails?.preProcedureQA?.isNotEmpty ??
                        false) {
                      tabs.add(const Tab(text: "Pre-Procedure"));
                      tabViews
                          .add(buildQAList(subServiceDetails!.preProcedureQA));
                    }
                    if (subServiceDetails?.procedureQA?.isNotEmpty ?? false) {
                      tabs.add(const Tab(text: "Procedure"));
                      tabViews.add(buildQAList(subServiceDetails!.procedureQA));
                    }
                    if (subServiceDetails?.postProcedureQA?.isNotEmpty ??
                        false) {
                      tabs.add(const Tab(text: "Post-Procedure"));
                      tabViews
                          .add(buildQAList(subServiceDetails!.postProcedureQA));
                    }

                    requiredTabs = tabs.length;

                    return Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: mainColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: mainColor,
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 2),
                          tabs: tabs,
                        ),
                        SizedBox(
                          height: 300,
                          child: TabBarView(
                            controller: _tabController,
                            children: tabViews,
                          ),
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: appGradient(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                // serviceselectioncontroller.showAddedItemsAlert(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "₹ ${subServiceDetails?.finalCost.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    // Text(
                    //   "(including tax\n& discount (if any))",
                    //   style: TextStyle(fontSize: 12, color: Colors.white),
                    //   textAlign: TextAlign.center,
                    // )
                  ],
                ),
              ),
            ),
            Container(
              height: 30,
              width: 1,
              color: Colors.white.withOpacity(0.5),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            TextButton(
              onPressed: () {
                if (allTabsRead) {
                  // ✅ User has read everything, proceed
                  Get.to(() => Doctorscreen(
                        mobileNumber: widget.mobileNumber,
                        username: widget.username,
                        subServiceID: subServiceDetails!.subServiceId,
                        hospiatlName: widget.hospitalName,
                        branchName: widget.branchName,
                        branchId: widget.branchId,
                      ));

                  final selectedServicesController =
                      Get.find<SelectedServicesController>();
                  selectedServicesController
                      .updateSelectedSubServices([subServiceDetails!]);
                  selectedServicesController.setHospitalId(widget.hospitalId);
                } else {
                  // ❌ User has NOT read, show alert
                  Get.defaultDialog(
                    title: "Please Read First",
                    middleText:
                        "Kindly read the procedure details, pre-care, and post-care instructions before continuing.",
                    textConfirm: "OK",
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      Get.back();
                    },
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Text(
                  "CONTINUE",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: allTabsRead
                          ? Colors.white
                          : const Color.fromARGB(255, 219, 203, 203)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildQAList(List<DescriptionQA> qaList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...qaList.expand((descQA) {
            return descQA.qa.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...entry.value.map((answer) => Padding(
                          padding:
                              const EdgeInsets.only(left: 8.0, bottom: 4.0),
                          child: Text(
                            "• $answer",
                            style: const TextStyle(fontSize: 16),
                          ),
                        )),
                  ],
                ),
              );
            });
          }),
          const SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: _nextTab,
          //   child: const Text("Next"),
          // ),
        ],
      ),
    );
  }
}
