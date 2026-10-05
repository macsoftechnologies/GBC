// ignore: camel_case_types
class GetServicesModel {
  String? status;
  String? message;
  String? baseUrl;
  List<Service> services;

  GetServicesModel({
    this.status,
    this.message,
    this.baseUrl,
    this.services = const [],
  });

  factory GetServicesModel.fromJson(Map<String, dynamic> json) {
    return GetServicesModel(
      status: json['status'],
      message: json['message'],
      baseUrl: json['base_url'],
      services: (json['services'] as List<dynamic>?)
              ?.map((v) => Service.fromJson(v))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'base_url': baseUrl,
      'services': services.map((v) => v.toJson()).toList(),
    };
  }
}

class Service {
  String? id;
  String? title;
  String? price;
  String? presponsibility;
  String? cresponsibility;
  String? note;
  String? serviceImage;
  String? time;
  double? averageRating;
  String? totalReviews;
  List<dynamic>? gallery;
  int? bookings;

  // Optional fields from your previous model
  String? locationName;
  int? subServices;

  Service({
    this.id,
    this.title,
    this.price,
    this.presponsibility,
    this.cresponsibility,
    this.note,
    this.serviceImage,
    this.time,
    this.averageRating,
    this.totalReviews,
    this.gallery,
    this.bookings,
    this.locationName,
    this.subServices,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      presponsibility: json['presponsibility'],
      cresponsibility: json['cresponsibility'],
      note: json['note'],
      serviceImage: json['service_image'],
      time: json['time'],
      averageRating: (json['average_rating'] != null)
          ? double.tryParse(json['average_rating'].toString())
          : null,
      totalReviews: json['total_reviews']?.toString(),
      gallery: json['gallery'] ?? [],
      bookings: json['bookings'] is int
          ? json['bookings']
          : int.tryParse(json['bookings'].toString()),
      locationName: json['location_name'],
      subServices: json['sub_services'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'presponsibility': presponsibility,
      'cresponsibility': cresponsibility,
      'note': note,
      'service_image': serviceImage,
      'time': time,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'gallery': gallery,
      'bookings': bookings,
      'location_name': locationName,
      'sub_services': subServices,
    };
  }
}
