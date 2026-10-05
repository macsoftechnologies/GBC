class GetCouponModel {
  String? status;
  String? message;
  String? couponAmount;
  int? amount;
  String? couponId;
  String? couponName;

  GetCouponModel({
    this.status,
    this.message,
    this.couponAmount,
    this.amount,
    this.couponId,
    this.couponName,
  });

  // Factory constructor to create instance from JSON
  factory GetCouponModel.fromJson(Map<String, dynamic> json) {
    return GetCouponModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      couponAmount: json['coupon_amount'] as String?,
      amount: json['amount'] != null ? int.tryParse(json['amount'].toString()) : null,
      couponId: json['coupon_id'] as String?,
      couponName: json['coupon_name'] as String?,
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'coupon_amount': couponAmount,
        'amount': amount,
        'coupon_id': couponId,
        'coupon_name': couponName,
      };
}