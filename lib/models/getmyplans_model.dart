class GetMySubscriptionsPlansModel {
  final bool? status;
  final List<Data>? data;

  GetMySubscriptionsPlansModel({
    this.status,
    this.data,
  });

  factory GetMySubscriptionsPlansModel.fromJson(Map<String, dynamic> json) {
    return GetMySubscriptionsPlansModel(
      status: json['status'] as bool?,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => Data.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.map((e) => e.toJson()).toList(),
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
      subscriptionId: json['subscription_id']?.toString(),
      planId: json['plan_id']?.toString(),
      planName: json['plan_name']?.toString(),
      planType: json['plan_type']?.toString(),
      image: json['image']?.toString(),
      houseType: json['house_type']?.toString(),
      duration: json['duration']?.toString(),
      amount: json['amount']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      status: json['status']?.toString(),
      services: json['services'] != null
          ? (json['services'] as List)
              .map((e) => Services.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      servicesCount: json['services_count'] as int?,
      createdAt: json['created_at']?.toString(),
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
  final String? serviceId;
  final String? serviceName;

  Services({
    this.serviceId,
    this.serviceName,
  });

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      serviceId: json['service_id']?.toString(),
      serviceName: json['service_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
    };
  }
}