class NewSearchModel {
  String? status;
  String? message;
  List<ServicesforSearch>? services;

  NewSearchModel({this.status, this.message, this.services});

  factory NewSearchModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NewSearchModel();

    return NewSearchModel(
      status: json['status'] as String?,
      message: json['message'] as String?,
      services: (json['services'] as List?)
          ?.map((item) => ServicesforSearch.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'services': services?.map((v) => v.toJson()).toList(),
    };
  }
}

class ServicesforSearch{
  String? id;
  String? title;
  String? price;
  String? presponsibility;
  String? cresponsibility;
  String? note;
  String? serviceImage;
  String? locationName;
  int? subServices;

  ServicesforSearch({
    this.id,
    this.title,
    this.price,
    this.presponsibility,
    this.cresponsibility,
    this.note,
    this.serviceImage,
    this.locationName,
    this.subServices,
  });

  factory ServicesforSearch.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ServicesforSearch();

    return ServicesforSearch(
      id: json['id'] as String?,
      title: json['title'] as String?,
      price: json['price'] as String?,
      presponsibility: json['presponsibility'] as String?,
      cresponsibility: json['cresponsibility'] as String?,
      note: json['note'] as String?,
      serviceImage: json['service_image'] as String?,
      locationName: json['location_name'] as String?,
      subServices: json['sub_services'] is int
          ? json['sub_services'] as int
          : int.tryParse(json['sub_services']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'presponsibility': presponsibility,
      'cresponsibility': cresponsibility,
      'note': note,
      'service_image': serviceImage,
      'location_name': locationName,
      'sub_services': subServices,
    };
  }
}
