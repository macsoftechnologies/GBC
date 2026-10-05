// Model for a single cancel reason
class CancelReason {
  final String id;
  final String reason;

  CancelReason({
    required this.id,
    required this.reason,
  });

  factory CancelReason.fromJson(Map<String, dynamic> json) {
    return CancelReason(
      id: json['id'] ?? '',
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reason': reason,
    };
  }
}

// Model for the full API response
class GetCancelOrderReasons {
  final String status;
  final String message;
  final List<CancelReason> cancelReasons;

  GetCancelOrderReasons({
    required this.status,
    required this.message,
    required this.cancelReasons,
  });

  factory GetCancelOrderReasons.fromJson(Map<String, dynamic> json) {
    var reasonsList = <CancelReason>[];
    if (json['cancelreasons'] != null) {
      reasonsList = List<CancelReason>.from(
          json['cancelreasons'].map((x) => CancelReason.fromJson(x)));
    }

    return GetCancelOrderReasons(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      cancelReasons: reasonsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'cancelreasons': cancelReasons.map((x) => x.toJson()).toList(),
    };
  }
}
