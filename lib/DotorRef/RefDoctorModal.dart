class RefDoctor {
  final String id;
  final String clinicId;
  final String fullName;
  final String gender;
  final DateTime dateOfBirth;
  final String governmentId;
  final String medicalRegistrationNumber;
  final String specialization;
  final int yearsOfExperience;
  final String currentHospitalName;
  final String department;
  final String mobileNumber;
  final String email;
  final Address address;
  final String referralId;
  final BankAccount bankAccountNumber;
  final String status;

  RefDoctor({
    required this.id,
    required this.clinicId,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.governmentId,
    required this.medicalRegistrationNumber,
    required this.specialization,
    required this.yearsOfExperience,
    required this.currentHospitalName,
    required this.department,
    required this.mobileNumber,
    required this.email,
    required this.address,
    required this.referralId,
    required this.bankAccountNumber,
    required this.status,
  });

  factory RefDoctor.fromJson(Map<String, dynamic> json) {
    return RefDoctor(
      id: json['id'],
      clinicId: json['clinicId'],
      fullName: json['fullName'],
      gender: json['gender'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      governmentId: json['governmentId'],
      medicalRegistrationNumber: json['medicalRegistrationNumber'],
      specialization: json['specialization'],
      yearsOfExperience: json['yearsOfExperience'],
      currentHospitalName: json['currentHospitalName'],
      department: json['department'],
      mobileNumber: json['mobileNumber'],
      email: json['email'],
      address: Address.fromJson(json['address']),
      referralId: json['referralId'],
      bankAccountNumber: BankAccount.fromJson(json['bankAccountNumber']),
      status: json['status'],
    );
  }
}

class Address {
  final String houseNo;
  final String street;
  final String landmark;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  Address({
    required this.houseNo,
    required this.street,
    required this.landmark,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      houseNo: json['houseNo'],
      street: json['street'],
      landmark: json['landmark'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
    );
  }
}

class BankAccount {
  final String accountHolderName;
  final String accountNumber;
  final String bankName;
  final String branchName;
  final String ifscCode;
  final String panCardNumber;

  BankAccount({
    required this.accountHolderName,
    required this.accountNumber,
    required this.bankName,
    required this.branchName,
    required this.ifscCode,
    required this.panCardNumber,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      accountHolderName: json['accountHolderName'],
      accountNumber: json['accountNumber'],
      bankName: json['bankName'],
      branchName: json['branchName'],
      ifscCode: json['ifscCode'],
      panCardNumber: json['panCardNumber'],
    );
  }
}
