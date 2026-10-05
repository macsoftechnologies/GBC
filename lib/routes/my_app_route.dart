
import 'package:flutter/material.dart';
import 'package:gobuddy_customer_app/api/push_notification_screen.dart';
import 'package:gobuddy_customer_app/pages/authentication/googleMaps/maps.dart';
import 'package:gobuddy_customer_app/pages/authentication/login/login_screen.dart';
import 'package:gobuddy_customer_app/pages/authentication/signup/select_space.dart';
import 'package:gobuddy_customer_app/pages/bookings/booking_order_details.dart';
import 'package:gobuddy_customer_app/pages/bookings/edit_schedule.dart';
import 'package:gobuddy_customer_app/pages/edit_profile.dart';
import 'package:gobuddy_customer_app/pages/home/notifications_screen.dart';
import 'package:gobuddy_customer_app/pages/inspectionReport.dart';
import 'package:gobuddy_customer_app/pages/onBoardingScreen/onboarding_screen.dart';
import 'package:gobuddy_customer_app/pages/payments/payment_screen.dart';
import 'package:gobuddy_customer_app/pages/payments/service_payment_screen.dart';
import 'package:gobuddy_customer_app/pages/payments/service_payment_success_Scree.dart';
import 'package:gobuddy_customer_app/pages/rateProvider/rate_provider.dart';
import 'package:gobuddy_customer_app/pages/seacrhScreen/search_api.dart';
import 'package:gobuddy_customer_app/pages/seacrhScreen/sub_category_screen.dart';
import 'package:gobuddy_customer_app/pages/seacrhScreen/view_details.dart';
import 'package:gobuddy_customer_app/pages/services/schedule_date_time.dart';

import 'package:gobuddy_customer_app/pages/splashScreen/splash_screen.dart';
import 'package:gobuddy_customer_app/pages/subscription/custom_package_jobs.dart';
import 'package:gobuddy_customer_app/pages/subscription/plan_details.dart';
import 'package:gobuddy_customer_app/pages/subscription/schedule_subscription_date.dart';
import 'package:gobuddy_customer_app/pages/subscription/subscription_summary.dart';
import 'package:gobuddy_customer_app/pages/terms&conditions.dart';
import 'package:gobuddy_customer_app/pages/userside/referandEarn.dart';
import 'package:gobuddy_customer_app/pages/userside/sendfeedback.dart';
import 'package:gobuddy_customer_app/pages/welcomeScreens/welcome_screen.dart';
import 'package:hexcolor/hexcolor.dart';

import '../../utils/config.dart';
import '../../utils/my_colors.dart';

import '../pages/authentication/otp/otp_verification.dart';
import '../pages/authentication/signup/home_reg_screen.dart';
import '../pages/authentication/signup/property_reg_screen.dart';
import '../pages/guest/guest_home_screen.dart';
import '../pages/home/home_screen.dart';
import '../pages/schedulePropertyVisit/schedule_property_visit.dart';
import '../pages/schedulePropertyVisit/schedule_visit_date.dart';
import '../pages/selectProvider/select_provider.dart';
import '../pages/serviceOrderSummary/service_order_summary_screen.dart';
import '../pages/services/add_services_to_cart.dart';
import '../pages/services/select_service_type.dart';
import '../pages/services/service_details.dart';
import '../pages/viewProviderDetails/provider_profile_details.dart';
// import 'package:gobuddy/pages/splash/splash_screen.dart';

//EKYCVerificationPage

class MyAppRoute extends StatefulWidget {
  const MyAppRoute({super.key});

  @override
  State<MyAppRoute> createState() => MyAppRouteState();
}

class MyAppRouteState extends State<MyAppRoute> {
  @override
   Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Config.appName,
      initialRoute: Config.splashRouteName,
      theme: ThemeData(
        primaryColor: HexColor(MyColors.colorPrimary),
       
        fontFamily: Config.fontFamilyPoppinsRegular,
        appBarTheme: AppBarTheme(
          backgroundColor: HexColor(MyColors.navColor),
        ),
      ),
      
      routes: {
        //OnBoardScreenOne

        Config.splashRouteName: (ctx) => const SplashScreen(),
        Config.onBoardRouteName: (ctx) => OnBoardScreen(),
        Config.welcomeScreenRouteName: (ctx) => WelcomeScreen(),
        Config.loginRouteName: (ctx) => LoginScreen(),
        Config.signUpGuidingRouteName: (ctx) => SelectSpaceScreen(),
        Config.homeRegRouteName: (ctx) =>  HomeRegScreen(),
        Config.propertyRegRouteName: (ctx) =>  PropertyRegScreen(),
        Config.scheduleVisitRouteName: (ctx) =>  SchedulePropertyVisitScreen(),
        Config.homeRouteName: (ctx) =>  HomeMainScreen(),
        Config.selectServiceTypeRouteName: (ctx) =>  SelectServiceTypeScreen(),
        Config.addServicesToCartRouteName: (ctx) =>  AddServicesScreen(),
        Config.serviceDetailsRouteName: (ctx) =>  ServiceDetailsScreen(),
        Config.serviceOrderSummaryRouteName: (ctx) =>  ServiceOrderSummaryScreen(),
        Config.googleMapScreen : (ctx)=> GoogleMapScreen(),
        Config.searchScreen : (ctx)=> SearchServicesScreenNew(),
        Config.viewDetailsScreen : (ctx)=> ViewDetailsScreen(),
        Config.searchAddtocart  : (ctx)=> SearchAddServicesScreen(),
        Config.serviceDateandTimeScreen : (ctx)=> ScheduleVisitDateForServiceScreen(),
        Config.selectProviderScreen : (ctx)=> SelectProviderScreen(),
        Config.providerOverviewScreen : (ctx)=> ProviderReviewDetails(),
        Config.razorpaypaymentScreen : (ctx)=> PaymentMethodScreen(),
        Config.OderDetailsScreen : (ctx)=> OrderDetailsScreen(),
        Config.rateProviderScreenforBookings  : (ctx)=> RateProviderScreen(),
        Config.editschedulescreen : (ctx)=> EditScheduleVisitDateForServiceScreen(),
        Config.planDetailsScreen : (ctx)=> PlanDetails(),
        Config.custompackagejobs : (ctx)=> CustomPackageJobsScreen(),
        Config.subscriptionSummary : (ctx)=> SubscriptionSummary(),
        Config.scheduledateandTimeforSubscription : (ctx)=> ScheduleVisitDateForSubscriptionScreen(),
        Config.notificationscreen : (ctx)=> NotificationsScreen(),
        Config.servicePaymentScreen : (ctx)=> ServicePaymentScreen(),
        Config.afterPaymentScreen : (ctx)=> PaymentSuccessfulScreen(),
        Config.terms : (ctx)=> TermsConditions(),
        Config.inspectionReport : (ctx)=> Inspectionreport(),
        Config.editprofilepath : (ctx)=> EditProfile(),
        Config.pushnotificationscreen : (ctx)=> PushNotificationScreen(),
        Config.referandearnRouteName : (ctx)=> Referandearn(),
        Config.sendfeedbackScreenRouteName : (ctx)=> SendFeedbackScreen(),
        Config.otpRouteName : (ctx)=> OTPVerificationScreen(),
        Config.homeMainScreenDashboard : (ctx)=> HomeMainScreen(),
        Config.guestHomeScreen : (ctx)=> const GuestHomeScreen(),


  
        //Config.myOrdersRouteName: (ctx) =>  MyOrdersScreen(),

      },
      // onGenerateRoute: (settings) {
      //   return MaterialPageRoute(
      //     builder: (_) => const SplashScreen(),
      //   );
      // },
      onGenerateRoute: (settings) {
      

        if (settings.name == Config.addServicesToCartRouteName) {
          final args = settings.arguments as Map<String, dynamic>;

          // return MaterialPageRoute(
          //   builder: (_) => AddServicesScreen(
          //     serviceType: args['serviceType'] ?? '',
          //     serviceTitle: args['serviceTitle'] ?? '',
          //     //userid:args['user_id'] ?? '4361',
          //   ),
          // );
        }
        if (settings.name == Config.selectProviderVisitDateRouteName) {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (_) => ScheduleVisitDateScreen(
              serviceType: args['serviceType'] ?? '',
              serviceTitle: args['serviceTitle'] ?? '',
              services: (args['services'] as List<dynamic>).cast<Map<String, dynamic>>(),

              // This is the corrected line
              //userid:args['user_id'] ?? '4361',
            ),
          );
        }

        



        // if (settings.name == Config.paymentMethodRouteName) {
        //   final args = settings.arguments as Map<String, dynamic>;
        //   return MaterialPageRoute(
        //     builder: (_) => PaymentMethodScreen(
        //       amount: args["amount"] ?? 0.0,
        //       fromScreen: args['fromScreen'] ?? '',

        //     ),
        //   );
        // }


        // default
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      },
    );
  }
}

