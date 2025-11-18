// ✅ Doctor Data Models for Service → Hospital → Doctor structure

import 'package:cutomer_app/Doctors/ListOfDoctors/DoctorSlotModel.dart';

class ServiceModel {
  final String serviceId;
  final String serviceName;
  final List<ServiceHospitalModel> hospitals;

  ServiceModel({
    required this.serviceId,
    required this.serviceName,
    required this.hospitals,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      hospitals: (json['hospitals'] as List)
          .map((e) => ServiceHospitalModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'serviceId': serviceId,
        'serviceName': serviceName,
        'hospitals': hospitals.map((e) => e.toJson()).toList(),
      };
}

class ServiceHospitalModel {
  final String hospitalId;
  final String name;
  final String address;
  final String city;
  final String contactNumber;
  final int hospitalOveralRating;
  final String hospitalRegistrations;
  final String openingTime;
  final String closingTime;
  final String hospitalLogo;
  final List<dynamic> hospitalDoucuments;
  final bool recommended;
  final List<HospitalDoctorModel> doctors;

  ServiceHospitalModel(
      {required this.hospitalId,
      required this.name,
      required this.address,
      required this.city,
      required this.contactNumber,
      required this.hospitalOveralRating,
      required this.hospitalRegistrations,
      required this.openingTime,
      required this.closingTime,
      required this.hospitalLogo,
      required this.hospitalDoucuments,
      required this.doctors,
      required this.recommended});

  factory ServiceHospitalModel.fromJson(Map<String, dynamic> json) {
    final hospitalInfo = Hospital(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      hospitalId: json['hospitalId'],
      hospitalOveralRating: json['hospitalOveralRating'] ?? 0,
      hospitalRegistrations: json['hospitalRegistrations'] ?? '',
      recommended: json['recommended'] ?? '',
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      hospitalLogo: json['hospitalLogo'] ?? '',
      hospitalDoucuments: json['hospitalDoucuments'] ?? [],
    );

    return ServiceHospitalModel(
      hospitalId: json['hospitalId'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      hospitalOveralRating: json['hospitalOveralRating'] ?? 0,
      hospitalRegistrations: json['hospitalRegistrations'] ?? '',
      openingTime: json['openingTime'] ?? '',
      closingTime: json['closingTime'] ?? '',
      hospitalLogo: json['hospitalLogo'] ?? '',
      hospitalDoucuments: json['hospitalDoucuments'] ?? [],
      recommended: json['recommended'] ?? false,
      doctors: (json['doctors'] as List)
          .map((docJson) => HospitalDoctorModel(
                id: docJson['doctorId'] ?? '',
                service: '', // Optional: assign later from outer service
                hospital: hospitalInfo,
                doctor: Doctor.fromJson(docJson),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'hospitalId': hospitalId,
        'name': name,
        'address': address,
        'city': city,
        'contactNumber': contactNumber,
        'hospitalOveralRating': hospitalOveralRating,
        'hospitalRegistrations': hospitalRegistrations,
        'openingTime': openingTime,
        'closingTime': closingTime,
        'hospitalLogo': hospitalLogo,
        'doctors': doctors.map((e) => e.toJson()).toList(),
      };
}

class HospitalDoctorModel {
  final String id;
  final String service;
  final Hospital hospital;
  final Doctor doctor;

  HospitalDoctorModel({
    required this.id,
    required this.service,
    required this.hospital,
    required this.doctor,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'service': service,
        'hospital': hospital.toJson(),
        'doctor': doctor.toJson(),
      };
}

class Hospital {
  final String hospitalId;
  final String name;
  final String address;
  final String city;
  final String contactNumber;
  final int hospitalOveralRating;
  final String hospitalRegistrations;
  final String openingTime;
  final String closingTime;
  final String hospitalLogo;
  final bool recommended;
  final List<dynamic> hospitalDoucuments;

  Hospital(
      {required this.hospitalId,
      required this.name,
      required this.address,
      required this.city,
      required this.contactNumber,
      required this.hospitalOveralRating,
      required this.hospitalRegistrations,
      required this.openingTime,
      required this.closingTime,
      required this.hospitalLogo,
      required this.hospitalDoucuments,
      required this.recommended});

  factory Hospital.fromJson(Map<String, dynamic> json) => Hospital(
        hospitalId: json['hospitalId'],
        name: json['name'] ?? '',
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        contactNumber: json['contactNumber'] ?? '',
        hospitalOveralRating: json['hospitalOveralRating'] ?? 0,
        hospitalRegistrations: json['hospitalRegistrations'] ?? '',
        openingTime: json['openingTime'] ?? '',
        closingTime: json['closingTime'] ?? '',
        hospitalLogo: json['hospitalLogo'] ?? '',
        hospitalDoucuments: json['hospitalDoucuments'] ?? [],
        recommended: json['recommended'],
      );

  Map<String, dynamic> toJson() => {
        'hospitalId': hospitalId,
        'name': name,
        'address': address,
        'city': city,
        'contactNumber': contactNumber,
        'hospitalOveralRating': hospitalOveralRating,
        'hospitalRegistrations': hospitalRegistrations,
        'openingTime': openingTime,
        'closingTime': closingTime,
        'hospitalLogo': hospitalLogo,
        'hospitalDoucuments': hospitalDoucuments,
        'recommended': recommended,
      };
}

class Doctor {
  final String doctorId;
  final String name;
  final String gender;
  final String qualification;
  final String specialization;
  final int experienceYears;
  final List<String> focusAreas;
  final String availableDays;
  final String availableTimings;
  // final List<Map<String, dynamic>> availableSlots;
  final List<DoctorSlot> slots;

  final List<String> languagesKnown;
  final String profile;
  final String profileImage;
  final List<String> careerPath;
  final List<String> highlights;
  final double overallRating;
  final bool rated;
  final bool availablity;
  bool favorites;
  final List<String> bookingSlots;
  final Fee fee;
  final Status status;
  final List<RatingComment> comments;

  Doctor({
    required this.doctorId,
    required this.name,
    required this.gender,
    required this.qualification,
    required this.specialization,
    required this.experienceYears,
    required this.focusAreas,
    required this.availableDays,
    required this.availableTimings,
    // required this.availableSlots,
    required this.slots,
    required this.languagesKnown,
    required this.profile,
    required this.profileImage,
    required this.careerPath,
    required this.highlights,
    required this.overallRating,
    required this.rated,
    required this.availablity,
    required this.favorites,
    required this.bookingSlots,
    required this.fee,
    required this.status,
    required this.comments,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      doctorId: json['doctorId'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      qualification: json['qualification'] ?? '',
      specialization: json['specialization'] ?? '',
      experienceYears: json['experienceYears'] ?? 0,
      focusAreas: List<String>.from(json['focusAreas'] ?? []),
      availableDays: json['availableDays'] ?? '',
      availableTimings: json['availableTimings'] ?? '',
      // availableSlots:List<Map<String, dynamic>>.from(json['availableSlots'] ?? []),
      slots:
          (json['slots'] as List).map((e) => DoctorSlot.fromJson(e)).toList(),

      languagesKnown: List<String>.from(json['languagesKnown'] ?? []),
      profile: json['profile'] ?? '',
      profileImage: json['profileImage'] ?? '',
      careerPath: List<String>.from(json['careerPath'] ?? []),
      highlights: List<String>.from(json['highlights'] ?? []),
      overallRating: (json['ratings']?['overall'] ?? 0).toDouble(),
      rated: json['ratings']?['rated'] ?? false,
      availablity: json['availablity'] ?? false,
      favorites: json['favorites'] ?? false,
      bookingSlots: List<String>.from(json['bookingSlots'] ?? []),
      fee: Fee.fromJson(json['fee'] ?? {}),
      status: Status.fromJson(json['status'] ?? {}),
      comments: (json['ratings']?['comments'] as List? ?? [])
          .map((e) => RatingComment.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'doctorId': doctorId,
        'name': name,
        'gender': gender,
        'qualification': qualification,
        'specialization': specialization,
        'experienceYears': experienceYears,
        'focusAreas': focusAreas,
        'availableDays': availableDays,
        'availableTimings': availableTimings,
        // 'availableSlots': availableSlots,
        'slots': slots.map((e) => e.toJson()).toList(),
        'languagesKnown': languagesKnown,
        'profile': profile,
        'profileImage': profileImage,
        'careerPath': careerPath,
        'highlights': highlights,
        'ratings': {
          'overall': overallRating,
          'rated': rated,
          'comments': comments.map((e) => e.toJson()).toList(),
        },
        'favorites': favorites,
        'availablity': availablity,
        'bookingSlots': bookingSlots,
        'fee': fee.toJson(),
        'status': status.toJson(),
      };
}


class Fee {
  final int treatmentFee;
  final int inClinicFee;
  final int videoConsultationFee;

  Fee({
    required this.treatmentFee,
    required this.inClinicFee,
    required this.videoConsultationFee,
  });

  factory Fee.fromJson(Map<String, dynamic> json) => Fee(
        treatmentFee: json['treatmentFee'] ?? 0,
        inClinicFee: json['inClinicFee'] ?? 0,
        videoConsultationFee: json['videoConsultationFee'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'treatmentFee': treatmentFee,
        'inClinicFee': inClinicFee,
        'videoConsultationFee': videoConsultationFee,
      };
}

class Status {
  final String status;
  final String? rejectionReason;

  Status({
    required this.status,
    this.rejectionReason,
  });

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        status: json['status'] ?? '',
        rejectionReason: json['rejectionReason'],
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'rejectionReason': rejectionReason,
      };
}

class RatingComment {
  final String userId;
  final int rating;
  final String comment;
  final String createdAt;
  final bool rated;
  final List<Reply> replies;

  RatingComment({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.rated,
    required this.createdAt,
    required this.replies,
  });

  factory RatingComment.fromJson(Map<String, dynamic> json) {
    return RatingComment(
      userId: json['userId'],
      rating: json['rating'],
      comment: json['comment'],
      rated: json['rated'],
      createdAt: json['createAt'],
      replies: (json['replies'] as List? ?? [])
          .map((e) => Reply.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'rated': rated,
        'createAt': createdAt,
        'replies': replies.map((e) => e.toJson()).toList(),
      };
}

class Reply {
  final String userId;
  final String reply;
  final String createAt;

  Reply({
    required this.userId,
    required this.reply,
    required this.createAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      userId: json['userId'],
      reply: json['reply'],
      createAt: json['createAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'reply': reply,
        'createAt': createAt,
      };
}
