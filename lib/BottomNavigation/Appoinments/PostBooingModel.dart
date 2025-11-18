import 'dart:convert';
import 'dart:io';

import '../../PatientsDetails/PatientModel.dart';

class BookingDetailsModel {
  final String categoryName;
  final String categoryId;
  final String servicename;
  final String serviceId;
  final String subServiceName;
  final String subServiceId;
  final String clinicId;
  final String clinicName;
  final String clinicAddress;
  final String doctorId;
  final String doctorName;
  final String doctorDeviceId;
  final String consultationType;
  final double consultationFee;
  final double totalFee;
  final String consultationExpiration;
  final String paymentType;
  final String visitType;
  final String symptomsDuration;
  final List<File>? attachments; // ✅ optional
  final int freeFollowUps;
  final String consentFormPdf;
  final String? doctorRefCode;
  final String customerId;
  final String branchname;
  final String branchId;
 

  BookingDetailsModel({
    required this.categoryName,
    required this.categoryId,
    required this.servicename,
    required this.serviceId,
    required this.subServiceName,
    required this.subServiceId,
    required this.clinicId,
    required this.clinicName,
    required this.clinicAddress,
    required this.doctorId,
    required this.doctorName,
    required this.doctorDeviceId,
    required this.consultationType,
    required this.consultationFee,
    required this.totalFee,
    required this.consultationExpiration,
    required this.paymentType,
    required this.visitType,
    required this.symptomsDuration,
    required this.freeFollowUps,
    required this.consentFormPdf,
    this.doctorRefCode,
    required this.customerId,
    required this.branchname,
    required this.branchId,
  
    this.attachments, // ✅ nullable
  });

  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailsModel(
      categoryName: json['categoryName'],
      // consultationExpiration: json['consultationExpiration'],
      categoryId: json['categoryId'],
      symptomsDuration: json['symptomsDuration'],
      servicename: json['servicename'],
      serviceId: json['serviceId'],
      subServiceName: json['subServiceName'],
      doctorRefCode: json['doctorRefCode'],
      subServiceId: json['subServiceId'],
      clinicId: json['clinicId'],
      clinicName: json['clinicName'],
      clinicAddress: json['clinicAddress'],
   

      doctorId: json['doctorId'],
      consentFormPdf: json['consentFormPdf'],
      doctorName: json['doctorName'],
      customerId: json['customerId'],
      branchname: json['branchname'],
      branchId: json['branchId'],
      doctorDeviceId: json['doctorDeviceId'],
      consultationType: json['consultationType'],
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      freeFollowUps: (json['freeFollowUps'] ?? 0),
      totalFee: (json['totalFee'] ?? 0).toDouble(),
      paymentType: json["paymentType"] ?? "",
      attachments: json["attachments"] != null
          ? List<File>.from(json["attachments"])
          : null,
      consultationExpiration: json["consultationExpiration"] ?? "",
      visitType: json["visitType"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
    
      // 'consultationExpiration': consultationExpiration,
      'categoryId': categoryId,
      'symptomsDuration': symptomsDuration,
      'servicename': servicename,
      'serviceId': serviceId,
      'subServiceName': subServiceName,
      'subServiceId': subServiceId,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorDeviceId': doctorDeviceId,
      'consultationType': consultationType,
      'consultationFee': consultationFee,
      'totalFee': totalFee,
      "paymentType": paymentType,
      "consentFormPdf": consentFormPdf,
      "customerId": customerId,
      "branchname": branchname,
      "branchId": branchId,
      "doctorRefCode": doctorRefCode,
      "attachments": attachments != null
          ? attachments!
              .map((file) =>
                  base64Encode(file.readAsBytesSync())) // ✅ convert to base64
              .toList()
          : [],
      "consultationExpiration": consultationExpiration,
      "visitType": visitType,
      "freeFollowUps": freeFollowUps,
    };
  }
}

class PostBookingModel {
  final PatientModel patient;
  final BookingDetailsModel booking;
  PostBookingModel({
    required this.patient,
    required this.booking,
  });

  factory PostBookingModel.fromJson(Map<String, dynamic> json) {
    return PostBookingModel(
      patient: PatientModel.fromJson(json),
      booking: BookingDetailsModel.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...patient.toJson(),
      ...booking.toJson(),
    };
  }
}
