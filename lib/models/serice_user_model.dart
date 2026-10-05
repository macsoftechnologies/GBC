class ServicesBannerModel {
  String? status;
  String? message;
  ServicePanelData? data;

  ServicesBannerModel({this.status, this.message, this.data});

  factory ServicesBannerModel.fromJson(Map<String, dynamic> json) {
    return ServicesBannerModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? ServicePanelData.fromJson(json['data'] as Map<String, dynamic>)
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

class ServicePanelData {
  String? id;
  String? categoryId;   // changed from subCategoryId
  String? providers;
  String? bookings;
  String? reviews;     

  ServicePanelData({
    this.id,
    this.categoryId,
    this.providers,
    this.bookings,
    this.reviews,
  });

  factory ServicePanelData.fromJson(Map<String, dynamic> json) {
    return ServicePanelData(
      id: json['id'] as String?,
      categoryId: json['category_id']?.toString(),  // ensure String type
      providers: json['providers']?.toString(),
      bookings: json['bookings']?.toString(),
      reviews: json['reviews']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'providers': providers,
      'bookings': bookings,
      'reviews': reviews,
    };
  }
}
