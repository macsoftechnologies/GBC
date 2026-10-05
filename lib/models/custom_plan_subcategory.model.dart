class GetSubcategoriesModelForCustomPlan {
  String? status;
  String? message;
  String? baseUrl;
  String? categoryName;
  List<SubCategory>? subCategory;

  GetSubcategoriesModelForCustomPlan({
    this.status,
    this.message,
    this.baseUrl,
    this.categoryName,
    this.subCategory,
  });

  factory GetSubcategoriesModelForCustomPlan.fromJson(Map<String, dynamic> json) {
    return GetSubcategoriesModelForCustomPlan(
      status: json['status'] as String?,
      message: json['message'] as String?,
      baseUrl: json['base_url'] as String?,
      categoryName: json['category_name'] as String?,
      subCategory: json['sub_category'] != null
          ? (json['sub_category'] as List)
              .map((item) => SubCategory.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'base_url': baseUrl,
        'category_name': categoryName,
        'sub_category': subCategory?.map((v) => v.toJson()).toList(),
      };
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
      id: json['id'] as String?,
      categoryId: json['category_id'] as String?,
      subCategory: json['sub_category'] as String?,
      status: json['status'] as String?,
      createdDate: json['created_date'] as String?,
      updatedDate: json['updated_date'] as String?,
      displayOrder: json['display_order'] as String?,
      subImage: json['sub_image'] as String?,
      locationId: json['location_id'] as String?,
      locationName: json['location_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
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
