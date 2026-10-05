// Root model
class GetBookings {
  final String? status;
  final String? message;
  final String? baseUrl;
  final User? user;
  final List<Order>? orders;

  GetBookings({
    this.status,
    this.message,
    this.baseUrl,
    this.user,
    this.orders,
  });

  factory GetBookings.fromJson(Map<String, dynamic> json) {
    return GetBookings(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      baseUrl: json['base_url']?.toString(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      orders: (json['orders'] as List<dynamic>?)
          ?.map((v) => Order.fromJson(v))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'base_url': baseUrl,
        if (user != null) 'user': user!.toJson(),
        if (orders != null)
          'orders': orders!.map((v) => v.toJson()).toList(),
      };
}

// User model
class User {
  final String? id;
  final String? name;
  final String? email;
  final String? phoneNumber;

  User({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id']?.toString(),
        name: json['name']?.toString(),
        email: json['email']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
      };
}

// Order model
class Order {
  final String? orderId;
  final String? jobCalenderId; // ✅ Added missing field
  final String? orderTxn;
  final String? createdAt;
  final String? status;
  final String? orderStatus;
  final String? serviceId;
  final String? serviceName;
  final String? serviceImage;
  final String? scheduleDate;
  final String? scheduleTime;
  final String? quantity;
  final String? price;
  final List<Addon>? addons;
  final String? addonsTotal;
  final String? grandTotal;
  final String? rating; // stored as String for consistency

  Order({
    this.orderId,
    this.jobCalenderId,
    this.orderTxn,
    this.createdAt,
    this.status,
    this.orderStatus,
    this.serviceId,
    this.serviceName,
    this.serviceImage,
    this.scheduleDate,
    this.scheduleTime,
    this.quantity,
    this.price,
    this.addons,
    this.addonsTotal,
    this.grandTotal,
    this.rating,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderId: json['order_id']?.toString(),
        jobCalenderId: json['job_calender_id']?.toString(), // ✅ Added
        orderTxn: json['order_txn']?.toString(),
        createdAt: json['created_at']?.toString(),
        status: json['status']?.toString(),
        orderStatus: json['order_status']?.toString(),
        serviceId: json['service_id']?.toString(),
        serviceName: json['service_name']?.toString(),
        serviceImage: json['service_image']?.toString(),
        scheduleDate: json['schedule_date']?.toString(),
        scheduleTime: json['schedule_time']?.toString(),
        quantity: json['quantity']?.toString(),
        price: json['price']?.toString(),
        addons: (json['addons'] as List<dynamic>?)
            ?.map((v) => Addon.fromJson(v))
            .toList(),
        addonsTotal: json['addons_total']?.toString(),
        grandTotal: json['grand_total']?.toString(),
        rating: json['rating']?.toString(), // safely handles int or string
      );

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'job_calender_id': jobCalenderId, // ✅ Added
        'order_txn': orderTxn,
        'created_at': createdAt,
        'status': status,
        'order_status': orderStatus,
        'service_id': serviceId,
        'service_name': serviceName,
        'service_image': serviceImage,
        'schedule_date': scheduleDate,
        'schedule_time': scheduleTime,
        'quantity': quantity,
        'price': price,
        if (addons != null)
          'addons': addons!.map((v) => v.toJson()).toList(),
        'addons_total': addonsTotal,
        'grand_total': grandTotal,
        'rating': rating,
      };
}

// Addon model
class Addon {
  final String? addonId;
  final String? addonName;
  final String? price;

  Addon({
    this.addonId,
    this.addonName,
    this.price,
  });

  factory Addon.fromJson(Map<String, dynamic> json) => Addon(
        addonId: json['addon_id']?.toString(),
        addonName: json['addon_name']?.toString(),
        price: json['price']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'addon_id': addonId,
        'addon_name': addonName,
        'price': price,
      };
}
