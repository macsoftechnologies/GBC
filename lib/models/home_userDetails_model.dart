class HomeUserDetailsModel {
  String? status;
  String? message;
  CustomerDetails? customerDetails;

  HomeUserDetailsModel({this.status, this.message, this.customerDetails});

  factory HomeUserDetailsModel.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing HomeUserDetailsModel...');
      print('status: ${json['status']}');
      print('message: ${json['message']}');
      print('customer_details (type): ${json['customer_details']?.runtimeType}');

      return HomeUserDetailsModel(
        status: json['status'],
        message: json['message'],
        customerDetails: json['customer_details'] != null
            ? CustomerDetails.fromJson(json['customer_details'])
            : null,
      );
    } catch (e, stackTrace) {
      print('Error parsing HomeUserDetailsModel: $e');
      print('Stacktrace: $stackTrace');
      print('JSON causing error: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (customerDetails != null) {
      data['customer_details'] = customerDetails!.toJson();
    }
    return data;
  }
}

class CustomerDetails {
  int? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? password;
  int? otp;
  dynamic forgotOtp; // could be int, String or null
  String? dob;
  String? address;
  int? customer;
  int? provider;
  String? termsAndConditions;
  int? otpVerified;
  double? latitude;
  double? longitude;
  String? placeId;
  String? landmark;
  int? adminApprovalProvider;
  int? adminApprovalCustomer;
  int? vacationMode;
  String? idNumber;
  String? profile;
  int? ekyc;
  String? token;
  String? viewAs;
  String? uniqueId; // use String for very large numbers
  String? createdDate;
  String? updatedDate;
  int? status;
  String? preferredProvider;
  String? location;
  String? notes;
  String? workingCategory;
  String? companyName;
  int? teamCount;
  String? referralCode;
  String? alternatePhoneNumber;
  String? referralId;
  String? property;

  CustomerDetails({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.password,
    this.otp,
    this.forgotOtp,
    this.dob,
    this.address,
    this.customer,
    this.provider,
    this.termsAndConditions,
    this.otpVerified,
    this.latitude,
    this.longitude,
    this.placeId,
    this.landmark,
    this.adminApprovalProvider,
    this.adminApprovalCustomer,
    this.vacationMode,
    this.idNumber,
    this.profile,
    this.ekyc,
    this.token,
    this.viewAs,
    this.uniqueId,
    this.createdDate,
    this.updatedDate,
    this.status,
    this.preferredProvider,
    this.location,
    this.notes,
    this.workingCategory,
    this.companyName,
    this.teamCount,
    this.referralCode,
    this.alternatePhoneNumber,
    this.referralId,
    this.property,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return CustomerDetails(
      id: parseInt(json['id']),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      password: json['password']?.toString(),
      otp: parseInt(json['otp']),
      forgotOtp: json['forgot_otp'], // keep as dynamic
      dob: json['dob']?.toString(),
      address: json['address']?.toString(),
      customer: parseInt(json['customer']),
      provider: parseInt(json['provider']),
      termsAndConditions: json['terms_and_conditions']?.toString(),
      otpVerified: parseInt(json['otp_verified']),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      placeId: json['place_id']?.toString(),
      landmark: json['landmark']?.toString(),
      adminApprovalProvider: parseInt(json['admin_approval_provider']),
      adminApprovalCustomer: parseInt(json['admin_approval_customer']),
      vacationMode: parseInt(json['vacation_mode']),
      idNumber: json['id_number']?.toString(),
      profile: json['profile']?.toString(),
      ekyc: parseInt(json['ekyc']),
      token: json['token']?.toString(),
      viewAs: json['view_as']?.toString(),
      uniqueId: json['unique_id']?.toString(),
      createdDate: json['created_date']?.toString(),
      updatedDate: json['updated_date']?.toString(),
      status: parseInt(json['status']),
      preferredProvider: json['preferred_provider']?.toString(),
      location: json['location']?.toString(),
      notes: json['notes']?.toString(),
      workingCategory: json['working_category']?.toString(),
      companyName: json['company_name']?.toString(),
      teamCount: parseInt(json['team_count']),
      referralCode: json['referral_code']?.toString(),
      alternatePhoneNumber: json['alternate_phone_number']?.toString(),
      referralId: json['referral_id']?.toString(),
      property: json['property']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
      'otp': otp,
      'forgot_otp': forgotOtp,
      'dob': dob,
      'address': address,
      'customer': customer,
      'provider': provider,
      'terms_and_conditions': termsAndConditions,
      'otp_verified': otpVerified,
      'latitude': latitude,
      'longitude': longitude,
      'place_id': placeId,
      'landmark': landmark,
      'admin_approval_provider': adminApprovalProvider,
      'admin_approval_customer': adminApprovalCustomer,
      'vacation_mode': vacationMode,
      'id_number': idNumber,
      'profile': profile,
      'ekyc': ekyc,
      'token': token,
      'view_as': viewAs,
      'unique_id': uniqueId,
      'created_date': createdDate,
      'updated_date': updatedDate,
      'status': status,
      'preferred_provider': preferredProvider,
      'location': location,
      'notes': notes,
      'working_category': workingCategory,
      'company_name': companyName,
      'team_count': teamCount,
      'referral_code': referralCode,
      'alternate_phone_number': alternatePhoneNumber,
      'referral_id': referralId,
      'property': property,
    };
  }
}
