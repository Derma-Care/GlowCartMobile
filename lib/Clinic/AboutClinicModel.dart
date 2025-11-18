import 'package:cutomer_app/SubserviceAndHospital/HospitalCardModel.dart';

class Clinic {
  final String hospitalId;
  final String name;
  final String address;
  final String city;
  final double hospitalOverallRating;
  final String contactNumber;
  final String openingTime;
  final String closingTime;
  final String? hospitalLogo;
  final String? emailAddress;
  final String? website;
  final String? licenseNumber;
  final String? issuingAuthority;
  final bool? recommended;
  final String? clinicType;
  final String? medicinesSoldOnSite;
  final String? consultationExpiration;
  final String? subscription;
  final int? freeFollowUps;
  final double? latitude;
  final double? longitude;
  final int? nabhScore;
  final String? branch;
  final String? walkthrough;

  final List<String>? others; // Array of base64 strings
  final List<Branch>? branches;
  final String? instagramHandle;
  final String? twitterHandle;
  final String? facebookHandle;

  Clinic({
    required this.hospitalId,
    required this.name,
    required this.address,
    required this.city,
    required this.hospitalOverallRating,
    required this.contactNumber,
    required this.openingTime,
    required this.closingTime,
    this.hospitalLogo,
    this.emailAddress,
    this.website,
    this.licenseNumber,
    this.issuingAuthority,
    this.recommended,
    this.clinicType,
    this.medicinesSoldOnSite,
    this.consultationExpiration,
    this.subscription,
    this.freeFollowUps,
    this.latitude,
    this.longitude,
    this.nabhScore,
    this.branch,
    this.walkthrough,
    this.others,
    this.branches,
    this.instagramHandle,
    this.twitterHandle,
    this.facebookHandle,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      hospitalId: json['hospitalId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      hospitalOverallRating: (json['hospitalOverallRating'] ?? 0).toDouble(),
      contactNumber: json['contactNumber'] ?? '',
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      hospitalLogo: json['hospitalLogo'],
      emailAddress: json['emailAddress'],
      website: json['website'],
      licenseNumber: json['licenseNumber'],
      issuingAuthority: json['issuingAuthority'],
      recommended: json['recommended'],
      clinicType: json['clinicType'],
      medicinesSoldOnSite: json['medicinesSoldOnSite'],
      consultationExpiration: json['consultationExpiration'],
      subscription: json['subscription'],
      freeFollowUps: json['freeFollowUps'],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      nabhScore: json['nabhScore'],
      branch: json['branch'],
      walkthrough: json['walkthrough'],
      others: json['others'] != null ? List<String>.from(json['others']) : [],
      branches: json['branches'] != null
          ? (json['branches'] as List).map((b) => Branch.fromJson(b)).toList()
          : [],
      instagramHandle: json['instagramHandle'],
      twitterHandle: json['twitterHandle'],
      facebookHandle: json['facebookHandle'],
    );
  }
}

// class Branch {
//   final String id;
//   final String clinicId;
//   final String branchId;
//   final String branchName;
//   final String address;
//   final String city;
//   final String contactNumber;
//   final String email;
//   final String latitude;
//   final String longitude;
//   final String virtualClinicTour;
//   final String role;

//   Branch({
//     required this.id,
//     required this.clinicId,
//     required this.branchId,
//     required this.branchName,
//     required this.address,
//     required this.city,
//     required this.contactNumber,
//     required this.email,
//     required this.latitude,
//     required this.longitude,
//     required this.virtualClinicTour,
//     required this.role,
//   });

//   factory Branch.fromJson(Map<String, dynamic> json) {
//     return Branch(
//       id: json['id'] ?? '',
//       clinicId: json['clinicId'] ?? '',
//       branchId: json['branchId'] ?? '',
//       branchName: json['branchName'] ?? '',
//       address: json['address'] ?? '',
//       city: json['city'] ?? '',
//       contactNumber: json['contactNumber'] ?? '',
//       email: json['email'] ?? '',
//       latitude: json['latitude'] ?? '',
//       longitude: json['longitude'] ?? '',
//       virtualClinicTour: json['virtualClinicTour'] ?? '',
//       role: json['role'] ?? '',
//     );
//   }
// }
