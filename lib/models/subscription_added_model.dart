class GetSubscriptionStatusModel {
  final bool status;
  final String message;
  final Map<String, dynamic>? data;

  GetSubscriptionStatusModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory GetSubscriptionStatusModel.fromJson(
      Map<String, dynamic> json) {
    return GetSubscriptionStatusModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}