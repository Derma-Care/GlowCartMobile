// class Getappointmentmodel {
//   final String bookingId;
//   final String bookingFor;
//   final String name;
//   final int age;
//   final String gender;
//   final String mobileNumber;
//   final String problem;
//   final String subServiceName;
//   final String subServiceId;
//   final String doctorId;
//   final String clinicId;
//   final String serviceDate;
//   final String servicetime;
//   final String consultationType;
//   final double consultationFee;
//   final String? channelId;
//   final String status;
//   final double totalFee;
//   final String bookeAt;

//   Getappointmentmodel({
//     required this.bookingId,
//     required this.bookingFor,
//     required this.name,
//     required this.age,
//     required this.gender,
//     required this.mobileNumber,
//     required this.problem,
//     required this.subServiceName,
//     required this.subServiceId,
//     required this.doctorId,
//     required this.clinicId,
//     required this.serviceDate,
//     required this.servicetime,
//     required this.consultationType,
//     required this.consultationFee,
//     required this.channelId,
//     required this.status,
//     required this.totalFee,
//     required this.bookeAt,
//   });

//   /// Deserialize from JSON
//   factory Getappointmentmodel.fromJson(Map<String, dynamic> json) {
//     return Getappointmentmodel(
//       bookingId: json['bookingId'] ?? '',
//       bookingFor: json['bookingFor'] ?? '',
//       name: json['name'] ?? '',
//       age: int.tryParse(json['age'].toString()) ?? 0,
//       gender: json['gender'] ?? '',
//       mobileNumber: json['mobileNumber'] ?? '',
//       problem: json['problem'] ?? '',
//       subServiceName: json['subServiceName'] ?? '',
//       subServiceId: json['subServiceId'] ?? '',
//       doctorId: json['doctorId'] ?? '',
//       clinicId: json['clinicId'],
//       serviceDate: json['serviceDate'] ?? '',
//       servicetime: json['servicetime'] ?? '',
//       consultationType: json['consultationType'] ?? '',
//       consultationFee:
//           double.tryParse(json['consultationFee'].toString()) ?? 0.0,
//       channelId: json['channelId'],
//       status: json['status'] ?? '',
//       totalFee: double.tryParse(json['totalFee'].toString()) ?? 0.0,
//       bookeAt: json['bookeAt'] ?? '',
//     );
//   }

//   /// Serialize to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'bookingId': bookingId,
//       'bookingFor': bookingFor,
//       'name': name,
//       'age': age,
//       'gender': gender,
//       'mobileNumber': mobileNumber,
//       'problem': problem,
//       'subServiceName': subServiceName,
//       'subServiceId': subServiceId,
//       'doctorId': doctorId,
//       'clinicId': clinicId,
//       'serviceDate': serviceDate,
//       'servicetime': servicetime,
//       'consultationType': consultationType,
//       'consultationFee': consultationFee,
//       'channelId': channelId,
//       'status': status,
//       'totalFee': totalFee,
//       'bookeAt': bookeAt,
//     };
//   }
// }

class Getappointmentmodel {
  final String bookingId;
  final String bookingFor;
  final String name;
  final String age;
  final String gender;
  final String mobileNumber;
  final String problem;
  final String subServiceName;
  final String subServiceId;
  final String doctorId;
  final String clinicId;
  final String serviceDate;
  final String servicetime;
  final String consultationType;
  final double consultationFee;
  final String? channelId;
  final String? reasonForCancel;
  final String? notes; // ✅ make nullable
  final List<Reports>? reports; // instead of single Reports?

  final String status;
  final double totalFee;
  final String bookedAt;
  final String? relation;
  final String patientId;
  final int freeFollowUps;
  final String clinicName;
  final String doctorName;
  final List<String>? prescriptionPdf;

  final int freeFollowUpsLeft;
  // final String customerId;
  final String? branchname;
  final String? branchId;
  final String? consentFormPdf;
  final String? doctorRefCode;
  final String? followupDate;

  final int? totalSittings;
  final int? takenSittings;
  final int? pendingSittings;
  final int? currentSitting;

  final Map<String, TreatmentData>? treatments;

  Getappointmentmodel({
    required this.bookingId,
    required this.relation,
    required this.bookingFor,
    required this.name,
    required this.age,
    required this.gender,
    required this.mobileNumber,
    required this.problem,
    required this.subServiceName,
    required this.subServiceId,
    required this.doctorId,
    required this.clinicId,
    required this.serviceDate,
    required this.servicetime,
    required this.consultationType,
    required this.consultationFee,
    this.channelId,
    this.reasonForCancel,
    this.notes,
    this.reports,
    required this.status,
    required this.totalFee,
    required this.bookedAt,
    required this.patientId,
    required this.freeFollowUps,
    required this.freeFollowUpsLeft,
    required this.clinicName,
    required this.doctorName,
    // required this.customerId,
    this.branchname,
    this.consentFormPdf,
    this.doctorRefCode,
    this.branchId,
    this.prescriptionPdf,
    this.followupDate,
    this.totalSittings,
    this.takenSittings,
    this.pendingSittings,
    this.currentSitting,
    this.treatments,
  });

  factory Getappointmentmodel.fromJson(Map<String, dynamic> json) {
    try {
      return Getappointmentmodel(
        bookingId: json['bookingId']?.toString() ?? '',
        patientId: json['patientId']?.toString() ?? '',
        relation: json['relation']?.toString() ?? '',
        bookingFor: json['bookingFor']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        age: json['age']?.toString() ?? '', // always String
        gender: json['gender']?.toString() ?? '',
        mobileNumber: json['mobileNumber']?.toString() ?? '',
        problem: json['problem']?.toString() ?? '',
        subServiceName: json['subServiceName']?.toString() ?? '',
        subServiceId: json['subServiceId']?.toString() ?? '',
        doctorId: json['doctorId']?.toString() ?? '',
        clinicId: json['clinicId']?.toString() ?? '',
        serviceDate: json['serviceDate']?.toString() ?? '',
        servicetime: json['servicetime']?.toString() ?? '',
        consultationType: json['consultationType']?.toString() ?? '',
        clinicName: json['clinicName']?.toString() ?? '',
        doctorName: json['doctorName']?.toString() ?? '',
        // customerId: json['customerId'],
        branchname: json['branchname'],
        branchId: json['branchId'],
        consentFormPdf: json['consentFormPdf'],
        doctorRefCode: json['doctorRefCode'],
        followupDate: json['followupDate'],

        totalSittings: json['totalSittings'],
        takenSittings: json['takenSittings'],
        pendingSittings: json['pendingSittings'],
        currentSitting: json['currentSitting'],

        prescriptionPdf: json['prescriptionPdf'] != null
            ? List<String>.from(json['prescriptionPdf'])
            : [],

        // 👇 Safely parse doubles
        consultationFee:
            double.tryParse(json['consultationFee'].toString()) ?? 0.0,

        channelId: json['channelId']?.toString(),
        reasonForCancel: json['reasonForCancel']?.toString(),
        notes: json['notes']?.toString(),

        reports: (json['reports'] as List?)
            ?.map((e) => Reports.fromJson(e as Map<String, dynamic>))
            .toList(),

        status: json['status']?.toString() ?? '',
        freeFollowUps: json['freeFollowUps'] ?? 0,
        freeFollowUpsLeft: json['freeFollowUpsLeft'] ?? 0,

        // 👇 Same for totalFee
        totalFee: double.tryParse(json['totalFee'].toString()) ?? 0.0,

        bookedAt: json['bookedAt']?.toString() ?? '',
        treatments: json['treatments']?['generatedData'] != null
            ? (json['treatments']['generatedData'] as Map<String, dynamic>).map(
                (key, value) =>
                    MapEntry(key, TreatmentData.fromJson(value ?? {})),
              )
            : null,
      );
    } catch (e) {
      print('❌ Error parsing Getappointmentmodel: $e\nData: $json');
      rethrow;
    }
  }
}

class TreatmentData {
  final String? reason;
  final String? frequency;
  final int? sittings;
  final String? startDate;
  final int? totalSittings;
  final int? takenSittings;
  final int? pendingSittings;
  final int? currentSitting;
  final List<TreatmentDate>? dates;

  TreatmentData({
    this.reason,
    this.frequency,
    this.sittings,
    this.startDate,
    this.totalSittings,
    this.takenSittings,
    this.pendingSittings,
    this.currentSitting,
    this.dates,
  });

  factory TreatmentData.fromJson(Map<String, dynamic> json) {
    return TreatmentData(
      reason: json['reason']?.toString(),
      frequency: json['frequency']?.toString(),
      sittings: json['sittings'] is int
          ? json['sittings']
          : int.tryParse(json['sittings']?.toString() ?? '0'),
      startDate: json['startDate']?.toString(),
      totalSittings: json['totalSittings'],
      takenSittings: json['takenSittings'],
      pendingSittings: json['pendingSittings'],
      currentSitting: json['currentSitting'],
      dates: (json['dates'] as List?)
          ?.map((e) => TreatmentDate.fromJson(e))
          .toList(),
    );
  }
}

class TreatmentDate {
  final String? date;
  final int? sitting;
  final String? status;

  TreatmentDate({this.date, this.sitting, this.status});

  factory TreatmentDate.fromJson(Map<String, dynamic> json) {
    return TreatmentDate(
      date: json['date']?.toString(),
      sitting: json['sitting'] is int
          ? json['sitting']
          : int.tryParse(json['sitting']?.toString() ?? '0'),
      status: json['status']?.toString(),
    );
  }
}

class Reports {
  final List<ReportItem> reportsList;

  Reports({required this.reportsList});

  factory Reports.fromJson(Map<String, dynamic> json) {
    return Reports(
      reportsList: (json['reportsList'] as List? ?? [])
          .map((e) => ReportItem.fromJson(e))
          .toList(),
    );
  }
}

class ReportItem {
  final String bookingId;
  final String customerMobileNumber;
  final String reportName;
  final String reportDate;
  final String reportStatus;
  final String reportType;
  final List<String> reportFile;

  ReportItem({
    required this.bookingId,
    required this.customerMobileNumber,
    required this.reportName,
    required this.reportDate,
    required this.reportStatus,
    required this.reportType,
    required this.reportFile,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      bookingId: json['bookingId'],
      customerMobileNumber: json['customerMobileNumber'] ?? '',
      reportName: json['reportName'],
      reportDate: json['reportDate'],
      reportStatus: json['reportStatus'],
      reportType: json['reportType'],
      reportFile: List<String>.from(json['reportFile'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'customerMobileNumber': customerMobileNumber,
      'reportName': reportName,
      'reportDate': reportDate,
      'reportStatus': reportStatus,
      'reportType': reportType,
      'reportFile': reportFile,
    };
  }
}
