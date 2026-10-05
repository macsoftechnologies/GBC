class GetMySubscriptionModel {
  bool? status;
  List<Data>? data;

  GetMySubscriptionModel({this.status, this.data});

  factory GetMySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return GetMySubscriptionModel(
      status: json['status'],
      data: json['data'] != null
          ? List<Data>.from(
              json['data'].map((v) => Data.fromJson(v)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}

class Data {
  String? subscriptionId;
  String? planId;
  String? planName;
  String? planType;
  String? image;
  String? houseType;
  String? duration;
  String? amount;
  String? startDate;
  String? endDate;
  String? status;
  List<Services>? services;
  int? servicesCount;
  String? createdAt;

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
      subscriptionId: json['subscription_id'],
      planId: json['plan_id'],
      planName: json['plan_name'],
      planType: json['plan_type'],
      image: json['image'],
      houseType: json['house_type'],
      duration: json['duration'],
      amount: json['amount'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      services: json['services'] != null
          ? List<Services>.from(
              json['services'].map((v) => Services.fromJson(v)),
            )
          : null,
      servicesCount: json['services_count'],
      createdAt: json['created_at'],
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
      'services': services?.map((v) => v.toJson()).toList(),
      'services_count': servicesCount,
      'created_at': createdAt,
    };
  }
}

class Services {
  String? serviceId;
  String? serviceName;

  Services({this.serviceId, this.serviceName});

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      serviceId: json['service_id'],
      serviceName: json['service_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
    };
  }
}