class SearchCategoryModel {
  final String categoryId;
  final String categoryName;
  final String image;
  final List<SubcategoryModel> subcategories;

  SearchCategoryModel({
    required this.categoryId,
    required this.categoryName,
    required this.image,
    required this.subcategories,
  });

  factory SearchCategoryModel.fromJson(Map<String, dynamic> json) {
    return SearchCategoryModel(
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      image: json['image'],
      subcategories: (json['subcategories'] as List)
          .map((item) => SubcategoryModel.fromJson(item))
          .toList(),
    );
  }
}

class SubcategoryModel {
  final String id;
  final String name;
  final String subImage;

  SubcategoryModel({
    required this.id,
    required this.name,
    required this.subImage,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'],
      name: json['name'],
      subImage: json['sub_image'],
    );
  }
}
