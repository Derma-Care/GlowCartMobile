class RegisterModel {
  late String fullName;
  late String mobileNumber;
  late String gender;
  late String dateOfBirth;
  String? referCode;
  late String emailId;

  RegisterModel({
    required this.fullName,
    required this.mobileNumber,
    required this.gender,
    required this.dateOfBirth,
    this.referCode,
    required this.emailId,
  });

  RegisterModel.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    mobileNumber = json['mobileNumber'];
    gender = json['gender'];
    dateOfBirth = json['dateOfBirth'];
    referCode = json['referCode'];
    emailId = json['emailId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = fullName;
    data['mobileNumber'] = mobileNumber;
    data['gender'] = gender;
    data['dateOfBirth'] = dateOfBirth;
    data['referCode'] = referCode;
    data['emailId'] = emailId;
    return data;
  }
}
