class GetCancelSubscriptionModel {
  final bool? status;
  final String? message;

  GetCancelSubscriptionModel({
    this.status,
    this.message,
  });

  factory GetCancelSubscriptionModel.fromJson(
      Map<String, dynamic> json) {
    return GetCancelSubscriptionModel(
      status: json['status'] as bool?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}