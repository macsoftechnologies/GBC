import 'dart:convert';

GetProvidersModel getProvidersModelFromJson(String str) =>
    GetProvidersModel.fromJson(json.decode(str));

String getProvidersModelToJson(GetProvidersModel data) =>
    json.encode(data.toJson());

class GetProvidersModel {
  String? status;
  List<Data>? data;

  GetProvidersModel({this.status, this.data});

  factory GetProvidersModel.fromJson(Map<String, dynamic> json) =>
      GetProvidersModel(
        status: json['status'],
        data: json['data'] == null
            ? []
            : List<Data>.from(json['data'].map((x) => Data.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Data {
  String? providerId;
  String? categoryId;
  String? category;
  String? name;
  String? phoneNumber;
  String? latitude;
  String? longitude;
  String? profile;
  String? landmark;
  String? serviceIds;
  double? averageRating;
  String? reviewCount;
  String? totalOriginalPrice;
  String? totalDiscountAmount;
  String? finalPrice;
  int? discountPercentage;
  List<Services>? services;
  String? bookings;
  List<String>? matchedServices;
  int? matchedServicesCount;
  String? vacationMode;
  String? isHoliday;
  String? isAvailable;
  String? status;

  Data({
    this.providerId,
    this.categoryId,
    this.category,
    this.name,
    this.phoneNumber,
    this.latitude,
    this.longitude,
    this.profile,
    this.landmark,
    this.serviceIds,
    this.averageRating,
    this.reviewCount,
    this.totalOriginalPrice,
    this.totalDiscountAmount,
    this.finalPrice,
    this.discountPercentage,
    this.services,
    this.bookings,
    this.matchedServices,
    this.matchedServicesCount,
    this.vacationMode,
    this.isHoliday,
    this.isAvailable,
    this.status,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        providerId: json['provider_id']?.toString(),
        categoryId: json['category_id']?.toString(),
        category: json['category'],
        name: json['name'],
        phoneNumber: json['phone_number'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        profile: json['profile'],
        landmark: json['landmark'],
        serviceIds: json['service_ids'],
        averageRating: _parseDouble(json['average_rating']),
        reviewCount: json['review_count']?.toString(),
        totalOriginalPrice: json['total_original_price']?.toString(),
        totalDiscountAmount: json['total_discount_amount']?.toString(),
        finalPrice: json['final_price']?.toString(),
        discountPercentage: _parseInt(json['discount_percentage']),
        services: json['services'] == null
            ? []
            : List<Services>.from(
                json['services'].map((x) => Services.fromJson(x))),
        bookings: json['bookings']?.toString(),
        matchedServices: json['matched_services'] == null
            ? []
            : List<String>.from(json['matched_services'].map((x) => x.toString())),
        matchedServicesCount: _parseInt(json['matched_services_count']),
        vacationMode: json['vacation_mode']?.toString(),
        isHoliday: json['is_holiday']?.toString() ?? json['holiday']?.toString(),
        isAvailable: json['is_available']?.toString() ?? json['available']?.toString(),
        status: json['status']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'provider_id': providerId,
        'category_id': categoryId,
        'category': category,
        'name': name,
        'phone_number': phoneNumber,
        'latitude': latitude,
        'longitude': longitude,
        'profile': profile,
        'landmark': landmark,
        'service_ids': serviceIds,
        'average_rating': averageRating,
        'review_count': reviewCount,
        'total_original_price': totalOriginalPrice,
        'total_discount_amount': totalDiscountAmount,
        'final_price': finalPrice,
        'discount_percentage': discountPercentage,
        'services': services == null
            ? []
            : List<dynamic>.from(services!.map((x) => x.toJson())),
        'bookings': bookings,
        'matched_services': matchedServices == null
            ? []
            : List<dynamic>.from(matchedServices!.map((x) => x)),
        'matched_services_count': matchedServicesCount,
      };
}

class Services {
  String? serviceId;
  String? price;
  String? discount;
  String? discountType;
  String? discountAmount;
  String? finalPrice;

  Services({
    this.serviceId,
    this.price,
    this.discount,
    this.discountType,
    this.discountAmount,
    this.finalPrice,
  });

  factory Services.fromJson(Map<String, dynamic> json) => Services(
        serviceId: json['service_id'],
        price: json['price'],
        discount: json['discount'],
        discountType: json['discount_type'],
        discountAmount: json['discount_amount'],
        finalPrice: json['final_price'],
      );

  Map<String, dynamic> toJson() => {
        'service_id': serviceId,
        'price': price,
        'discount': discount,
        'discount_type': discountType,
        'discount_amount': discountAmount,
        'final_price': finalPrice,
      };
}

/// Helper parsers to avoid runtime exceptions
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', '')) ?? 0.0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString().replaceAll(',', '')) ?? 0;
}
