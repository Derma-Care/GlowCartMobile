class RelationModel {
  final String relation;
  final String patientId;
  final String fullname;
  final String mobileNumber;
  final String age;
  final String address;
  final String gender;

  RelationModel({
    required this.relation,
    required this.patientId,
    required this.fullname,
    required this.mobileNumber,
    required this.age,
    required this.address,
    required this.gender,
  });

  factory RelationModel.fromJson(Map<String, dynamic> json) {
    return RelationModel(
      relation: json['relation'] ?? '',
      patientId: json['patientId'] ?? '',
      fullname: json['fullname'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      age: json['age'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
    );
  }
}
