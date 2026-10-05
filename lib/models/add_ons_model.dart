class GetAddons {
  final String status;
  final String message;
  final List<Addon> addons;

  GetAddons({
    required this.status,
    required this.message,
    required this.addons,
  });

  factory GetAddons.fromJson(Map<String, dynamic> json) {
    return GetAddons(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      addons: (json['addons'] as List<dynamic>?)
              ?.map((e) => Addon.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'addons': addons.map((e) => e.toJson()).toList(),
      };
}

class Addon {
  final String id;
  final String addonId;
  final String subscriptionId;
  final String providerId;
  final String amount;
  final String categoryId;
  final String createdAt;
  final String updatedAt;
  final String status;
  final String addonService;

  Addon({
    required this.id,
    required this.addonId,
    required this.subscriptionId,
    required this.providerId,
    required this.amount,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.addonService,
  });

  factory Addon.fromJson(Map<String, dynamic> json) {
    return Addon(
      id: json['id']?.toString() ?? '',
      addonId: json['addon_id']?.toString() ?? '',
      subscriptionId: json['subscription_id']?.toString() ?? '',
      providerId: json['provider_id']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      categoryId: json['category_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      addonService: json['addon_service']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'addon_id': addonId,
        'subscription_id': subscriptionId,
        'provider_id': providerId,
        'amount': amount,
        'category_id': categoryId,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'status': status,
        'addon_service': addonService,
      };
}
