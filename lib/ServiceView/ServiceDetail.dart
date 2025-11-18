import 'dart:typed_data';

class ServiceDetails {
  final String viewDescription;
  final Uint8List viewImage;
  final String includes;
  final String readyPeriod;
  final String preparation;
  final String minTime;

  ServiceDetails({
    required this.viewDescription,
    required this.viewImage,
    required this.includes,
    required this.readyPeriod,
    required this.preparation,
    required this.minTime,
  });

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    return ServiceDetails(
      viewDescription: json['viewDescription'] ?? '',
      viewImage: json['viewimage'] ?? '',
      includes: json['includes'] ?? '',
      readyPeriod: json['readyPeriod'] ?? '',
      preparation: json['preparation'] ?? '',
      minTime: json['minTime'] ?? '',
    );
  }
}
