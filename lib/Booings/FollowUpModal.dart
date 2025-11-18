class FollowUpModal {
  final String visitType;
  final String mobileNumber;
  final String serviceDate;
  final String servicetime;
  final String patientId;
  final String bookingId;
  final String doctorId;
  final String bookingFor;
  final String branchId;

  FollowUpModal({
    required this.visitType,
    required this.mobileNumber,
    required this.serviceDate,
    required this.servicetime,
    required this.patientId,
    required this.bookingId,
    required this.doctorId,
    required this.bookingFor,
    required this.branchId,
  });

  // Convert JSON → Object
  factory FollowUpModal.fromJson(Map<String, dynamic> json) {
    return FollowUpModal(
      visitType: json['visitType'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      serviceDate: json['serviceDate'] ?? '',
      servicetime: json['serviceTime'] ?? '',
      patientId: json['patientId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      bookingFor: json['bookingFor'] ?? '',
      branchId: json['branchId'] ?? '',
    );
  }

  // Convert Object → JSON
  Map<String, dynamic> toJson() {
    return {
      "visitType": visitType,
      "mobileNumber": mobileNumber,
      "serviceDate": serviceDate,
      "servicetime": servicetime,
      "patientId": patientId,
      "bookingId": bookingId,
      "doctorId": doctorId,
      "bookingFor": bookingFor,
      "branchId": branchId,
    };
  }
}
