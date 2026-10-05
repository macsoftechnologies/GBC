class MainHeadCategory {
  final String id;
  final String category;
  final String image;
  final String displayOrder;
  final String count;
  final List<SubCategory> subCategories;

  MainHeadCategory({
    required this.id,
    required this.category,
    required this.image,
    required this.displayOrder,
    required this.count,
    required this.subCategories,
  });

  factory MainHeadCategory.fromJson(Map<String, dynamic> json) {
    print("Parsing MainHeadCategory id: ${json['id']}, category: ${json['category']}");

    final subCategoriesJson = json['sub_categories'];
    List<SubCategory> subCategoriesList = [];

    if (subCategoriesJson != null) {
      if (subCategoriesJson is List) {
        subCategoriesList = subCategoriesJson
            .whereType<Map<String, dynamic>>()
            .map((item) => SubCategory.fromJson(item))
            .toList();
      } else {
        print(
            "Warning: sub_categories is not a List for category id: ${json['id']}, got: ${subCategoriesJson.runtimeType}");
      }
    } else {
      print("Info: sub_categories is null for category id: ${json['id']}");
    }

    return MainHeadCategory(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      displayOrder: json['display_order']?.toString() ?? '',
      count: json['count']?.toString() ?? '',
      subCategories: subCategoriesList,
    );
  }
}

class SubCategory {
  final String sid;
  final String subCategory;
  final String subImage;

  SubCategory({
    required this.sid,
    required this.subCategory,
    required this.subImage,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {


    return SubCategory(
      sid: json['sid']?.toString() ?? '',
      subCategory: json['sub_category']?.toString() ?? '',
      subImage: json['sub_image']?.toString() ?? '',
    );
  }
}
