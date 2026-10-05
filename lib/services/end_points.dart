class EndPoints {

  //base url
  static const String newbaseUrl = "https://dev.gobuddyindia.com/api/";

  //Partial Api End Points

  static const String newSignupApi = "${newbaseUrl}customer_register";
  static const String newLoginApi = "${newbaseUrl}newlogin";
  static const String newVerifyOtpApi = "${newbaseUrl}verify_otp";
  // ignore: constant_identifier_names
  static const String AddSchedulePropertyVisitAPi = "${newbaseUrl}add_schedule_propertvisit";
  static const String getMainHeadCategories = "${newbaseUrl}categories";
  static const String getAllSearchApi = "${newbaseUrl}category_subcategory_search";
  static const String getSubCategoriesById = "${newbaseUrl}categorybasedsub_category";
  static const String getMainCategories="${newbaseUrl}categories";
  static const String getSubcategoriesByMaincategoryApi = "${newbaseUrl}categorybasedsub_category";
  static const String getUserDetailsforDashboard = "${newbaseUrl}customer_details";
  static const String getBanners = "${newbaseUrl}getsliders";
  static const String resendOTP = "${newbaseUrl}resend_login_otp";
  static const String getServicesBySubCategoryId = "${newbaseUrl}services";
  static const String getServiceOverview="${newbaseUrl}getServiceDetails";
  static const String newSearchApi="${newbaseUrl}services";
  static const String getdashboardDetails="${newbaseUrl}getmainscreenlists";
  static const String subcategoryuserdetails = "${newbaseUrl}get_categorybasedlistst";
  static const String getserviceBannerdetails = "${newbaseUrl}get_subcategorybasedlistst";
  static const String getProviderAPi = "${newbaseUrl}search_jobs_by_category_and_datetime";
  static const String getProviderOverview = "${newbaseUrl}provider_profile";
  static const String getAddonsApi = "${newbaseUrl}addons";
  static const String getAllAdvertisments = "${newbaseUrl}getadvertisements";
  static const String addTocartItems = "${newbaseUrl}add_customer_cart";
  static const String uploadProviderImages = "${newbaseUrl}add_provider_gallery";
  static const String getAllOdersApi = "${newbaseUrl}all_orders";
  static const String getBookingsOverview = "${newbaseUrl}view_order_details";
  static const String RateProviderinBookings = "${newbaseUrl}rating";
  static const String ImageUploadingApiforReview = "${newbaseUrl}add_provider_gallery";
  static const String getCancelReasons = "${newbaseUrl}getcancelreasons";
  static const String cancelSubcription = "${newbaseUrl}cancelorder";
  static const String getJobcalendarId = "${newbaseUrl}get_orderproviderdetails";
  static const String editscheduleforbookings = "${newbaseUrl}edit_schedule_datetime";
  static const String getAllSubscriptionPlans = "${newbaseUrl}get_plans";
  static const String getAllMainCategoriesforCustomPlan = "${newbaseUrl}categories";
  static const String getSubCategoriesByMainCategoryId = "${newbaseUrl}categorybasedsub_category";
  static const String getServicesBySubCategoryIdforCustomSubscription = "${newbaseUrl}subscriptionservices";
  static const String addtoSubscriptionService = "${newbaseUrl}customersubscriptionservices";
  static const String gethouseTypes = "${newbaseUrl}gethousetypes";
  static const String getNotificationByUserId = "${newbaseUrl}getCustomerNotifications";
  static const String AddtocartServiceApi = "${newbaseUrl}add_customer_cart";
  static const String getUserDetailsbyUserId = "${newbaseUrl}customer_details";
  static const String postAllserviceDataoder = "${newbaseUrl}place_order_full";
  static const String getTermsandConditions = "${newbaseUrl}terms_and_conditions";
  static const String userprofileDetails = "${newbaseUrl}customer_details";
  static const String getinspectionreport = "${newbaseUrl}inspection_report";
  static const String CustomerProfileupdate = "${newbaseUrl}cusotmer_profileupdate";
  static const String verifyCouponcode = "${newbaseUrl}check_coupon";
  static const String addSubscription = "${newbaseUrl}add_subscription";
  static const String sendfeedbackUser = "${newbaseUrl}sendfeedback";
  static const String getUserProfileDetailsRefer = "${newbaseUrl}profile";
  static const String getMySubscriptionPlans = "${newbaseUrl}get_user_subscriptions";
  static const String getMySubscriptionOverview = "${newbaseUrl}getcustomersubscriptionbyid";
  static const String cancelSubscriptionsNew = "${newbaseUrl}cancel_subscription";
  static const String getUpdateAddress = "${newbaseUrl}update_address";
  static const String AssignbestProvider = "${newbaseUrl}bestprovider";
  static const String assignToProvider = "${newbaseUrl}assigntoprovider";
  static const String updateSubscription = "${newbaseUrl}update_subscription";
  static const String upgradeSubscription = "${newbaseUrl}upgrade_subscription";
  static const String getSubscriptionCancelReasons = "${newbaseUrl}getcustomersubscriptioncancelreasons";
  static const String mostBookedServices = "${newbaseUrl}most_booked_services";
  static const String customerDashboard = "${newbaseUrl}customerdashboard";
  static const String getCustomerNotificationsCount = "${newbaseUrl}getCustomerNotificationscount";
  static const String getUserSubscriptions = "${newbaseUrl}getusersubscriptions";
}