class ProviderAutoSelectModel {
  final String? status;
  final ProviderData? data;

  ProviderAutoSelectModel({
    this.status,
    this.data,
  });

  factory ProviderAutoSelectModel.fromJson(Map<String, dynamic> json) {
    return ProviderAutoSelectModel(
      status: json['status'] as String?,
      data: json['data'] != null
          ? ProviderData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
    };
  }
}

class ProviderData {
  final String? providerId;
  final String? categoryId;
  final String? category;
  final String? name;
  final String? phoneNumber;
  final dynamic latitude;
  final String? longitude;
  final String? profile;
  final dynamic landmark;
  final String? serviceIds;
  final int? averageRating;
  final String? reviewCount;
  final List<ProviderServices>? services;
  final String? totalOriginalPrice;
  final String? totalDiscountAmount;
  final String? finalPrice;
  final String? bookings;

  ProviderData({
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
    this.services,
    this.totalOriginalPrice,
    this.totalDiscountAmount,
    this.finalPrice,
    this.bookings,
  });

  factory ProviderData.fromJson(Map<String, dynamic> json) {
    return ProviderData(
      providerId: json['provider_id'] as String?,
      categoryId: json['category_id'] as String?,
      category: json['category'] as String?,
      name: json['name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      latitude: json['latitude'],
      longitude: json['longitude'] as String?,
      profile: json['profile'] as String?,
      landmark: json['landmark'],
      serviceIds: json['service_ids'] as String?,
      averageRating: json['average_rating'] is int
          ? json['average_rating']
          : int.tryParse(json['average_rating']?.toString() ?? ''),
      reviewCount: json['review_count']?.toString(),
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => ProviderServices.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalOriginalPrice: json['total_original_price']?.toString(),
      totalDiscountAmount: json['total_discount_amount']?.toString(),
      finalPrice: json['final_price']?.toString(),
      bookings: json['bookings']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'services': services?.map((e) => e.toJson()).toList(),
      'total_original_price': totalOriginalPrice,
      'total_discount_amount': totalDiscountAmount,
      'final_price': finalPrice,
      'bookings': bookings,
    };
  }
}

class ProviderServices {
  final String? serviceId;
  final String? price;
  final String? discount;
  final String? discountType;
  final String? discountAmount;
  final String? finalPrice;

  ProviderServices({
    this.serviceId,
    this.price,
    this.discount,
    this.discountType,
    this.discountAmount,
    this.finalPrice,
  });

  factory ProviderServices.fromJson(Map<String, dynamic> json) {
    return ProviderServices(
      serviceId: json['service_id']?.toString(),
      price: json['price']?.toString(),
      discount: json['discount']?.toString(),
      discountType: json['discount_type']?.toString(),
      discountAmount: json['discount_amount']?.toString(),
      finalPrice: json['final_price']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'price': price,
      'discount': discount,
      'discount_type': discountType,
      'discount_amount': discountAmount,
      'final_price': finalPrice,
    };
  }
}