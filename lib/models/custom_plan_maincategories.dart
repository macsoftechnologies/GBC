class GetCustomPlanMainCategories {
  final String? status;
  final String? message;
  final String? baseUrl;
  final List<Category>? categories;

  GetCustomPlanMainCategories({
    this.status,
    this.message,
    this.baseUrl,
    this.categories,
  });

  factory GetCustomPlanMainCategories.fromJson(Map<String, dynamic> json) {
    return GetCustomPlanMainCategories(
      status: json['status'] as String?,
      message: json['message'] as String?,
      baseUrl: json['base_url'] as String?,
      categories: (json['categories'] as List?)
          ?.map((v) => Category.fromJson(v))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'base_url': baseUrl,
        'categories': categories?.map((v) => v.toJson()).toList(),
      };
}

class Category {
  final String? category;
  final String? id;
  final String? image;
  final String? displayOrder;
  final String? count;
  final List<SubCategory>? subCategories;

  Category({
    this.category,
    this.id,
    this.image,
    this.displayOrder,
    this.count,
    this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        category: json['category'] as String?,
        id: json['id'] as String?,
        image: json['image'] as String?,
        displayOrder: json['display_order'] as String?,
        count: json['count'] as String?,
        subCategories: (json['sub_categories'] as List?)
            ?.map((v) => SubCategory.fromJson(v))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'category': category,
        'id': id,
        'image': image,
        'display_order': displayOrder,
        'count': count,
        'sub_categories': subCategories?.map((v) => v.toJson()).toList(),
      };
}

class SubCategory {
  final String? sid;
  final String? subCategory;
  final String? subImage;

  SubCategory({this.sid, this.subCategory, this.subImage});

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
        sid: json['sid'] as String?,
        subCategory: json['sub_category'] as String?,
        subImage: json['sub_image'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'sid': sid,
        'sub_category': subCategory,
        'sub_image': subImage,
      };
}
