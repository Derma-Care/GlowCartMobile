import 'package:cutomer_app/Utils/Header.dart';
import 'package:flutter/material.dart';

import '../ListOfDoctors/DoctorModel.dart';

class Ratingandfeedbackscreen extends StatefulWidget {
  final HospitalDoctorModel doctor;
  const Ratingandfeedbackscreen({super.key, required this.doctor});

  @override
  State<Ratingandfeedbackscreen> createState() =>
      _RatingandfeedbackscreenState();
}

class _RatingandfeedbackscreenState extends State<Ratingandfeedbackscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonHeader(
      title: widget.doctor.doctor.name,
    ));
  }
}
