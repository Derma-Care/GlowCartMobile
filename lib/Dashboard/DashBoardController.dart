import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cutomer_app/Dashboard/ImagePreview.dart';
import 'package:cutomer_app/Modals/ServiceModal.dart';
import 'package:cutomer_app/Notification/LocalNotification.dart';
import 'package:cutomer_app/Utils/ScaffoldMessageSnacber.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../APIs/BaseUrl.dart';
import '../APIs/FetchServices.dart';
import '../BottomNavigation/Appoinments/AppointmentService.dart';
import '../BottomNavigation/Appoinments/BookingModal.dart';
import '../BottomNavigation/Appoinments/GetAppointmentModel.dart';
import '../Services/CarouselSliderService.dart';
import '../Services/serviceb.dart';

class Dashboardcontroller extends GetxController {
  final AppointmentService _appointmentService = AppointmentService();
  final ImagePicker _picker = ImagePicker();
  final CarouselSliderService carouselSliderService = CarouselSliderService();

  final Rx<File?> imageFile = Rx<File?>(null);
  final RxBool isLoading = true.obs;
  final RxList<Serviceb> services = <Serviceb>[].obs;
  final RxList<Getappointmentmodel> allAppointments =
      <Getappointmentmodel>[].obs;
  final RxList<String> carouselImages = <String>[].obs;
  final RxList<String> carouseServicelImages = <String>[].obs;
  final selectedService = Rxn<Serviceb>();

  var selectedSubService = Rxn<Service>();
  var selectedSubSubService = Rxn<SubServiceAdmin>();
  var serviceList = <Serviceb>[];

  var subServiceList = <Service>[].obs;
  var subServiceArray = <SubServiceAdmin>[].obs;

  String statusMessage = "";

  RxString mobileNumber = ''.obs;
  void setMobileNumber(String number) {
    mobileNumber.value = number;
  }

  File? _imageFile;

  void fetchSubServices(String categoryId) async {
    print("categoryId ${categoryId}");
    final result = await ServiceFetcher().fetchServices(categoryId);
    subServiceList.assignAll(result);
    print("subServiceList ${subServiceList}");
  }

  void fetchSubSubServices(String serviceId) async {
    print("categoryId ${serviceId}");
    final result = await ServiceFetcher().fetchsubServices(serviceId);
    subServiceArray.assignAll(result);
    print("subServiceArray ${subServiceArray}");
  }

  /// Store user session data
  void storeUserData(String mobileNumber, String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
  }

  /// Load saved profile image
  Future<void> loadSavedImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('profile_image');
    if (savedImagePath != null && File(savedImagePath).existsSync()) {
      imageFile.value = File(savedImagePath);
    }
  }

  void scheduleAlertsForUpcomingVideoCalls(List appointments) {
    for (var appt in appointments) {
      final type = appt.consultationType.toLowerCase();
      final status = appt.status.toLowerCase();

      if ((type == 'video consultation' || type == 'online consultation') &&
          !['completed', 'cancelled'].contains(status)) {
        final callTime =
            DateTime.parse(appt.scheduledTime); // use your real field
        if (callTime.difference(DateTime.now()) > Duration(minutes: 6)) {
          scheduleVideoCallNotification(
            title: 'Doctor Video Call',
            body: 'Your video call with the doctor starts in 5 minutes.',
            videoCallTime: callTime,
          );
        }
      }
    }
  }

  void clearAfterAppointment() async {
    // Clear selected services
    // Get.snackbar("Success", "Appointment booked and form reset!",
    //     snackPosition: SnackPosition.BOTTOM);

    selectedService.value = null;
    selectedSubService.value = null;
    selectedSubSubService.value = null;
    subServiceList.clear();
    subServiceArray.clear();
  }

  // /// Pick new image and store in SharedPreferences
  // Future<void> _pickImage(ImageSource source) async {
  //   final pickedFile = await _picker.pickImage(source: source);
  //   if (pickedFile != null) {
  //     final file = File(pickedFile.path);
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     prefs.setString('profile_image', file.path);
  //     imageFile.value = file;
  //   }
  // }
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      // Store the file path in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('profile_image', file.path);

      // Update the reactive imageFile variable
      imageFile.value = file;
    }
  }

  // Load the stored profile image from SharedPreferences
  Future<void> loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image');

    if (imagePath != null && imagePath.isNotEmpty) {
      // If the image path exists, load the image file
      imageFile.value = File(imagePath);
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadProfileImage(); // Load the image when the controller is initialized
  }

  /// Show modal to pick image from gallery or camera
  void showImagePickerOptions(BuildContext context, image) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.preview),
                title: const Text('Preview'),
                onTap: () {
                  // Ensure that the image exists
                  if (image != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ImagePreviewScreen(imagePath: image),
                      ),
                    );
                  } else {
                    // Handle case where no image is selected
                       ScaffoldMessageSnackbar.show(
                  context: context,
                  message: "No image selected for preview",
                  type: SnackbarType.warning,
                );
                     
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Fetch user appointments
  Future<void> fetchAppointments(String mobileNumber) async {
    if (mobileNumber.trim().isEmpty) {
      // No mobile number provided, clear list and exit
      allAppointments.clear();
      return;
    }

    try {
      isLoading.value = true;

      // Fetch all appointments from the service
      final appointments =
          await _appointmentService.fetchAppointments(mobileNumber);

      if (appointments != null && appointments.isNotEmpty) {
        // Filter appointments with status 'in_progress' (case-insensitive)
        final filtered = appointments
            .where((appointment) =>
                appointment.status.toLowerCase() == 'in_progress')
            .toList();

        // Update reactive list
        allAppointments.assignAll(filtered);
      } else {
        // No appointments found
        allAppointments.clear();
      }
    } catch (e) {
      // Handle error gracefully
      print("Error fetching appointments: $e");
      allAppointments.clear();
    } finally {
      // Always set loading to false at the end
      isLoading.value = false;
    }
  }

  /// Fetch images for carousel
  Future<void> fetchImages() async {
    try {
      final images = await carouselSliderService.fetchImages();
      carouselImages.assignAll(images);
      print("imagesimages lengrt ${images.length}");
    } catch (e) {
      print("Error fetching images: $e");
    }
  }

  /// Fetch service images for carousel
  Future<void> fetchserviceImages() async {
    try {
      final images = await carouselSliderService.fetchServiceImages();
      carouseServicelImages.assignAll(images);
      print("imagesimages fetchServiceImages ${images.length}");
    } catch (e) {
      print("Error fetching images: $e");
    }
  }

  /// Fetch services/categories
  Future<void> fetchUserServices() async {
    isLoading.value = true;
    try {
      print("Starting API call to fetch services...");
      isLoading.value = true;
      statusMessage = 'Fetching services...';

      final response = await http
          .get(Uri.parse(categoryUrl))
          .timeout(const Duration(seconds: 20), onTimeout: () {
        isLoading.value = false;
        statusMessage =
            'Your network seems to be down! \n Please check your internet connection.';
        print("Error: Network timeout.");
        throw TimeoutException('Network timeout');
      });

      print("response.statusCoderesponse.statusCode ${response}");

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        isLoading.value = false;
        print("response.statusCoderesponse.statusCode ${response}");

        if (responseBody['data'] != null && responseBody['data'] is List) {
          final List<dynamic> serviceList = responseBody['data'];

          services.assignAll(serviceList.map((serviceData) {
            return Serviceb.fromJson({
              'categoryId': serviceData['categoryId'] ?? '',
              'categoryName': serviceData['categoryName'] ?? '',
              'categoryImage': serviceData['categoryImage'] ?? '',
            });
          }).toList());

          statusMessage = 'Services fetched successfully!';
        } else {
          statusMessage = 'Invalid data format received.';
        }
      } else {
        statusMessage =
            'Failed to fetch services. Status code: ${response.statusCode}';
      }
    } catch (e) {
      isLoading.value = false;
      statusMessage = e is TimeoutException
          ? 'Your network seems to be down! \n Please check your internet connection.'
          : 'An error occurred while fetching services.';
      print("Error fetching services: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull to refresh
  // Future<void> onRefresh(String mobileNumber) async {
  //   await fetchUserServices();
  //   await fetchAppointments(mobileNumber);
  //   await fetchImages();
  // }
  Future<void> onRefresh(String mobileNumber) async {
    isLoading.value = true; // start loading

    try {
      // Fetch services
      await fetchUserServices;

      // Fetch bookings or other needed data
      await fetchAppointments(mobileNumber);
      await fetchImages();
      await fetchserviceImages();
      // ✅ Only after data is fetched, stop loading
      isLoading.value = false;
    } catch (e) {
      // handle errors
      statusMessage = "Something went wrong. Please try again.";
      isLoading.value = false;
    }
  }
}
