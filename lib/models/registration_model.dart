class GetRegistrationModel {
  final String? status;
  final String? message;
  final int? userId;
  final String? phoneNumber;
  final String? viewAs;

  GetRegistrationModel({
    this.status,
    this.message,
    this.userId,
    this.phoneNumber,
    this.viewAs,
  });

  factory GetRegistrationModel.fromJson(Map<String, dynamic> json) {
    return GetRegistrationModel(
      status: json['status'],
      message: json['message'],
      userId: json['user_id'],
      phoneNumber: json['phone_number'],
      viewAs: json['view_as'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'user_id': userId,
      'phone_number': phoneNumber,
      'view_as': viewAs,
    };
  }
}
