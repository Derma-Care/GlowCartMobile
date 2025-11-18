import 'package:intl/intl.dart';

class RatingSummary {
  final String doctorId;
  final String branchId;
  final String count;
  final String hospitalId;
  final double overallDoctorRating;
  final double overallHospitalRating;
  final List<Comment> comments;

  RatingSummary({
    required this.doctorId,
    required this.branchId,
    required this.hospitalId,
    required this.overallDoctorRating,
    required this.overallHospitalRating,
    required this.comments,
    required this.count,
  });

  /// ✅ Named constructor for empty fallback
  factory RatingSummary.empty(String branchId, String doctorId) {
    return RatingSummary(
      doctorId: doctorId,
      branchId: branchId,
      hospitalId: '',
      overallDoctorRating: 0.0,
      overallHospitalRating: 0.0,
      count: "0",
      comments: [],
    );
  }

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    print("🛠️ Parsing RatingSummary from JSON: $json");

    return RatingSummary(
      doctorId: json['doctorId'] ?? '',
      branchId: json['branchId'] ?? '',
      hospitalId: json['hospitalId'] ?? '',
      count: json['count'].toString(),
      overallDoctorRating: (json['overallDoctorRating'] ?? 0).toDouble(),
      overallHospitalRating: (json['overallBranchRating'] ?? 0).toDouble(),
      comments: (json['comments'] as List? ?? []).map((item) {
        print("💬 Parsing comment: $item");
        return Comment.fromJson(Map<String, dynamic>.from(item));
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'branchId': branchId,
      'hospitalId': hospitalId,
      'count': count,
      'overallDoctorRating': overallDoctorRating,
      'overallHospitalRating': overallHospitalRating,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }
}

class Comment {
  final double doctorRating;
  final double hospitalRating;
  final String feedback;
  final String hospitalId;
  final String doctorId;
  final String customerMobileNumber;
  final String appointmentId;
  final bool rated;
  final String patientId;
  final String patientNamme;
  final String dateAndTimeAtRating;

  Comment({
    required this.doctorRating,
    required this.hospitalRating,
    required this.feedback,
    required this.hospitalId,
    required this.doctorId,
    required this.customerMobileNumber,
    required this.appointmentId,
    required this.rated,
    required this.dateAndTimeAtRating,
    required this.patientId,
    required this.patientNamme,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    print("🛠️ Parsing Comment from JSON: $json");

    return Comment(
      doctorRating: (json['doctorRating'] ?? 0).toDouble(),
      hospitalRating: (json['branchRating'] ?? 0).toDouble(), // ✅ FIX key
      feedback: json['feedback'] ?? '',
      hospitalId: json['hospitalId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      customerMobileNumber: json['customerMobileNumber'] ?? '',
      appointmentId: json['appointmentId'] ?? '',
      rated: json['rated'] ?? false,
      dateAndTimeAtRating: json['dateAndTimeAtRating'] ?? '',
      patientId: json['patientId'] ?? '',
      patientNamme: json['patientName'] ?? '', // ✅ FIX key & typo
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorRating': doctorRating,
      'hospitalRating': hospitalRating,
      'feedback': feedback,
      'hospitalId': hospitalId,
      'doctorId': doctorId,
      'customerMobileNumber': customerMobileNumber,
      'appointmentId': appointmentId,
      'rated': rated,
      'dateAndTimeAtRating': dateAndTimeAtRating,
      'patientId': patientId,
      'patientNamme': patientNamme,
    };
  }

  DateTime get parsedDateTime {
    try {
      print("Original string: $dateAndTimeAtRating");

      final parsed =
          DateFormat("dd-MM-yyyy hh:mm:ss a").parse(dateAndTimeAtRating);
      print("Parsed datetime: $parsed");
      print("Local datetime: ${parsed.toLocal()}");

      return parsed.toLocal();
    } catch (e) {
      print("Parsing failed: $e");
      return DateTime.now();
    }
  }
}
