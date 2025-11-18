import 'package:cutomer_app/ServiceView/ServiceDetailPage.dart';
import 'package:cutomer_app/TreatmentAndServices/SubserviceController.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../APIs/FetchServices.dart';
import '../Dashboard/DashBoardController.dart';
import '../Loading/SkeletonLoder.dart';
import '../Modals/ServiceModal.dart';

import '../SubserviceAndHospital/HospitalCardScreen .dart';
import '../TreatmentAndServices/ServiceSelectionController.dart';
import '../Utils/CommonCarouselAds.dart';
import '../Utils/GradintColor.dart';

class Onlysubserviceview extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String mobileNumber;
  final String username;

  const Onlysubserviceview({
    super.key,
    required this.categoryName,
    required this.categoryId,
    required this.mobileNumber,
    required this.username,
  });

  @override
  _OnlysubserviceviewState createState() => _OnlysubserviceviewState();
}

class _OnlysubserviceviewState extends State<Onlysubserviceview>
    with SingleTickerProviderStateMixin {
  final Serviceselectioncontroller serviceselectioncontroller =
      Get.put(Serviceselectioncontroller());
  final Dashboardcontroller dashboardcontroller =
      Get.put(Dashboardcontroller());
  final serviceFetcher = Get.put(ServiceFetcher());
  List<SubServiceAdmin> dynamicSubServices = [];
  bool isSubServiceLoading = false;
  SubServiceAdmin? selectedSubService;
  final subServiceController = Get.put(SubServiceController());
  var suggestion;
  @override
  void initState() {
    super.initState();

    print("Blood sample collection categoryName${widget.categoryName}");
    print("Blood sample collection categoryId${widget.categoryId}");

    serviceselectioncontroller.services.clear();
    serviceselectioncontroller.filteredServices.clear();

    serviceselectioncontroller.fetchImages();
    serviceselectioncontroller.fetchServices(widget.categoryId).then((_) {
      serviceselectioncontroller.filteredServices.assignAll(
        serviceselectioncontroller.services,
      );
    });

    serviceselectioncontroller.searchController
        .addListener(serviceselectioncontroller.updateSuggestions);

    serviceselectioncontroller.animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    serviceselectioncontroller.skeletonColorAnimation = ColorTween(
      begin: Colors.grey[300],
      end: Colors.grey[100],
    ).animate(serviceselectioncontroller.animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonHeader(
        title: 'Select Services',
        onNotificationPressed: () {},
        onSettingPressed: () {},
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            serviceselectioncontroller.onRefresh(widget.categoryId),
        child: Obx(
          () => Column(
            children: [
              const SizedBox(height: 20),
              CommonCarouselAds(
                media: serviceselectioncontroller.carouselImages,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  style: const TextStyle(color: secondaryColor),
                  controller: serviceselectioncontroller.searchController,
                  onChanged: serviceselectioncontroller.filterServices,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: secondaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: secondaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    hintText: "Search by service name",
                    suffixIcon: serviceselectioncontroller
                            .searchController.text.isNotEmpty
                        ? IconButton(
                            icon:
                                const Icon(Icons.clear, color: secondaryColor),
                            onPressed: serviceselectioncontroller.clearSearch,
                          )
                        : const Icon(Icons.search, color: secondaryColor),
                  ),
                ),
              ),
              if (serviceselectioncontroller.searchController.text.isNotEmpty &&
                  serviceselectioncontroller.filteredServices.isNotEmpty)
                Container(
                  child: Obx(() {
                    List<Service> services =
                        serviceselectioncontroller.filteredServices;
                    print("selected services ${services}");

                    return ListView.builder(
                      shrinkWrap: true, // Needed inside Column/Scroll
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        suggestion = services[index];

                        return ListTile(
                          title: Text(suggestion.serviceName),
                          onTap: () {
                            serviceselectioncontroller.searchController.text =
                                suggestion.serviceName;

                            // Assign only the selected suggestion to filtered list
                            serviceselectioncontroller.filteredServices
                                .assignAll([suggestion]);

                            FocusScope.of(context).unfocus(); // Hide keyboard
                          },
                        );
                      },
                    );
                  }),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.categoryName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
              ),
              Expanded(
                child: serviceselectioncontroller.isLoading.value
                    ? SkeletonLoader(
                        animation:
                            serviceselectioncontroller.skeletonColorAnimation,
                      )
                    : serviceselectioncontroller.filteredServices.isEmpty
                        ? const Center(
                            child: Text(
                              "No services available",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Two columns

                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            itemCount: serviceselectioncontroller
                                .filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = serviceselectioncontroller
                                  .filteredServices[index];
                              return InkWell(
                                onTap: () {
                                  _showOptionBottomSheet(context, service);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 246, 246, 246),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 225, 224, 224),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(10)),
                                          child: AspectRatio(
                                            aspectRatio: 1.5,
                                            child: service.serviceImage !=
                                                        null &&
                                                    service
                                                        .serviceImage.isNotEmpty
                                                ? Image.memory(
                                                    service.serviceImage,
                                                    fit: BoxFit.cover)
                                                : Container(
                                                    color: Colors.grey.shade200,
                                                    child: const Center(
                                                        child:
                                                            Text("No Image")),
                                                  ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0, horizontal: 8),
                                            child: Text(
                                              service.serviceName,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: mainColor),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionBottomSheet(BuildContext context, Service service) {
    selectedSubService = null;
    dynamicSubServices = [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Use StatefulBuilder to update loading/subservices
        return StatefulBuilder(
          builder: (context, setState) {
            // Fetch subservices after bottom sheet is built
            if (dynamicSubServices.isEmpty && !isSubServiceLoading) {
              setState(() => isSubServiceLoading = true);
              serviceFetcher.fetchsubServices(service.serviceId).then((subs) {
                setState(() {
                  dynamicSubServices = subs;
                  isSubServiceLoading = false;
                });
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Select Procedure for\n${service.serviceName}",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isSubServiceLoading)
                      Center(
                        child: SpinKitFadingCircle(
                          color: mainColor,
                          size: 40.0,
                        ),
                      )
                    else if (dynamicSubServices.isEmpty)
                      const Text("No Sub-Services Available")
                    else
                      ...dynamicSubServices.map((sub) {
                        final isSelected = selectedSubService?.subServiceId ==
                            sub.subServiceId;
                        return GestureDetector(
                          onTap: () => setState(() => selectedSubService = sub),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    sub.subServiceName.isNotEmpty
                                        ? sub.subServiceName
                                        : sub.serviceName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: (selectedSubService == null ||
                                  dynamicSubServices.isEmpty)
                              ? Colors.grey
                              : Theme.of(context).primaryColor,
                        ),
                        onPressed: (selectedSubService == null ||
                                dynamicSubServices.isEmpty)
                            ? null
                            : () {
                                subServiceController
                                    .setSelectedSubService(selectedSubService!);
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HospitalCardScreen(
                                      categoryName: service.categoryName,
                                      serviceId: service.serviceId,
                                      serviceName: service.serviceName,
                                      categoryId: widget.categoryId,
                                      mobileNumber: widget.mobileNumber,
                                      username: widget.username,
                                      services: service,
                                      selectedService: selectedSubService!,
                                    ),
                                  ),
                                );
                              },
                        child: const Text(
                          "Continue",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
