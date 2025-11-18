import 'package:cutomer_app/APIs/FetchServices.dart';
import 'package:cutomer_app/Inputs/CustomDropdownField.dart';
import 'package:cutomer_app/Modals/ServiceModal.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/CopyRigths.dart';
import 'package:cutomer_app/Utils/GradintColor.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ConfirmBooking/ConsultationPrice.dart';
import '../Controller/CustomerController.dart';
import '../Dashboard/DashBoardController.dart';
import '../Doctors/ListOfDoctors/ConsuationDoctors.dart';
import '../Doctors/ListOfDoctors/DoctorScreen.dart';
import '../Services/serviceb.dart';
import '../TreatmentAndServices/ServiceSelectionController.dart';
import '../../Utils/GradintColor.dart';

class CategoryAndServicesForm extends StatefulWidget {
  final String mobileNumber;
  final String username;
  final String consulationType;

  CategoryAndServicesForm(
      {required this.mobileNumber,
      required this.username,
      required this.consulationType});
  @override
  State<CategoryAndServicesForm> createState() =>
      _CategoryAndServicesFormState();
}

class _CategoryAndServicesFormState extends State<CategoryAndServicesForm> {
  final Dashboardcontroller controller = Get.put(Dashboardcontroller());
  final Serviceselectioncontroller serviceselectioncontroller =
      Get.put(Serviceselectioncontroller());
  @override
  void initState() {
    super.initState();
    fetchMainServices();
  }

  Future<void> fetchMainServices() async {
    await controller.fetchUserServices(); // ✅ JUST call it, don't assign
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme:
            IconThemeData(color: Colors.black), // 👈 Make back arrow black
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset("assets/ic_launcher.png", height: 100),
              SizedBox(height: 20),
              GradientText(
                "Service Details", // Required text
                gradient: appGradient(), // Now it's a LinearGradient
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 5),
              Text(
                widget.consulationType,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: secondaryColor,
                ),
              ),
              SizedBox(height: 20),

              // Service Category Image - Wrap in Obx ONLY this part
              Obx(() => controller.selectedService.value != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        controller.selectedService.value!.categoryImage,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  : SizedBox.shrink()),

              SizedBox(height: 10),

              // Dropdowns inside Obx because they use observables
              Obx(() => CustomDropdownField<Serviceb>(
                    value: controller.selectedService.value,
                    labelText: 'Service Category',
                    items: controller.services.isNotEmpty
                        ? controller.services.map((service) {
                            return DropdownMenuItem<Serviceb>(
                              value: service,
                              child: Text(service.categoryName),
                            );
                          }).toList()
                        : [
                            const DropdownMenuItem<Serviceb>(
                              value: null,
                              child: Text("No Services Available"),
                            )
                          ],
                    onChanged: (service) {
                      controller.selectedService.value = service;
                      controller.selectedSubService.value = null;
                      controller.fetchSubServices(service!.categoryId);
                    },
                  )),

              SizedBox(height: 5),
              Obx(() {
                final ServiceList = controller.subServiceList;
                final selectedSubService = controller.selectedSubService.value;
                final isSubServiceAvailable = ServiceList.isNotEmpty;

                return CustomDropdownField<Service>(
                  value: isSubServiceAvailable ? selectedSubService : null,
                  labelText: 'Service',
                  items: isSubServiceAvailable
                      ? ServiceList.map((service) {
                          return DropdownMenuItem<Service>(
                            value: service,
                            child: Text(service.serviceName),
                          );
                        }).toList()
                      : [
                          const DropdownMenuItem<Service>(
                            value: null,
                            child: Text("No Services Available"),
                          ),
                        ],
                  onChanged: (sub) {
                    if (isSubServiceAvailable && sub != null) {
                      controller.selectedSubService.value = sub;
                    }
                    controller.fetchSubSubServices(sub!.serviceId);
                  },
                );
              }),
              SizedBox(height: 5),

              Obx(() {
                final subServiceArray = controller.subServiceArray;
                final selectedSubSubService =
                    controller.selectedSubSubService.value;
                final isSubServiceAvailable = subServiceArray.isNotEmpty;

                // 🛡 Ensure the selected value is still valid
                if (selectedSubSubService != null &&
                    !subServiceArray.contains(selectedSubSubService)) {
                  controller.selectedSubSubService.value = null;
                }

                return CustomDropdownField<SubServiceAdmin>(
                  value: isSubServiceAvailable
                      ? controller.selectedSubSubService.value
                      : null,
                  labelText: 'Sub-Service',
                  items: isSubServiceAvailable
                      ? subServiceArray.map((service) {
                          return DropdownMenuItem<SubServiceAdmin>(
                            value: service,
                            child: Text(service.subServiceName),
                          );
                        }).toList()
                      : [
                          const DropdownMenuItem<SubServiceAdmin>(
                            value: null,
                            child: Text("No Sub-Services Available"),
                          ),
                        ],
                  onChanged: (sub) {
                    if (isSubServiceAvailable && sub != null) {
                      controller.selectedSubSubService.value = sub;
                    }
                  },
                );
              }),

              SizedBox(
                height: 20,
              ),

              Container(
                decoration: BoxDecoration(
                  gradient: appGradient(),
                  borderRadius: BorderRadius.circular(10), // optional
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final selectedMain = controller.selectedService.value;
                    final selectedSub = controller.selectedSubService.value;
                    final selectedSubService =
                        controller.selectedSubSubService.value;

                    if (selectedMain == null) {
                      ScaffoldMessageSnackbar.show(
                        context: context,
                        message: "Please select a service category",
                        type: SnackbarType.warning,
                      );
                      // Get.snackbar(
                      //     "Validation", "Please select a service category");
                      return;
                    }

                    if (selectedSub == null) {
                      ScaffoldMessageSnackbar.show(
                        context: context,
                        message: "Please select a sub-service",
                        type: SnackbarType.warning,
                      );
                      // Get.snackbar("Validation", "Please select a sub-service");
                      return;
                    }

                    final selectedServicesController =
                        Get.find<SelectedServicesController>();
                    selectedServicesController
                        .updateSelectedServices([selectedSub]);
                    selectedServicesController
                        .updateSelectedSubServicesName([selectedSubService!]);
                    selectedServicesController.categoryId.value =
                        selectedMain.categoryId;
                    selectedServicesController.categoryName.value =
                        selectedMain.categoryName;

                    Get.to(() => ConsultationPrice(
                          mobileNumber: widget.mobileNumber,
                          username: widget.username,

                          consulationType: widget.consulationType,
                          symptoms: '', // ✅ send it here
                        ));
                    // Get.to(() => ConsulationDoctorScreen(
                    //       mobileNumber: widget.mobileNumber,
                    //       username: widget.username,
                    //       subServiceID: selectedSubService.subServiceId,
                    //       hospiatlName: selectedSubService.subServiceName,
                    //     ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Submit", style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Back", style: TextStyle(fontSize: 16))),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Copyrights(),
      ),
    );
  }
}
