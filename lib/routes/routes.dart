import 'package:animal_kart_demo2/auth/screens/login_screen.dart';
import 'package:animal_kart_demo2/auth/screens/otp_screen.dart';
import 'package:animal_kart_demo2/auth/screens/register_form.dart';
import 'package:animal_kart_demo2/buffalo/screens/bufflo_details_screen.dart';
import 'package:animal_kart_demo2/manualpayment/screens/payment_pending_screen.dart';
import 'package:animal_kart_demo2/notification/screens/notification_screen.dart';
import 'package:animal_kart_demo2/onboarding/screens/onboarding_screen.dart';
import 'package:animal_kart_demo2/orders/screens/orders_screen.dart';
import 'package:animal_kart_demo2/screens/home_screen.dart';
import 'package:animal_kart_demo2/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String splash = '/';
  static const String onBoardingScreen = '/onboarding_screen';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String profileForm = '/profile-form';
  static const String home = '/home';
  static const String notification = '/notification';
  static const String buffaloDetails = '/buffalodetails';
  static const String orders = '/orders';
  static const String PaymentPending = '/paymentPending';
  //static const String addBuffalocart = '/cart';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onBoardingScreen:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
     case otp:
      final args = settings.arguments as Map<String, dynamic>;
      final String phoneNumber = args['phoneNumber'];
      final String otp = args['otp'];
      final bool isFormFilled = args['isFormFilled'];
        return MaterialPageRoute(
          builder: (_) => OtpScreen(
            phoneNumber: phoneNumber,
            otp: otp,
            isFormFilled: isFormFilled,
          ),
        );


      case profileForm:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RegisterScreen(
            phoneNumberFromLogin: args['phoneNumberFromLogin'],
          ),
        );
      case home:
        return MaterialPageRoute(
          builder: (_) {
            final isHomeRoute = settings.name == AppRouter.home;

            // Read tab index only if arguments are provided
            final selectedTab = settings.arguments is int
                ? settings.arguments as int
                : 0;

            if (isHomeRoute) {
              return HomeScreen(selectedIndex: selectedTab);
            } else {
              return const LoginScreen();
            }
          },
        );

        case orders:
           return MaterialPageRoute(
          builder: (_) => OrdersScreen(),
        );
        case PaymentPending:
          return MaterialPageRoute(
          builder: (_) => PaymentPendingScreen(),
        );
      case buffaloDetails:
        final data = args as Map<String, dynamic>?;
      final buffaloId = data?['buffaloId'] ?? '';
        return MaterialPageRoute(
          builder: (_) => BuffaloDetailsScreen(buffaloId: buffaloId),
        );
      case notification:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text(message))),
    );
  }
}
