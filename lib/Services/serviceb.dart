import 'dart:convert';
import 'dart:typed_data';


class Serviceb {
  final String categoryId;
  final String categoryName;
  final Uint8List categoryImage;

  Serviceb({
    required this.categoryId,
    required this.categoryName,
    required this.categoryImage,
  });
  factory Serviceb.fromJson(Map<String, dynamic> json) {
    return Serviceb(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryImage: base64Decode(json['categoryImage'] ?? ''),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Serviceb &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId;

  @override
  int get hashCode => categoryId.hashCode;
}
