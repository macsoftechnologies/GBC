class GetSubCategoriesModel {
  List<DashboardSubCategoryModel> subCategories;

  GetSubCategoriesModel({
    required this.subCategories,
  });

  factory GetSubCategoriesModel.fromJson(Map<String, dynamic> json) {
    return GetSubCategoriesModel(
      subCategories: json['sub_category'] != null && json['sub_category'] is List
          ? (json['sub_category'] as List)
              .map((item) => DashboardSubCategoryModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class DashboardSubCategoryModel {
  String? id;
  String? categoryId;
  String? subCategoryName;
  String? subImage;

  DashboardSubCategoryModel({
    this.id,
    this.categoryId,
    this.subCategoryName,
    this.subImage,
  });

  factory DashboardSubCategoryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSubCategoryModel(
      id: json['id'].toString(),
      categoryId: json['category_id'] as String?,
      subCategoryName: json['sub_category'] as String?,
      subImage: json['sub_image'] as String?,
    );
  }
}
