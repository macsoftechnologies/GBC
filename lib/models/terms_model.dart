class GetTermsConditions {
  String? status;
  String? message;
  String? termsAndConditions;

  GetTermsConditions({
    this.status,
    this.message,
    this.termsAndConditions,
  });

  factory GetTermsConditions.fromJson(Map<String, dynamic> json) {
    return GetTermsConditions(
      status: json['status'],
      message: json['message'],
      termsAndConditions: json['terms_and_conditions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'terms_and_conditions': termsAndConditions,
    };
  }
}
