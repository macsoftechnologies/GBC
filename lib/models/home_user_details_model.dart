class HomeUserDetailsModel {
  final String status;
  final String message;
  final CustomerDetails customerDetails;

  HomeUserDetailsModel({
    required this.status,
    required this.message,
    required this.customerDetails,
  });

  factory HomeUserDetailsModel.fromJson(Map<String, dynamic> json) {
    return HomeUserDetailsModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      customerDetails: CustomerDetails.fromJson(json['customer_details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'customer_details': customerDetails.toJson(),
    };
  }
}


class CustomerDetails {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String otp;
  final String? forgotOtp;
  final String? dob;
  final String? address;
  final String customer;
  final String provider;
  final String? termsAndConditions;
  final String otpVerified;
  final String? latitude;
  final String? longitude;
  final String? placeId;
  final String? landmark;
  final String adminApprovalProvider;
  final String adminApprovalCustomer;
  final String vacationMode;
  final String? idNumber;
  final String profile;
  final String ekyc;
  final String token;
  final String viewAs;
  final String uniqueId;
  final String createdDate;
  final String updatedDate;
  final String status;
  final String preferredProvider;
  final String? location;
  final String? notes;
  final String? workingCategory;
  final String companyName;
  final String teamCount;
  final String referralCode;
  final String alternatePhoneNumber;
  final String referralId;
  final String property;

  CustomerDetails({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.otp,
    this.forgotOtp,
    this.dob,
    this.address,
    required this.customer,
    required this.provider,
    this.termsAndConditions,
    required this.otpVerified,
    this.latitude,
    this.longitude,
    this.placeId,
    this.landmark,
    required this.adminApprovalProvider,
    required this.adminApprovalCustomer,
    required this.vacationMode,
    this.idNumber,
    required this.profile,
    required this.ekyc,
    required this.token,
    required this.viewAs,
    required this.uniqueId,
    required this.createdDate,
    required this.updatedDate,
    required this.status,
    required this.preferredProvider,
    this.location,
    this.notes,
    this.workingCategory,
    required this.companyName,
    required this.teamCount,
    required this.referralCode,
    required this.alternatePhoneNumber,
    required this.referralId,
    required this.property,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      password: json['password'] ?? '',
      otp: json['otp'] ?? '',
      forgotOtp: json['forgot_otp'],
      dob: json['dob'],
      address: json['address'],
      customer: json['customer'] ?? '',
      provider: json['provider'] ?? '',
      termsAndConditions: json['terms_and_conditions'],
      otpVerified: json['otp_verified'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      placeId: json['place_id'],
      landmark: json['landmark'],
      adminApprovalProvider: json['admin_approval_provider'] ?? '',
      adminApprovalCustomer: json['admin_approval_customer'] ?? '',
      vacationMode: json['vacation_mode'] ?? '',
      idNumber: json['id_number'],
      profile: json['profile'] ?? '',
      ekyc: json['ekyc'] ?? '',
      token: json['token'] ?? '',
      viewAs: json['view_as'] ?? '',
      uniqueId: json['unique_id'] ?? '',
      createdDate: json['created_date'] ?? '',
      updatedDate: json['updated_date'] ?? '',
      status: json['status'] ?? '',
      preferredProvider: json['preferred_provider'] ?? '',
      location: json['location'],
      notes: json['notes'],
      workingCategory: json['working_category'],
      companyName: json['company_name'] ?? '',
      teamCount: json['team_count'] ?? '',
      referralCode: json['referral_code'] ?? '',
      alternatePhoneNumber: json['alternate_phone_number'] ?? '',
      referralId: json['referral_id'] ?? '',
      property: json['property'] ?? '',
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
