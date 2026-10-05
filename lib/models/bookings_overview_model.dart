class GetBookingOverview {
  final String? status;
  final String? message;
  final String? baseUrl;
  final Order? order;

  GetBookingOverview({
    this.status,
    this.message,
    this.baseUrl,
    this.order,
  });

  factory GetBookingOverview.fromJson(Map<String, dynamic> json) {
    return GetBookingOverview(
      status: json['status'] as String?,
      message: json['message'] as String?,
      baseUrl: json['base_url'] as String?,
      order: json['order'] != null ? Order.fromJson(json['order']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'base_url': baseUrl,
        if (order != null) 'order': order!.toJson(),
      };
}

class Order {
  final String? orderId;
  final String? orderTxn;
  final String? scheduleDate;
  final String? scheduleTime;
  final int? orderStatus;
  final String? status;
  final String? latitude;
  final String? longitude;
  final String? address;
  final String? landmark;
  final String? location;
  final String? couponName;
  final String? couponAmount;
  final String? gbCoins;
  final String? platformFee;
  final String? subTotal;
  final String? grandTotal;
  final User? user;
  final Provider? provider;
  final Service? service;
  final String? createdAt;

  Order({
    this.orderId,
    this.orderTxn,
    this.scheduleDate,
    this.scheduleTime,
    this.orderStatus,
    this.status,
    this.latitude,
    this.longitude,
    this.address,
    this.landmark,
    this.location,
    this.couponName,
    this.couponAmount,
    this.gbCoins,
    this.platformFee,
    this.subTotal,
    this.grandTotal,
    this.user,
    this.provider,
    this.service,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id']?.toString(),
      orderTxn: json['order_txn'] as String?,
      scheduleDate: json['schedule_date'] as String?,
      scheduleTime: json['schedule_time'] as String?,
      orderStatus: json['order_status'] is int
          ? json['order_status']
          : int.tryParse(json['order_status']?.toString() ?? ''),
      status: json['status'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      address: json['address'] as String?,
      landmark: json['landmark'] as String?,
      location: json['location'] as String?,
      couponName: json['coupon_name'] as String?,
      couponAmount: json['coupon_amount']?.toString(),
      gbCoins: json['gb_coins']?.toString(),
      platformFee: json['platform_fee']?.toString(),
      subTotal: json['sub_total']?.toString(),
      grandTotal: json['grand_total']?.toString(),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      provider: json['provider'] != null ? Provider.fromJson(json['provider']) : null,
      service: json['service'] != null ? Service.fromJson(json['service']) : null,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'order_id': orderId,
        'order_txn': orderTxn,
        'schedule_date': scheduleDate,
        'schedule_time': scheduleTime,
        'order_status': orderStatus,
        'status': status,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'landmark': landmark,
        'location': location,
        'coupon_name': couponName,
        'coupon_amount': couponAmount,
        'gb_coins': gbCoins,
        'platform_fee': platformFee,
        'sub_total': subTotal,
        'grand_total': grandTotal,
        if (user != null) 'user': user!.toJson(),
        if (provider != null) 'provider': provider!.toJson(),
        if (service != null) 'service': service!.toJson(),
        'created_at': createdAt,
      };
}

class User {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
      };
}

class Provider {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? providerProfile;

  Provider({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.providerProfile,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      providerProfile: json['provider_profile'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'provider_profile': providerProfile,
      };
}

class Service {
  final String? cartId;
  final String? serviceId;
  final String? serviceName;
  final String? serviceImage;
  final String? price;
  final String? discount;
  final int? quantity;
  final String? subtotal;
  final List<Addons> addons;
  final String? addonsTotal;
  final String? rating;
  final String? review;
  final String? reviewDate;

  Service({
    this.cartId,
    this.serviceId,
    this.serviceName,
    this.serviceImage,
    this.price,
    this.discount,
    this.quantity,
    this.subtotal,
    this.addons = const [],
    this.addonsTotal,
    this.rating,
    this.review,
    this.reviewDate,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    final addonsList = (json['addons'] as List<dynamic>?)
            ?.map((e) => Addons.fromJson(e))
            .toList() ??
        [];

    return Service(
      cartId: json['cart_id']?.toString(),
      serviceId: json['service_id']?.toString(),
      serviceName: json['service_name'] as String?,
      serviceImage: json['service_image'] as String?,
      price: json['price']?.toString(),
      discount: json['discount']?.toString(),
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? ''),
      subtotal: json['subtotal']?.toString(),
      addons: addonsList,
      addonsTotal: json['addons_total']?.toString(),
      rating: json['rating']?.toString(),
      review: json['review'] as String?,
      reviewDate: json['review_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'cart_id': cartId,
        'service_id': serviceId,
        'service_name': serviceName,
        'service_image': serviceImage,
        'price': price,
        'discount': discount,
        'quantity': quantity,
        'subtotal': subtotal,
        'addons': addons.map((e) => e.toJson()).toList(),
        'addons_total': addonsTotal,
        'rating': rating,
        'review': review,
        'review_date': reviewDate,
      };
}

class Addons {
  final String? customerAddonId;
  final String? userId;
  final String? categoryId;
  final String? addonId;
  final String? jobCalenderId;
  final String? price;
  final String? providerId;
  final String? createdAt;
  final String? updatedAt;
  final String? customerCartId;
  final String? addonName;

  Addons({
    this.customerAddonId,
    this.userId,
    this.categoryId,
    this.addonId,
    this.jobCalenderId,
    this.price,
    this.providerId,
    this.createdAt,
    this.updatedAt,
    this.customerCartId,
    this.addonName,
  });

  factory Addons.fromJson(Map<String, dynamic> json) {
    return Addons(
      customerAddonId: json['customer_addon_id']?.toString(),
      userId: json['user_id']?.toString(),
      categoryId: json['category_id']?.toString(),
      addonId: json['addon_id']?.toString(),
      jobCalenderId: json['job_calender_id']?.toString(),
      price: json['price']?.toString(),
      providerId: json['provider_id']?.toString(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      customerCartId: json['customer_cart_id']?.toString(),
      addonName: json['addon_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'customer_addon_id': customerAddonId,
        'user_id': userId,
        'category_id': categoryId,
        'addon_id': addonId,
        'job_calender_id': jobCalenderId,
        'price': price,
        'provider_id': providerId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'customer_cart_id': customerCartId,
        'addon_name': addonName,
      };
}
