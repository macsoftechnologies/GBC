class GetUserProfileDetails {
  final String? status;
  final String? message;
  final CustomerDetails? customerDetails;

  GetUserProfileDetails({
    this.status,
    this.message,
    this.customerDetails,
  });

  factory GetUserProfileDetails.fromJson(Map<String, dynamic> json) {
    return GetUserProfileDetails(
      status: json['status'],
      message: json['message'],
      customerDetails: json['customer_details'] != null
          ? CustomerDetails.fromJson(json['customer_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'customer_details': customerDetails?.toJson(),
    };
  }
}

class CustomerDetails {
  final String? id;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? password;
  final String? otp;
  final dynamic forgotOtp;
  final dynamic dob;
  final dynamic address;
  final String? customer;
  final String? provider;
  final dynamic termsAndConditions;
  final String? otpVerified;
  final dynamic latitude;
  final String? longitude;
  final dynamic placeId;
  final dynamic landmark;
  final String? adminApprovalProvider;
  final String? adminApprovalCustomer;
  final String? vacationMode;
  final dynamic idNumber;
  final String? profile;
  final String? ekyc;
  final String? token;
  final String? viewAs;
  final String? uniqueId;
  final String? createdDate;
  final String? updatedDate;
  final String? status;
  final String? preferredProvider;
  final String? location;
  final dynamic notes;
  final dynamic workingCategory;
  final String? companyName;
  final String? teamCount;
  final String? referralCode;
  final String? alternatePhoneNumber;
  final String? referralId;
  final String? property;
  final String? unique;

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
    this.unique,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      password: json['password'],
      otp: json['otp'],
      forgotOtp: json['forgot_otp'],
      dob: json['dob'],
      address: json['address'],
      customer: json['customer'],
      provider: json['provider'],
      termsAndConditions: json['terms_and_conditions'],
      otpVerified: json['otp_verified'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      placeId: json['place_id'],
      landmark: json['landmark'],
      adminApprovalProvider: json['admin_approval_provider'],
      adminApprovalCustomer: json['admin_approval_customer'],
      vacationMode: json['vacation_mode'],
      idNumber: json['id_number'],
      profile: json['profile'],
      ekyc: json['ekyc'],
      token: json['token'],
      viewAs: json['view_as'],
      uniqueId: json['unique_id'],
      createdDate: json['created_date'],
      updatedDate: json['updated_date'],
      status: json['status'],
      preferredProvider: json['preferred_provider'],
      location: json['location'],
      notes: json['notes'],
      workingCategory: json['working_category'],
      companyName: json['company_name'],
      teamCount: json['team_count'],
      referralCode: json['referral_code'],
      alternatePhoneNumber: json['alternate_phone_number'],
      referralId: json['referral_id'],
      property: json['property'],
      unique: json['unique'],
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
      'unique': unique,
    };
  }
}
