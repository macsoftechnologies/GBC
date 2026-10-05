class ServiceOverviewModel {
  String status;
  String baseUrl;
  String message;
  Data? data;

  ServiceOverviewModel({
    required this.status,
    required this.baseUrl,
    required this.message,
    this.data,
  });

  factory ServiceOverviewModel.fromJson(Map<String, dynamic> json) {
    // print("📦 ServiceOverviewModel JSON: $json"); // Comment out or remove in production

    return ServiceOverviewModel(
      status: json['status'] ?? '',
      baseUrl: json['base_url'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }
}

class Data {
  String id;
  String subCategoryId;
  String title;
  String priceConfiguration;
  String price;
  String extraChargesTitle;
  String extraChargesPrice;
  String presponsibility;
  String cresponsibility;
  String note;
  String serviceImage;
  int averageRating;
  int totalComments;
  int bookings;
  List<Gallery> gallery;
  List<Review> reviews;

  Data({
    required this.id,
    required this.subCategoryId,
    required this.title,
    required this.priceConfiguration,
    required this.price,
    required this.extraChargesTitle,
    required this.extraChargesPrice,
    required this.presponsibility,
    required this.cresponsibility,
    required this.note,
    required this.serviceImage,
    required this.averageRating,
    required this.totalComments,
    required this.bookings,
    required this.gallery,
    required this.reviews,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    // print("📥 Data JSON: $json");

    return Data(
      id: json['id']?.toString() ?? '',
      subCategoryId: json['sub_category_id']?.toString() ?? '',
      title: json['title'] ?? '',
      priceConfiguration: json['price_configuration']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      extraChargesTitle: json['extra_charges_title'] ?? '',
      extraChargesPrice: json['extra_charges_price']?.toString() ?? '',
      presponsibility: json['presponsibility'] ?? '',
      cresponsibility: json['cresponsibility'] ?? '',
      note: json['note'] ?? '',
      serviceImage: json['service_image'] ?? '',
      averageRating: int.tryParse(json['average_rating']?.toString() ?? '') ?? 0,
      totalComments: int.tryParse(json['total_comments']?.toString() ?? '') ?? 0,
      bookings: int.tryParse(json['bookings']?.toString() ?? '') ?? 0,
      gallery: (json['gallery'] as List<dynamic>?)
              ?.map((item) => Gallery.fromJson(item))
              .toList() ??
          [],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((item) => Review.fromJson(item))
              .toList() ??
          [],
    );
  }

  void operator [](String other) {}
}

class Gallery {
  String image;

  Gallery({required this.image});

  factory Gallery.fromJson(Map<String, dynamic> json) {
    // print("🖼️ Gallery JSON: $json");
    return Gallery(
      image: json['image'] ?? '',
    );
  }
}

class Review {
  String id;
  String userId;
  String orderId;
  double rating;
  String? comments;
  String createdDate;
  String status;
  String userName;
  String profile;

  Review({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.rating,
    this.comments,
    required this.createdDate,
    required this.status,
    required this.userName,
    required this.profile,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // print("⭐ Review JSON: $json");

    return Review(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      comments: json['comments'] != null && json['comments'] != 'null'
          ? json['comments']
          : null,
      createdDate: json['created_date'] ?? '',
      status: json['status']?.toString() ?? '',
      userName: json['user_name'] ?? '',
      profile: json['profile'] ?? '',
    );
  }
}
