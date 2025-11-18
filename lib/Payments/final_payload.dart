class FinalPayload {
  final String? patientName;
  final String? emailAddress;
  final String? mobileNumber;
  final String? paymentType;
  final String? mihpayid;
  final String? transactionId;
  final double? price;

  FinalPayload({
    this.patientName,
    this.emailAddress,
    this.mobileNumber,
    this.paymentType,
    this.mihpayid,
    this.transactionId,
    this.price,
  });

  factory FinalPayload.fromJson(Map<String, dynamic> json) {
    return FinalPayload(
      patientName: json['PatientName'],
      emailAddress: json['EmailAddress'],
      mobileNumber: json['MobileNumber'],
      paymentType: json['payment_type'],
      mihpayid: json['mihpayid'],
      transactionId: json['transaction_id'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PatientName': patientName,
      'EmailAddress': emailAddress,
      'MobileNumber': mobileNumber,
      'payment_type': paymentType,
      'mihpayid': mihpayid,
      'transaction_id': transactionId,
      'price': price?.toStringAsFixed(2),
    };
  }
}
