class GetFeedbackModel {
  final String? status;
  final String? message;

  GetFeedbackModel({
    this.status,
    this.message,
  });

  factory GetFeedbackModel.fromJson(Map<String, dynamic> json) {
    return GetFeedbackModel(
      status: json['status'] as String?,
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