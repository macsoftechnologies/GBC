class GetUserDetailsModel {
  final String status;
  final String message;
  final CustomerDetails? customerDetails;

  GetUserDetailsModel({
    required this.status,
    required this.message,
    this.customerDetails,
  });

  factory GetUserDetailsModel.fromJson(Map<String, dynamic> json) {
    return GetUserDetailsModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      customerDetails: json['customer_details'] != null
          ? CustomerDetails.fromJson(json['customer_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      if (customerDetails != null) 'customer_details': customerDetails!.toJson(),
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
  final String? forgotOtp;
  final String? dob;
  final String? address;
  final String? customer;
  final String? provider;
  final String? termsAndConditions;
  final String? otpVerified;
  final String? latitude;
  final String? longitude;
  final String? placeId;
  final String? landmark;
  final String? adminApprovalProvider;
  final String? adminApprovalCustomer;
  final String? vacationMode;
  final String? idNumber;
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
  final String? notes;
  final String? workingCategory;
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
      id: json['id']?.toString(),
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      password: json['password'],
      otp: json['otp'],
      forgotOtp: json['forgot_otp']?.toString(),
      dob: json['dob']?.toString(),
      address: json['address'],
      customer: json['customer'],
      provider: json['provider'],
      termsAndConditions: json['terms_and_conditions']?.toString(),
      otpVerified: json['otp_verified'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      placeId: json['place_id']?.toString(),
      landmark: json['landmark']?.toString(),
      adminApprovalProvider: json['admin_approval_provider'],
      adminApprovalCustomer: json['admin_approval_customer'],
      vacationMode: json['vacation_mode'],
      idNumber: json['id_number']?.toString(),
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
      notes: json['notes']?.toString(),
      workingCategory: json['working_category']?.toString(),
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
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (password != null) 'password': password,
      if (otp != null) 'otp': otp,
      if (forgotOtp != null) 'forgot_otp': forgotOtp,
      if (dob != null) 'dob': dob,
      if (address != null) 'address': address,
      if (customer != null) 'customer': customer,
      if (provider != null) 'provider': provider,
      if (termsAndConditions != null) 'terms_and_conditions': termsAndConditions,
      if (otpVerified != null) 'otp_verified': otpVerified,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (placeId != null) 'place_id': placeId,
      if (landmark != null) 'landmark': landmark,
      if (adminApprovalProvider != null) 'admin_approval_provider': adminApprovalProvider,
      if (adminApprovalCustomer != null) 'admin_approval_customer': adminApprovalCustomer,
      if (vacationMode != null) 'vacation_mode': vacationMode,
      if (idNumber != null) 'id_number': idNumber,
      if (profile != null) 'profile': profile,
      if (ekyc != null) 'ekyc': ekyc,
      if (token != null) 'token': token,
      if (viewAs != null) 'view_as': viewAs,
      if (uniqueId != null) 'unique_id': uniqueId,
      if (createdDate != null) 'created_date': createdDate,
      if (updatedDate != null) 'updated_date': updatedDate,
      if (status != null) 'status': status,
      if (preferredProvider != null) 'preferred_provider': preferredProvider,
      if (location != null) 'location': location,
      if (notes != null) 'notes': notes,
      if (workingCategory != null) 'working_category': workingCategory,
      if (companyName != null) 'company_name': companyName,
      if (teamCount != null) 'team_count': teamCount,
      if (referralCode != null) 'referral_code': referralCode,
      if (alternatePhoneNumber != null) 'alternate_phone_number': alternatePhoneNumber,
      if (referralId != null) 'referral_id': referralId,
      if (property != null) 'property': property,
      if (unique != null) 'unique': unique,
    };
  }
}
