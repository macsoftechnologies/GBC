class SubcategoriesModel {
  final String? status;
  final String? message;
  final String? baseUrl;
  final List<SubCategory>? subCategory;

  SubcategoriesModel({
    this.status,
    this.message,
    this.baseUrl,
    this.subCategory,
  });

  factory SubcategoriesModel.fromJson(Map<String, dynamic> json) {
    return SubcategoriesModel(
      status: json['status'],
      message: json['message'],
      baseUrl: json['base_url'],
      subCategory: json['sub_category'] != null
          ? (json['sub_category'] as List)
              .map((e) => SubCategory.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'base_url': baseUrl,
        'sub_category': subCategory?.map((e) => e.toJson()).toList(),
      };
}


class SubCategory {
  final String? id;
  final String? categoryId;
  final String? subCategory;
  final String? status;
  final String? createdDate;
  final String? updatedDate;
  final String? displayOrder;
  final String? subImage;
  final String? locationId;
  final String? locationName;
  final List<ServicesModel>? services;

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
    this.services,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      categoryId: json['category_id'],
      subCategory: json['sub_category'],
      status: json['status'],
      createdDate: json['created_date'],
      updatedDate: json['updated_date'],
      displayOrder: json['display_order'],
      subImage: json['sub_image'],
      locationId: json['location_id'],
      locationName: json['location_name'],
      services: json['services'] != null
          ? (json['services'] as List)
              .map((e) => ServicesModel.fromJson(e))
              .toList()
          : [],
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
        'services': services?.map((e) => e.toJson()).toList(),
      };
}


class ServicesModel {
  final String? id;
  final String? subCategoryId;
  final String? title;
  final String? priceConfiguration;
  final String? price;
  final String? extraChargesTitle;
  final String? extraChargesPrice;
  final String? presponsibility;
  final String? cresponsibility;
  final String? note;
  final String? status;
  final String? createdDate;
  final String? updatedDate;
  final String? displayOrder;
  final String? serviceImage;
  final String? locationId;
  final String? locationName;

  ServicesModel({
    this.id,
    this.subCategoryId,
    this.title,
    this.priceConfiguration,
    this.price,
    this.extraChargesTitle,
    this.extraChargesPrice,
    this.presponsibility,
    this.cresponsibility,
    this.note,
    this.status,
    this.createdDate,
    this.updatedDate,
    this.displayOrder,
    this.serviceImage,
    this.locationId,
    this.locationName,
  });

  factory ServicesModel.fromJson(Map<String, dynamic> json) {
    return ServicesModel(
      id: json['id'],
      subCategoryId: json['sub_category_id'],
      title: json['title'],
      priceConfiguration: json['price_configuration'],
      price: json['price'],
      extraChargesTitle: json['extra_charges_title'],
      extraChargesPrice: json['extra_charges_price'],
      presponsibility: json['presponsibility'],
      cresponsibility: json['cresponsibility'],
      note: json['note'],
      status: json['status'],
      createdDate: json['created_date'],
      updatedDate: json['updated_date'],
      displayOrder: json['display_order'],
      serviceImage: json['service_image'],
      locationId: json['location_id'],
      locationName: json['location_name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sub_category_id': subCategoryId,
        'title': title,
        'price_configuration': priceConfiguration,
        'price': price,
        'extra_charges_title': extraChargesTitle,
        'extra_charges_price': extraChargesPrice,
        'presponsibility': presponsibility,
        'cresponsibility': cresponsibility,
        'note': note,
        'status': status,
        'created_date': createdDate,
        'updated_date': updatedDate,
        'display_order': displayOrder,
        'service_image': serviceImage,
        'location_id': locationId,
        'location_name': locationName,
      };
}

