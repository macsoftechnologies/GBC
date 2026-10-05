class GetReviewsOnSubcategoryModel {
  final String? status;
  final String? message;
  final Data? data;

  GetReviewsOnSubcategoryModel({
    this.status,
    this.message,
    this.data,
  });

  factory GetReviewsOnSubcategoryModel.fromJson(Map<String, dynamic> json) {
    return GetReviewsOnSubcategoryModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (data != null) 'data': data!.toJson(),
    };
  }
}

class Data {
  final String? id;
  final String? categoryId;
  final String? providers;
  final String? reviews;
  final String? bookings;

  Data({
    this.id,
    this.categoryId,
    this.providers,
    this.reviews,
    this.bookings,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'] as String?,
      categoryId: json['category_id'] as String?,
      providers: json['providers'] as String?,
      reviews: json['reviews'] as String?,
      bookings: json['bookings'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'providers': providers,
      'reviews': reviews,
      'bookings': bookings,
    };
  }
}
