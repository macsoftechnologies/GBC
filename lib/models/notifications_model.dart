class GetNotificationsModel {
  final String? status;
  final String? message;
  final List<Data>? data;
  final int? count;

  GetNotificationsModel({
    this.status,
    this.message,
    this.data,
    this.count,
  });

  factory GetNotificationsModel.fromJson(Map<String, dynamic> json) {
    return GetNotificationsModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((e) => Data.fromJson(e)).toList()
          : null,
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
      'count': count,
    };
  }
}


class Data {
  final String? id;
  final String? userId;
  final String? userType;
  final String? title;
  final String? subtitle;
  final String? serviceName;
  final String? location;
  final String? personName;
  final String? dateTime;
  final String? amount;
  final String? status;
  final String? isRead;
  final String? createdAt;

  Data({
    this.id,
    this.userId,
    this.userType,
    this.title,
    this.subtitle,
    this.serviceName,
    this.location,
    this.personName,
    this.dateTime,
    this.amount,
    this.status,
    this.isRead,
    this.createdAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      userId: json['user_id'],
      userType: json['user_type'],
      title: json['title'],
      subtitle: json['subtitle'],
      serviceName: json['service_name'],
      location: json['location'],
      personName: json['person_name'],
      dateTime: json['date_time'],
      amount: json['amount'],
      status: json['status'],
      isRead: json['is_read'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_type': userType,
      'title': title,
      'subtitle': subtitle,
      'service_name': serviceName,
      'location': location,
      'person_name': personName,
      'date_time': dateTime,
      'amount': amount,
      'status': status,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }
}
