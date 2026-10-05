class GetReferalCodeModel {
  String? status;
  String? message;
  Profile? profile;
  int? subscriptionCount;

  GetReferalCodeModel({
    this.status,
    this.message,
    this.profile,
    this.subscriptionCount,
  });

  factory GetReferalCodeModel.fromJson(Map<String, dynamic> json) {
    return GetReferalCodeModel(
      status: json['status'],
      message: json['message'],
      profile: json['profile'] != null
          ? Profile.fromJson(json['profile'])
          : null,
      subscriptionCount: json['subscription_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'profile': profile?.toJson(),
      'subscription_count': subscriptionCount,
    };
  }
}

class Profile {
  String? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? password;
  String? otp;
  dynamic forgotOtp;
  String? dob;
  String? address;
  String? customer;
  String? provider;
  dynamic termsAndConditions;
  String? otpVerified;
  String? latitude;
  String? longitude;
  String? placeId;
  String? landmark;
  String? adminApprovalProvider;
  String? adminApprovalCustomer;
  String? vacationMode;
  dynamic idNumber;
  String? profile;
  String? ekyc;
  String? token;
  String? viewAs;
  String? uniqueId;
  String? createdDate;
  String? updatedDate;
  String? status;
  String? preferredProvider;
  String? location;
  dynamic notes;
  dynamic workingCategory;
  String? companyName;
  String? teamCount;
  String? referralCode;
  String? alternatePhoneNumber;
  String? referralId;
  String? property;
  String? unique;
  String? deviceToken;
  String? walletBalance;
  String? ekycStatus;
  String? ekycStatusName;
  String? skills;

  Profile({
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
    this.deviceToken,
    this.walletBalance,
    this.ekycStatus,
    this.ekycStatusName,
    this.skills,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
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
      deviceToken: json['device_token'],
      walletBalance: json['wallet_balance'],
      ekycStatus: json['ekyc_status'],
      ekycStatusName: json['ekyc_status_name'],
      skills: json['skills'],
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
      'device_token': deviceToken,
      'wallet_balance': walletBalance,
      'ekyc_status': ekycStatus,
      'ekyc_status_name': ekycStatusName,
      'skills': skills,
    };
  }
}