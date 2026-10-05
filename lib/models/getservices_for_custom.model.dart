class GetServicesForCustomPlanModel {
  final String? status;
  final String? message;
  final String? baseUrl;
  final List<Service>? services;

  GetServicesForCustomPlanModel({
    this.status,
    this.message,
    this.baseUrl,
    this.services,
  });

  factory GetServicesForCustomPlanModel.fromJson(Map<String, dynamic> json) {
    return GetServicesForCustomPlanModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      baseUrl: json['base_url'] as String?,
      services: (json['services'] as List<dynamic>?)
          ?.map((v) => Service.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'base_url': baseUrl,
      'services': services?.map((v) => v.toJson()).toList(),
    };
  }
}

class Service {
  final String? id;
  final String? title;
  final String? defaultPrice;
  final String? presponsibility;
  final String? cresponsibility;
  final String? note;
  final String? serviceImage;
  final String? time;
  final String? servicePrice;
  final String? total;

  Service({
    this.id,
    this.title,
    this.defaultPrice,
    this.presponsibility,
    this.cresponsibility,
    this.note,
    this.serviceImage,
    this.time,
    this.servicePrice,
    this.total,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id']?.toString(),
      title: json['title'] as String?,
      defaultPrice: json['default_price']?.toString(),
      presponsibility: json['presponsibility'] as String?,
      cresponsibility: json['cresponsibility'] as String?,
      note: json['note'] as String?,
      serviceImage: json['service_image'] as String?,
      time: json['time'] as String?,
      servicePrice: json['service_price']?.toString(),
      total: json['total']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'default_price': defaultPrice,
      'presponsibility': presponsibility,
      'cresponsibility': cresponsibility,
      'note': note,
      'service_image': serviceImage,
      'time': time,
      'service_price': servicePrice,
      'total': total,
    };
  }
}
