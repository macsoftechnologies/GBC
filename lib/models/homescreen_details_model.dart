class getDownloadsmodel {
  List<Mainscreen>? mainscreen;
  String? providerCount;
  String? bookingCount;
  String? happyCustomers;

  getDownloadsmodel({
    this.mainscreen,
    this.providerCount,
    this.bookingCount,
    this.happyCustomers,
  });

  factory getDownloadsmodel.fromJson(Map<String, dynamic> json) {
    return getDownloadsmodel(
      mainscreen: json['mainscreen'] != null
          ? List<Mainscreen>.from(
              json['mainscreen'].map((x) => Mainscreen.fromJson(x)))
          : null,
      providerCount: json['providerCount'],
      bookingCount: json['bookingCount'],
      happyCustomers: json['happyCustomers'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mainscreen': mainscreen?.map((x) => x.toJson()).toList(),
      'providerCount': providerCount,
      'bookingCount': bookingCount,
      'happyCustomers': happyCustomers,
    };
  }
}


class Mainscreen {
  String? id;
  String? providers;
  String? bookings;
  String? customers;

  Mainscreen({this.id, this.providers, this.bookings, this.customers});

  factory Mainscreen.fromJson(Map<String, dynamic> json) {
    return Mainscreen(
      id: json['id'],
      providers: json['providers'],
      bookings: json['bookings'],
      customers: json['customers'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providers': providers,
      'bookings': bookings,
      'customers': customers,
    };
  }
}
