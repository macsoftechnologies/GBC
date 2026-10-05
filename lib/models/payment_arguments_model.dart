class PaymentArguments {
  final String providerTotalOriginalPrice;
  final String providerDiscountPrice;
  final String providerId;
  final String date;
  final String time;
  final List<dynamic> services;
  final String userId;
  final String mainCategoryId;
  final List<dynamic> addons;
  final String location;
  final String address;
  final String longitude;
  final String latitude;
  final String landmark;
  final String platformFee;
  final String couponName;
  final String couponId;
  final String couponAmount;
  final String paymentId;
  final String gbCoins;
  final String subTotal;
  final String gstAmount;
  final String offHourFee;

  PaymentArguments({
    required this.providerTotalOriginalPrice,
    required this.providerDiscountPrice,
    required this.providerId,
    required this.date,
    required this.time,
    required this.services,
    required this.userId,
    required this.mainCategoryId,
    required this.addons,
    required this.location,
    required this.address,
    required this.longitude,
    required this.latitude,
    required this.landmark,
    required this.platformFee,
    required this.couponName,
    required this.couponId,
    required this.couponAmount,
    required this.paymentId,
    required this.gbCoins,
    this.subTotal = "",
    this.gstAmount = "0",
    this.offHourFee = "0",
  });

  factory PaymentArguments.fromMap(Map<String, dynamic> map) {
    return PaymentArguments(
      providerTotalOriginalPrice: map['provider_total_orignal_price']?.toString() ?? "0",
      providerDiscountPrice: map['provider_discount_price']?.toString() ?? "0",
      providerId: map['provider_id']?.toString() ?? "",
      date: map['date']?.toString() ?? "",
      time: map['time']?.toString() ?? "",
      services: map['services'] ?? [],
      userId: map['user_id']?.toString() ?? "",
      mainCategoryId: map['main_category_id']?.toString() ?? "",
      addons: map['addons'] ?? [],
      location: map['location']?.toString() ?? "",
      address: map['address']?.toString() ?? "",
      longitude: map['longitude']?.toString() ?? "",
      latitude: map['lattitude']?.toString() ?? "",
      landmark: map['landmark']?.toString() ?? "",
      platformFee: map['platform_fee']?.toString() ?? "0",
      couponName: map['coupon_name']?.toString() ?? "",
      couponId: map['coupon_id']?.toString() ?? "",
      couponAmount: map['coupon_amount']?.toString() ?? "",
      paymentId: map['payment_id']?.toString() ?? "",
      gbCoins: map['gb_coins']?.toString() ?? "",
      subTotal: map['sub_total']?.toString() ?? "",
      gstAmount: map['gst_amount']?.toString() ?? "0",
      offHourFee: map['off_hour_fee']?.toString() ?? "0",
    );
  }
}
