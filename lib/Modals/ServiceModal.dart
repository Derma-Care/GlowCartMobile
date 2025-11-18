import 'dart:convert';
import 'dart:typed_data';

// class Service {
//   final String serviceName;
//   final String serviceId;
//   final String categoryName;
//   final String description;
//   final double pricing;
//   final double discount;
//   final double discountCost;
//   final double tax;
//   final double discountedCost;
//   final double finalCost;
//   final double taxAmount;
//   final String status;
//   final String minTime;
//   final String includes;
//   final String readyPeriod;
//   final String viewDescription;
//   final String preparation;
//   final Uint8List serviceImage; // To hold the decoded image
//   int quantity;

//   // Constructor with named parameters
//   Service(
//       {required this.serviceName,
//       required this.serviceId,
//       required this.categoryName,
//       required this.description,
//       required this.pricing,
//       required this.discount,
//       required this.finalCost,
//       required this.discountCost,
//       required this.discountedCost,
//       required this.minTime,
//       required this.taxAmount,
//       required this.tax,
//       required this.includes,
//       required this.readyPeriod,
//       required this.viewDescription,
//       required this.preparation,
//       required this.serviceImage, // Ensure it's a named parameter
//       this.quantity = 0,
//       required this.status});

//   // Factory constructor for creating a Service from JSON
//   factory Service.fromJson(Map<String, dynamic> json) {
//     final Map<String, dynamic> imagesMap =
//         Map<String, dynamic>.from(json['images'] ?? {});
//     final decodedImage = base64Decode(imagesMap['serviceImage'] ?? "");
//     imagesMap['serviceImage'] = decodedImage; // Decode the image

//     return Service(
//       serviceName: json['serviceName'] as String? ?? "",
//       serviceId: json['serviceId'] as String? ?? "",
//       categoryName: json['categoryName'] as String? ?? "",
//       description: json['description'] as String? ?? "",
//       minTime: json['minTime'] as String? ?? "",
//       pricing: double.tryParse(json['pricing'].toString()) ?? 0.0,
//       discount: double.tryParse(json['discount'].toString()) ?? 0.0,
//       discountCost: double.tryParse(json['discountCost'].toString()) ?? 0.0,
//       finalCost: double.tryParse(json['finalCost'].toString()) ?? 0.0,
//       tax: double.tryParse(json['tax'].toString()) ?? 0.0,
//       taxAmount: double.tryParse(json['taxAmount'].toString()) ?? 0.0,
//       discountedCost: double.tryParse(json['discountedCost'].toString()) ?? 0.0,
//       status: json['status'] as String? ?? "",
//       includes: json['includes'] as String? ?? "",
//       readyPeriod: json['readyPeriod'] as String? ?? "",
//       viewDescription: json['viewDescription'] as String? ?? "",
//       preparation: json['preparation'] as String? ?? "",
//       quantity: json['quantity'] as int? ?? 0,
//       serviceImage: decodedImage, // Pass the decoded image
//     );
//   }
// }

// [
//   {
//     "question": "What are the benefits of this service?",
//     "answers": [
//       "Fast and reliable service",
//       "24/7 customer support",
//       "Affordable pricing"
//     ]
//   },
//   {
//     "question": "How to book an appointment?",
//     "answers": [
//       "Select a service",
//       "Choose a date and time",
//       "Confirm your booking"
//     ]
//   }
// ]

import 'dart:convert';
import 'dart:typed_data';

class SubService {
  final String hospitalId;
  final String subServiceId;
  final String subServiceName;
  final String serviceId;
  final String serviceName;
  final String categoryName;
  final String categoryId;
  final String description;
  final String viewDescription;
  final String status;
  final Uint8List subServiceImage;
  final String minTime;
  final List<DescriptionQA> preProcedureQA;
  final List<DescriptionQA> procedureQA;
  final List<DescriptionQA> postProcedureQA;
  final double price;
  final double discountPercentage;
  final double taxPercentage;
  final double platformFeePercentage;
  final double discountAmount;
  final double taxAmount;
  final double platformFee;
  final double discountedCost;
  final double clinicPay;
  final double finalCost;
  final double consultationFee;
  final int gst;
  final double gstAmount;

  SubService({
    required this.hospitalId,
    required this.subServiceId,
    required this.subServiceName,
    required this.serviceId,
    required this.serviceName,
    required this.categoryName,
    required this.categoryId,
    required this.description,
    required this.viewDescription,
    required this.status,
    required this.subServiceImage,
    required this.minTime,
    required this.preProcedureQA,
    required this.procedureQA,
    required this.postProcedureQA,
    required this.price,
    required this.discountPercentage,
    required this.taxPercentage,
    required this.platformFeePercentage,
    required this.discountAmount,
    required this.taxAmount,
    required this.platformFee,
    required this.discountedCost,
    required this.clinicPay,
    required this.finalCost,
    required this.consultationFee,
    required this.gstAmount,
    required this.gst,
  });

  factory SubService.fromJson(Map<String, dynamic> json) {
    return SubService(
      hospitalId: json['hospitalId'] ?? '',
      subServiceId: json['subServiceId'] ?? '',
      subServiceName: json['subServiceName'] ?? '',
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryId: json['categoryId'] ?? '',
      description: json['description'] ?? '',
      viewDescription: json['viewDescription'] ?? '',
      status: json['status'] ?? '',
      subServiceImage: (json['subServiceImage'] != null &&
              json['subServiceImage'].isNotEmpty)
          ? base64Decode(json['subServiceImage'])
          : Uint8List(0),
      minTime: json['minTime'] ?? '',
      preProcedureQA: (json['preProcedureQA'] as List<dynamic>?)
              ?.map((e) => DescriptionQA.fromJson(e))
              .toList() ??
          [],
      procedureQA: (json['procedureQA'] as List<dynamic>?)
              ?.map((e) => DescriptionQA.fromJson(e))
              .toList() ??
          [],
      postProcedureQA: (json['postProcedureQA'] as List<dynamic>?)
              ?.map((e) => DescriptionQA.fromJson(e))
              .toList() ??
          [],
      price: (json['price'] ?? 0).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      taxPercentage: (json['taxPercentage'] ?? 0).toDouble(),
      platformFeePercentage: (json['platformFeePercentage'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      platformFee: (json['platformFee'] ?? 0).toDouble(),
      discountedCost: (json['discountedCost'] ?? 0).toDouble(),
      clinicPay: (json['clinicPay'] ?? 0).toDouble(),
      finalCost: (json['finalCost'] ?? 0).toDouble(),
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0),
      gstAmount: (json['gstAmount'] ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hospitalId': hospitalId,
      'subServiceId': subServiceId,
      'subServiceName': subServiceName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'categoryName': categoryName,
      'categoryId': categoryId,
      'description': description,
      'viewDescription': viewDescription,
      'status': status,
      'subServiceImage': base64Encode(subServiceImage),
      'minTime': minTime,
      'preProcedureQA': preProcedureQA.map((e) => e.toJson()).toList(),
      'procedureQA': procedureQA.map((e) => e.toJson()).toList(),
      'postProcedureQA': postProcedureQA.map((e) => e.toJson()).toList(),
      'price': price,
      'discountPercentage': discountPercentage,
      'taxPercentage': taxPercentage,
      'platformFeePercentage': platformFeePercentage,
      'discountAmount': discountAmount,
      'taxAmount': taxAmount,
      'platformFee': platformFee,
      'discountedCost': discountedCost,
      'clinicPay': clinicPay,
      'finalCost': finalCost,
      'consultationFee': consultationFee,
      'gst': gst,
      'gstAmount': gstAmount,
    };
  }
}

class DescriptionQA {
  final Map<String, List<String>> qa;

  DescriptionQA({required this.qa});

  factory DescriptionQA.fromJson(Map<String, dynamic> json) {
    return DescriptionQA(
      qa: Map<String, List<String>>.from(
        json.map((key, value) => MapEntry(
            key,
            List<String>.from(
                (value as List<dynamic>).map((e) => e.toString())))),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return qa;
  }
}

class Service {
  final String serviceId;
  final String serviceName;
  final String categoryName;
  final String categoryId;
  final String description;
  final Uint8List serviceImage;

  Service({
    required this.serviceId,
    required this.serviceName,
    required this.categoryName,
    required this.categoryId,
    required this.description,
    required this.serviceImage,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryId: json['categoryId'] ?? '',
      description: json['description'] ?? '',
      serviceImage: base64Decode(json['serviceImage'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'categoryName': categoryName,
      'categoryId': categoryId,
      'description': description,
      'serviceImage': base64Encode(serviceImage),
    };
  }
}

//SUbservice model

class CategoryAdmin {
  final String id;
  final String categoryId;
  final String categoryName;
  final List<SubServiceAdmin> subServices;

  CategoryAdmin({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.subServices,
  });

  factory CategoryAdmin.fromJson(Map<String, dynamic> json) {
    return CategoryAdmin(
      id: json['id'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      subServices: (json['subServices'] as List)
          .map((e) => SubServiceAdmin.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'subServices': subServices.map((s) => s.toJson()).toList(),
      };
}

class SubServiceAdmin {
  final String subServiceId;
  final String subServiceName;
  final String serviceName;
  final String serviceId;

  SubServiceAdmin({
    required this.subServiceId,
    required this.subServiceName,
    required this.serviceName,
    required this.serviceId,
  });

  factory SubServiceAdmin.fromJson(Map<String, dynamic> json) {
    return SubServiceAdmin(
      subServiceId: json['subServiceId'],
      subServiceName: json['subServiceName'],
      serviceName: json['serviceName'],
      serviceId: json['serviceId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'subServiceId': subServiceId,
        'subServiceName': subServiceName,
        'serviceName': serviceName,
        'serviceId': serviceId,
      };
}
