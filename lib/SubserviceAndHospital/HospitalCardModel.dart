class Branch {
  final String clinicId;
  final String branchId;
  final String branchName;
  final String address;
  final String city;
  final String contactNumber;
  final String email;
  final String latitude;
  final String longitude;
  final String virtualClinicTour;
  final String kms;

  Branch(
      {required this.clinicId,
      required this.branchId,
      required this.branchName,
      required this.address,
      required this.city,
      required this.contactNumber,
      required this.email,
      required this.latitude,
      required this.longitude,
      required this.virtualClinicTour,
      required this.kms});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Branch && branchId == other.branchId;

  @override
  int get hashCode => branchId.hashCode;

  @override
  String toString() => branchName;

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      clinicId: json['clinicId'] ?? "",
      branchId: json['branchId'] ?? "",
      branchName: json['branchName'] ?? "",
      address: json['address'] ?? "",
      city: json['city'] ?? "",
      contactNumber: json['contactNumber'] ?? "",
      email: json['email'] ?? "",
      latitude: json['latitude'] ?? "",
      longitude: json['longitude'] ?? "",
      virtualClinicTour: json['virtualClinicTour'] ?? "",
      kms: json['kms'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "clinicId": clinicId,
        "branchId": branchId,
        "branchName": branchName,
        "address": address,
        "city": city,
        "contactNumber": contactNumber,
        "email": email,
        "latitude": latitude,
        "longitude": longitude,
        "virtualClinicTour": virtualClinicTour,
        "kms": kms,
      };
}

class HospitalCardModel {
  final String hospitalId;
  final String hospitalName;
  final String hospitalLogo; // base64 string
  final bool recommanded;
  final String serviceName;
  final String subServiceName;
  final double subServicePrice;
  final double price;
  final double discountedCost;
  final double taxAmount;
  final int discountPercentage;
  final double hospitalOverallRating;
  final String website;
  final double consultationFee;
  final List<Branch> branches; // 🔹 Added

  HospitalCardModel({
    required this.hospitalId,
    required this.hospitalName,
    required this.hospitalLogo,
    required this.recommanded,
    required this.serviceName,
    required this.subServiceName,
    required this.subServicePrice,
    required this.price,
    required this.discountedCost,
    required this.taxAmount,
    required this.discountPercentage,
    required this.hospitalOverallRating,
    required this.website,
    required this.consultationFee,
    required this.branches, // 🔹 Added
  });

  factory HospitalCardModel.fromJson(Map<String, dynamic> json) {
    return HospitalCardModel(
      hospitalId: json['hospitalId'] ?? "",
      hospitalName: json['hospitalName'] ?? "",
      hospitalLogo: json['hospitalLogo'] ?? "",
      recommanded: json['recommanded'] ?? false,
      serviceName: json['serviceName'] ?? "",
      subServiceName: json['subServiceName'] ?? "",
      subServicePrice: (json['subServicePrice'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
      discountedCost: (json['discountedCost'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toInt(),
      hospitalOverallRating: (json['hospitalOverallRating'] ?? 0).toDouble(),
      website: json['website'] ?? "",
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      branches: (json['branches'] as List<dynamic>?)
              ?.map((b) => Branch.fromJson(b))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        "hospitalId": hospitalId,
        "hospitalName": hospitalName,
        "hospitalLogo": hospitalLogo,
        "recommanded": recommanded,
        "serviceName": serviceName,
        "subServiceName": subServiceName,
        "subServicePrice": subServicePrice,
        "price": price,
        "discountedCost": discountedCost,
        "taxAmount": taxAmount,
        "discountPercentage": discountPercentage,
        "hospitalOverallRating": hospitalOverallRating,
        "website": website,
        "consultationFee": consultationFee,
        "branches": branches.map((b) => b.toJson()).toList(),
      };
}
