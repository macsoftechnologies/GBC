class GetHouseTypes {
  final String? status;
  final String? message;
  final List<HouseType>? houseTypes;

  GetHouseTypes({this.status, this.message, this.houseTypes});

  // Factory constructor from JSON
  factory GetHouseTypes.fromJson(Map<String, dynamic> json) {
    return GetHouseTypes(
      status: json['status'] as String?,
      message: json['message'] as String?,
      houseTypes: (json['housetypes'] as List<dynamic>?)
          ?.map((e) => HouseType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'housetypes': houseTypes?.map((e) => e.toJson()).toList(),
      };
}

class HouseType {
  final String? id;
  final String? houseType;

  HouseType({this.id, this.houseType});

  // Factory constructor from JSON
  factory HouseType.fromJson(Map<String, dynamic> json) {
    return HouseType(
      id: json['id']?.toString(),
      houseType: json['house_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'house_type': houseType,
      };
}
