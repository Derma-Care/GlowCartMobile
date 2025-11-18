import 'dart:convert';
import 'dart:typed_data';

class HospitalDoctorModel {
  final Doctor doctor;
  final Hospital hospital;

  HospitalDoctorModel({required this.doctor, required this.hospital});

  factory HospitalDoctorModel.fromJson(
      Map<String, dynamic> doctorJson, Map<String, dynamic> clinicJson) {
    return HospitalDoctorModel(
      doctor: Doctor.fromJson(doctorJson),
      hospital: Hospital.fromJson(clinicJson),
    );
  }
}

class Doctor {
  final String id;
  final String doctorId;
  final String hospitalId;
  final String doctorName;
  final String doctorPicture;
  final String doctorLicence;
  final String doctorMobileNumber;
  final List<Category> category;
  final List<Service> service;
  final List<SubServices> subServices;
  final String specialization;
  final String gender;
  final String experience;
  final String qualification;
  final String availableDays;
  final String availableTimes;
  final String profileDescription;
  final String deviceId;
  final DoctorFees doctorFees;
  final List<String> focusAreas;
  final List<String> languages;
  final List<String> highlights;
  final bool doctorAvailabilityStatus;
  final double doctorAverageRating;
  final String? doctorSignature;
  final List<Branch> branches;
  final String? associationsOrMemberships;
  Doctor({
    required this.id,
    required this.doctorId,
    required this.hospitalId,
    required this.doctorName,
    required this.doctorPicture,
    required this.doctorLicence,
    required this.doctorMobileNumber,
    required this.category,
    required this.service,
    required this.subServices,
    required this.specialization,
    required this.gender,
    required this.experience,
    required this.qualification,
    required this.availableDays,
    required this.availableTimes,
    required this.profileDescription,
    required this.doctorFees,
    required this.focusAreas,
    required this.languages,
    required this.highlights,
    required this.doctorAvailabilityStatus,
    required this.deviceId,
    required this.doctorAverageRating,
    this.doctorSignature,
    this.associationsOrMemberships,
    this.branches = const [], // default empty list
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    String? rawSign = json['doctorSignature'];

    // Uint8List? signBytes;
    // if (rawSign != null && rawSign.isNotEmpty) {
    //   try {
    //     final cleaned = rawSign.contains(",") ? rawSign.split(",")[1] : rawSign;
    //     signBytes = base64Decode(cleaned);
    //   } catch (e) {
    //     print("Doctor signature decode error: $e");
    //   }
    // }
    return Doctor(
      id: json['id'] ?? '',
      doctorId: json['doctorId'] ?? '',
      hospitalId: json['hospitalId'] ?? '',
      associationsOrMemberships: json['associationsOrMemberships'] ?? '',
      doctorAverageRating: json['doctorAverageRating'] ?? 0.0,
      doctorName: json['doctorName'] ?? '',
      doctorPicture: json['doctorPicture'] ?? '',
      doctorLicence: json['doctorLicence'] ?? '',
      doctorMobileNumber: json['doctorMobileNumber'] ?? '',
      deviceId: json['deviceId'] ?? '',
      category: (json['category'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e))
              .toList() ??
          [],
      service: (json['service'] as List<dynamic>?)
              ?.map((e) => Service.fromJson(e))
              .toList() ??
          [],
      subServices: (json['subServices'] as List<dynamic>?)
              ?.map((e) => SubServices.fromJson(e))
              .toList() ??
          [],
      specialization: json['specialization'] ?? '',
      gender: json['gender'] ?? '',
      experience: json['experience'] ?? '',
      qualification: json['qualification'] ?? '',
      availableDays: json['availableDays'] ?? '',
      availableTimes: json['availableTimes'] ?? '',
      profileDescription: json['profileDescription'] ?? '',
      doctorFees: DoctorFees.fromJson(json['doctorFees'] ?? {}),
      focusAreas: (json['focusAreas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      doctorAvailabilityStatus: json['doctorAvailabilityStatus'] ?? false,
      doctorSignature: json['doctorSignature'],
      branches: (json['branches'] as List<dynamic>?)
              ?.map((e) => Branch.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Hospital {
  final String hospitalId;
  final String name;
  final String address;
  final String city;
  final String contactNumber;
  final int freeFollowUps;
  final String openingTime;
  final String closingTime;
  final String hospitalLogo;
  final bool recommended;
  final String? consultationExpiration;
  final String branch;
  final double hospitalOverallRating;
  Hospital({
    required this.hospitalId,
    required this.name,
    required this.address,
    required this.city,
    required this.contactNumber,
    required this.openingTime,
    required this.closingTime,
    required this.hospitalLogo,
    required this.recommended,
    required this.freeFollowUps,
    required this.branch,
    this.consultationExpiration,
    required this.hospitalOverallRating,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      hospitalId: json['hospitalId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      hospitalLogo: json['hospitalLogo'] ?? '',
      recommended: json['recommended'] ?? false,
      freeFollowUps: json['freeFollowUps'] ?? 0,
      consultationExpiration: json['consultationExpiration'],
      branch: json['branch'] ?? '',
      hospitalOverallRating: json['hospitalOverallRating'] ?? 0.0,
    );
  }
}

class DoctorFees {
  final int inClinicFee;
  final int vedioConsultationFee;

  DoctorFees({
    required this.inClinicFee,
    required this.vedioConsultationFee,
  });

  factory DoctorFees.fromJson(Map<String, dynamic> json) {
    return DoctorFees(
      inClinicFee: json['inClinicFee'] ?? 0,
      vedioConsultationFee: json['vedioConsultationFee'] ?? 0,
    );
  }
}

class Category {
  final String categoryId;
  final String categoryName;

  Category({required this.categoryId, required this.categoryName});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
    );
  }
}

class Service {
  final String serviceId;
  final String serviceName;

  Service({required this.serviceId, required this.serviceName});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
    );
  }
}

class SubServices {
  final String subServiceId;
  final String subServiceName;

  SubServices({required this.subServiceId, required this.subServiceName});

  factory SubServices.fromJson(Map<String, dynamic> json) {
    return SubServices(
      subServiceId: json['subServiceId'] ?? '',
      subServiceName: json['subServiceName'] ?? '',
    );
  }
}

class Branch {
  final String branchId;
  final String branchName;

  Branch({required this.branchId, required this.branchName});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      branchId: json['branchId'] ?? '',
      branchName: json['branchName'] ?? '',
    );
  }
}
