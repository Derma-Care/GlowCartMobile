import 'dart:convert';

class AppointmentData {
  final String appointmentId;
  final String patientName;
  final String relationShip;
  final String patientNumber;
  final String gender;
  final String emailId;
  final String age;
  final String customerNumber;
  final String categoryName;
  final List<ServiceAdded> servicesAdded;
  final double totalPrice;
  final double totalDiscountAmount;
  final double totalDiscountedAmount;
  final double totalTax;
  final double payAmount;
  final String bookedAt;

  AppointmentData({
    required this.appointmentId,
    required this.patientName,
    required this.relationShip,
    required this.patientNumber,
    required this.gender,
    required this.emailId,
    required this.age,
    required this.customerNumber,
    required this.categoryName,
    required this.servicesAdded,
    required this.totalPrice,
    required this.totalDiscountAmount,
    required this.totalDiscountedAmount,
    required this.totalTax,
    required this.payAmount,
    required this.bookedAt,
  });

  factory AppointmentData.fromJson(Map<String, dynamic> json) {
    return AppointmentData(
      appointmentId: json['appointmentId'],
      patientName: json['patientName'],
      relationShip: json['relationShip'],
      patientNumber: json['patientNumber'],
      gender: json['gender'],
      emailId: json['emailId'],
      age: json['age'],
      customerNumber: json['customerNumber'],
      categoryName: json['categoryName'],
      servicesAdded: (json['servicesAdded'] as List)
          .map((item) => ServiceAdded.fromJson(item))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      totalDiscountAmount: (json['totalDiscountAmount'] as num).toDouble(),
      totalDiscountedAmount: (json['totalDiscountedAmount'] as num).toDouble(),
      totalTax: (json['totalTax'] as num).toDouble(),
      payAmount: (json['payAmount'] as num).toDouble(),
      bookedAt: json['bookedAt'],
    );
  }
}

class ServiceAdded {
  final String status;
  final String serviceId;
  final String serviceName;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final int numberOfDays;
  final String numberOfHours;
  final double price;
  final int discount;
  final double discountAmount;
  final double discountedCost;
  final int tax;
  final double taxAmount;
  final double finalCost;
  final String? startPin;
  final String? endPin;

  ServiceAdded({
    required this.status,
    required this.serviceId,
    required this.serviceName,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.numberOfDays,
    required this.numberOfHours,
    required this.price,
    required this.discount,
    required this.discountAmount,
    required this.discountedCost,
    required this.tax,
    required this.taxAmount,
    required this.finalCost,
    this.startPin,
    this.endPin,
  });

  factory ServiceAdded.fromJson(Map<String, dynamic> json) {
    return ServiceAdded(
      status: json['status'],
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      numberOfDays: json['numberOfDays'],
      numberOfHours: json['numberOfHours'],
      price: json['price'],
      discount: json['discount'],
      discountAmount: json['discountAmount'],
      discountedCost: json['discountedCost'],
      tax: json['tax'],
      taxAmount: json['taxAmount'],
      finalCost: json['finalCost'],
      startPin: json['startPin'],
      endPin: json['endPin'],
    );
  }
}
// List<AppointmentData> appointments = (json['data'] as List)
//     .map((item) => AppointmentData.fromJson(item))
//     .toList();
