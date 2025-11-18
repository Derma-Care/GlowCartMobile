import 'dart:convert';
import 'dart:typed_data';

import 'package:cutomer_app/BottomNavigation/Appoinments/GetAppointmentModel.dart';
import 'package:cutomer_app/Doctors/ListOfDoctors/HospitalAndDoctorModel.dart';
import 'package:cutomer_app/Review/ReviewService.dart';
import 'package:cutomer_app/Utils/Constant.dart';
import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Import the rating bar package
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../BottomNavigation/Appoinments/PostBooingModel.dart';

import '../Utils/ElevatedButtonGredint.dart';

class ReviewScreen extends StatefulWidget {
  final HospitalDoctorModel? doctorData;
  final Getappointmentmodel? doctorBookings;
  final String mobileNUmber;
  const ReviewScreen(
      {super.key,
      required this.doctorData,
      required this.doctorBookings,
      required this.mobileNUmber});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

Uint8List _getDecodedImage(String base64String) {
  try {
    // Remove the data URI prefix if it exists
    if (base64String.contains(',')) {
      base64String = base64String.split(',')[1];
    }
    return base64Decode(base64String);
  } catch (e) {
    print("⚠️ Image decode error: $e");
    // Return a blank image or fallback
    return Uint8List(0);
  }
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _doctorRating = 0.0; // Rating value for doctor
  double _hospitalRating = 0.0; // Rating value for hospital
  TextEditingController _commentController =
      TextEditingController(); // Controller for comment

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonHeader(
          title: 'Doctor & Hospital Review',
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              _buildReviewerSection(),
              SizedBox(height: 20),
              Divider(
                thickness: 1,
                height: 40,
                color: mainColor,
              ),
              SizedBox(height: 20),
              _buildHospitalRatingSection(),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: _buildSubmitButton(),
        ));
  }

  Widget _buildReviewerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                'Rate Your Experience with the Doctor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundImage: MemoryImage(
                  _getDecodedImage(widget.doctorData!.doctor.doctorPicture),
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.doctorData!.doctor.doctorName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                widget.doctorData!.doctor.specialization,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              _buildDoctorRatingSection(),
              SizedBox(height: 16),
            ],
          ),
        ),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.all(8),
          child: TextField(
            controller: _commentController,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Enter Your Comment Here...',
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        RatingBar.builder(
          initialRating: _doctorRating,
          minRating: 1,
          itemSize: 40,
          allowHalfRating: true,
          itemCount: 5,
          itemBuilder: (context, index) => Icon(
            Icons.star,
            color: index < _doctorRating ? mainColor : secondaryColor,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              _doctorRating = rating;
            });
          },
        ),
      ],
    );
  }

  Widget _buildHospitalRatingSection() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'How Was Your Experience at the Hospital?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Center(
            child: RatingBar.builder(
              initialRating: _hospitalRating,
              minRating: 1,
              itemSize: 40,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: index < _hospitalRating ? secondaryColor : mainColor,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _hospitalRating = rating;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GradientButton(
      onPressed: () async {
        print('➡️ Submit button pressed');

        print('Doctor Rating: $_doctorRating');
        print('Hospital Rating: $_hospitalRating');
        print('Comment: ${_commentController.text}');

        if (widget.doctorBookings != null) {
          print('🟢 doctorBookings is NOT null');
          print('📦 Payload values:');
          print('doctorId: ${widget.doctorBookings!.doctorId}');
          print('mobileNumber: ${widget.doctorBookings!.mobileNumber}');
          print('appointmentId: ${widget.doctorBookings!.bookingId}');
          final prefs = await SharedPreferences.getInstance();

          // final branchId = prefs.getString('branchId');
          try {
            await submitCustomerRating(
                doctorRating: _doctorRating,
                branchRating: _hospitalRating,
                feedback: _commentController.text,
                doctorId: widget.doctorBookings!.doctorId,
                customerMobileNumber: widget.mobileNUmber,
                appointmentId: widget.doctorBookings!.bookingId,
                hospitalId: widget.doctorBookings!.clinicId,
                patientId: widget.doctorBookings!.patientId,
                patientName: widget.doctorBookings!.name,
                branchId: widget.doctorBookings!.branchId ?? "");
            print('✅ submitCustomerRating called successfully');
            // After success
            Get.back(result: true);
          } catch (e) {
            print('❌ Error in submitCustomerRating: $e');
          }
        } else {
          print('🔴 doctorBookings is null');
        }
      },
      child: Text(
        "Add Review",
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
