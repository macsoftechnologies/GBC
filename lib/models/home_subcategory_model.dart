import 'dart:convert';

class GetSubCategoryModel {
  String? status;
  String? message;
  String? baseUrl;
  String? categoryName;
  List<SubCategory>? subCategory;

  GetSubCategoryModel({
    this.status,
    this.message,
    this.baseUrl,
    this.categoryName,
    this.subCategory,
  });

  factory GetSubCategoryModel.fromJson(Map<String, dynamic> json) {
    List<SubCategory>? parsedSubCategory;

    if (json['sub_category'] != null && json['sub_category'] is List) {
      parsedSubCategory = (json['sub_category'] as List).map((e) {
        if (e is String) {
          // If item is a JSON-encoded string, decode it before parsing
          final decoded = jsonDecode(e);
          return SubCategory.fromJson(decoded);
        } else if (e is Map<String, dynamic>) {
          return SubCategory.fromJson(e);
        } else {
          throw Exception('Unexpected sub_category item type: ${e.runtimeType}');
        }
      }).toList();
    }

    return GetSubCategoryModel(
      status: json['status'],
      message: json['message'],
      baseUrl: json['base_url'],
      categoryName: json['category_name'],
      subCategory: parsedSubCategory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'base_url': baseUrl,
      'category_name': categoryName,
      'sub_category': subCategory?.map((e) => e.toJson()).toList(),
    };
  }
}

class SubCategory {
  String? id;
  String? categoryId;
  String? subCategory;
  String? status;
  String? createdDate;
  String? updatedDate;
  String? displayOrder;
  String? subImage;
  String? locationId;
  String? locationName;

  SubCategory({
    this.id,
    this.categoryId,
    this.subCategory,
    this.status,
    this.createdDate,
    this.updatedDate,
    this.displayOrder,
    this.subImage,
    this.locationId,
    this.locationName,
  });

 factory SubCategory.fromJson(Map<String, dynamic> json) {
  return SubCategory(
    id: json['id']?.toString(),
    categoryId: json['category_id']?.toString(),
    subCategory: json['sub_category']?.toString(),
    status: json['status']?.toString(),
    createdDate: json['created_date']?.toString(),
    updatedDate: json['updated_date']?.toString(),
    displayOrder: json['display_order']?.toString(),
    subImage: json['sub_image']?.toString(),
    locationId: json['location_id']?.toString(),
    locationName: json['location_name']?.toString(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'sub_category': subCategory,
      'status': status,
      'created_date': createdDate,
      'updated_date': updatedDate,
      'display_order': displayOrder,
      'sub_image': subImage,
      'location_id': locationId,
      'location_name': locationName,
    };
  }
}
