class GetMySubscriptionsOverviewModel {
  final String? status;
  final String? message;
  final Data? data;

  GetMySubscriptionsOverviewModel({
    this.status,
    this.message,
    this.data,
  });

  factory GetMySubscriptionsOverviewModel.fromJson(
      Map<String, dynamic> json) {
    return GetMySubscriptionsOverviewModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? Data.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class Data {
  final String? subscriptionId;
  final String? planId;
  final String? planName;
  final String? planType;
  final String? image;
  final String? houseType;
  final String? duration;
  final String? amount;
  final String? startDate;
  final String? endDate;
  final String? status;
  final List<Services>? services;
  final int? servicesCount;
  final String? createdAt;

  Data({
    this.subscriptionId,
    this.planId,
    this.planName,
    this.planType,
    this.image,
    this.houseType,
    this.duration,
    this.amount,
    this.startDate,
    this.endDate,
    this.status,
    this.services,
    this.servicesCount,
    this.createdAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      subscriptionId: json['subscription_id'] as String?,
      planId: json['plan_id'] as String?,
      planName: json['plan_name'] as String?,
      planType: json['plan_type'] as String?,
      image: json['image'] as String?,
      houseType: json['house_type'] as String?,
      duration: json['duration'] as String?,
      amount: json['amount'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      status: json['status'] as String?,
      services: (json['services'] as List?)
          ?.map((e) => Services.fromJson(e as Map<String, dynamic>))
          .toList(),
      servicesCount: json['services_count'] as int?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'plan_id': planId,
      'plan_name': planName,
      'plan_type': planType,
      'image': image,
      'house_type': houseType,
      'duration': duration,
      'amount': amount,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'services': services?.map((e) => e.toJson()).toList(),
      'services_count': servicesCount,
      'created_at': createdAt,
    };
  }
}

class Services {
  final String? customerServiceId;
  final String? serviceId;
  final String? serviceName;
  final dynamic price;
  final int? total;
  final int? used;
  final int? remaining;
  final dynamic status;
  final String? createdAt;

  Services({
    this.customerServiceId,
    this.serviceId,
    this.serviceName,
    this.price,
    this.total,
    this.used,
    this.remaining,
    this.status,
    this.createdAt,
  });

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      customerServiceId: json['customer_service_id'] as String?,
      serviceId: json['service_id'] as String?,
      serviceName: json['service_name'] as String?,
      price: json['price'],
      total: json['total'] as int?,
      used: json['used'] as int?,
      remaining: json['remaining'] as int?,
      status: json['status'],
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_service_id': customerServiceId,
      'service_id': serviceId,
      'service_name': serviceName,
      'price': price,
      'total': total,
      'used': used,
      'remaining': remaining,
      'status': status,
      'created_at': createdAt,
    };
  }
}