// ─────────────────────────────────────────────
// Model: GetAllSubscriptions
// ─────────────────────────────────────────────

class GetAllSubscriptions {
  final bool status;
  final String message;
  final List<SubscriptionPlan> data;

  GetAllSubscriptions({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetAllSubscriptions.fromJson(Map<String, dynamic> json) {
    return GetAllSubscriptions(
      status: json['status'] == true,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Service item inside a plan
// ─────────────────────────────────────────────
class PlanService {
  final String id;
  final String serviceName;
  final String servicePrice;

  PlanService({
    required this.id,
    required this.serviceName,
    required this.servicePrice,
  });

  factory PlanService.fromJson(Map<String, dynamic> json) {
    return PlanService(
      id: json['id']?.toString() ?? '',
      serviceName: json['service_name'] ?? '',
      servicePrice: json['service_price']?.toString() ?? '0.00',
    );
  }
}

// ─────────────────────────────────────────────
// One plan (Premium / Prevent / Custom …)
// ─────────────────────────────────────────────
class SubscriptionPlan {
  final String id;
  final String planName;
  final String planType; // "standard" | "custom"
  final String image;
  final String status;
  final List<PlanService> services; // ← NEW
  final List<HouseTypePricing> pricing;

  SubscriptionPlan({
    required this.id,
    required this.planName,
    required this.planType,
    required this.image,
    required this.status,
    required this.services,
    required this.pricing,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['plan_id']?.toString() ?? '',
      planName: json['plan_name'] ?? '',
      planType: json['plan_type'] ?? 'standard',
      image: json['image'] ?? '',
      status: json['status']?.toString() ?? '0',
      services: (json['services'] as List<dynamic>? ?? [])
          .map((e) => PlanService.fromJson(e as Map<String, dynamic>))
          .toList(),
      pricing: (json['pricing'] as List<dynamic>? ?? [])
          .map((e) => HouseTypePricing.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Returns the [HouseTypePricing] for a given label, e.g. "1 BHK" → "1BHK".
  HouseTypePricing? pricingFor(String houseTypeLabel) {
    final normalised = houseTypeLabel.replaceAll(' ', '').toUpperCase();
    try {
      return pricing.firstWhere(
        (p) => p.houseType.replaceAll(' ', '').toUpperCase() == normalised,
      );
    } catch (_) {
      return null;
    }
  }

  /// First non-null amount string for the given house type.
  String displayPrice(String houseTypeLabel) {
    final block = pricingFor(houseTypeLabel);
    if (block == null) return '—';
    for (final p in block.prices) {
      if (p.amount != null) return p.amount!;
    }
    return '—';
  }
}

// ─────────────────────────────────────────────
// Pricing block per house type
// ─────────────────────────────────────────────
class HouseTypePricing {
  final String houseType;
  final List<DurationPrice> prices;

  HouseTypePricing({required this.houseType, required this.prices});

  factory HouseTypePricing.fromJson(Map<String, dynamic> json) {
    return HouseTypePricing(
      houseType: json['house_type'] ?? '',
      prices: (json['prices'] as List<dynamic>? ?? [])
          .map((e) => DurationPrice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────
// One duration row
// ─────────────────────────────────────────────
class DurationPrice {
  final String duration;
  final int? months;
  final String? amount;
  final String? discount;
  final double? finalAmount;

  DurationPrice({
    required this.duration,
    this.months,
    this.amount,
    this.discount,
    this.finalAmount,
  });

  factory DurationPrice.fromJson(Map<String, dynamic> json) {
    String? parseAmount(dynamic v) => v == null ? null : v.toString();

    double? parseFinal(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return DurationPrice(
      duration: json['duration'] ?? '',
      months: json['months'] as int?,
      amount: parseAmount(json['amount']),
      discount: json['discount']?.toString(),
      finalAmount: parseFinal(json['final']),
    );
  }

  String get displayAmount => amount ?? '—';
  bool get isAvailable => amount != null;
}