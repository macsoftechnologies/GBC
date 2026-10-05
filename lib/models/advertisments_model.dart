class GetAdvertisements {
  final String? status;
  final String? message;
  final List<Advertisement>? advertisements;

  GetAdvertisements({
    this.status,
    this.message,
    this.advertisements,
  });

  factory GetAdvertisements.fromJson(Map<String, dynamic> json) {
    return GetAdvertisements(
      status: json['status'] as String?,
      message: json['message'] as String?,
      advertisements: json['advertisements'] != null
          ? (json['advertisements'] as List)
              .map((v) => Advertisement.fromJson(v))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (advertisements != null)
        'advertisements': advertisements!.map((v) => v.toJson()).toList(),
    };
  }
}

class Advertisement {
  final String? id;
  final String? title;
  final String? subTitle;
  final String? advertise;

  Advertisement({
    this.id,
    this.title,
    this.subTitle,
    this.advertise,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'] as String?,
      title: json['title'] as String?,
      subTitle: json['sub_title'] as String?,
      advertise: json['advertise'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sub_title': subTitle,
      'advertise': advertise,
    };
  }
}
