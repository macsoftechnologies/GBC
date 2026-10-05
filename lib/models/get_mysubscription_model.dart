class GetMySubscriptionModel {
  final String? status;
  final String? message;
  final List<Data>? data;

  GetMySubscriptionModel({
    this.status,
    this.message,
    this.data,
  });

  factory GetMySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return GetMySubscriptionModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? List<Data>.from(json['data'].map((x) => Data.fromJson(x)))
          : [],
    );
  }
}

class Data {
  final String? subscriptionId;
  final String? paymentId;
  final String? userId;
  final String? planId;
  final String? couponName;
  final String? couponCode;
  final String? couponAmount;
  final String? gst;
  final String? subTotal;
  final String? totalAmount;
  final String? scheduleDate;
  final String? scheduleTime;
  final String? expiryDate;
  final String? validity;
  final String? subscriptionStatus;
  final String? createdDate;
  final String? planLevel;
  final Plan? plan;

  Data({
    this.subscriptionId,
    this.paymentId,
    this.userId,
    this.planId,
    this.couponName,
    this.couponCode,
    this.couponAmount,
    this.gst,
    this.subTotal,
    this.totalAmount,
    this.scheduleDate,
    this.scheduleTime,
    this.expiryDate,
    this.validity,
    this.subscriptionStatus,
    this.createdDate,
    this.planLevel,
    this.plan,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      subscriptionId: json['subscription_id'],
      paymentId: json['payment_id'],
      userId: json['user_id'],
      planId: json['plan_id'],
      couponName: json['coupon_name'],
      couponCode: json['coupon_code'],
      couponAmount: json['coupon_amount'],
      gst: json['gst'],
      subTotal: json['sub_total'],
      totalAmount: json['total_amount'],
      scheduleDate: json['schedule_date'],
      scheduleTime: json['schedule_time'],
      expiryDate: json['expiry_date'],
      validity: json['validity'],
      subscriptionStatus: json['subscription_status'],
      createdDate: json['created_date'],
      planLevel: json['plan_level'],
      plan: json['plan'] != null ? Plan.fromJson(json['plan']) : null,
    );
  }
}

class Plan {
  final String? planName;
  final String? planType;
  final String? duration;
  final String? validity;
  final String? price;
  final String? description;
  final String? image;
  final List<Services>? services;

  Plan({
    this.planName,
    this.planType,
    this.duration,
    this.validity,
    this.price,
    this.description,
    this.image,
    this.services,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      planName: json['plan_name'],
      planType: json['plan_type'],
      duration: json['duration'],
      validity: json['validity'],
      price: json['price'],
      description: json['description'],
      image: json['image'],
      services: json['services'] != null
          ? List<Services>.from(
              json['services'].map((x) => Services.fromJson(x)))
          : [],
    );
  }
}

class Services {
  final String? serviceId;
  final String? servicePrice;
  final String? serviceName;
  final String? total;

  Services({
    this.serviceId,
    this.servicePrice,
    this.serviceName,
    this.total,
  });

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      serviceId: json['service_id'],
      servicePrice: json['service_price'],
      serviceName: json['service_name'],
      total: json['total'],
    );
  }
}