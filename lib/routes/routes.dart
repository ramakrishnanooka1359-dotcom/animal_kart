import 'package:animal_kart_demo2/auth/screens/login_screen.dart';
import 'package:animal_kart_demo2/auth/screens/otp_screen.dart';
import 'package:animal_kart_demo2/auth/screens/register_form.dart';
import 'package:animal_kart_demo2/buffalo/screens/bufflo_details_screen.dart';
import 'package:animal_kart_demo2/notification/screens/notification_screen.dart';
import 'package:animal_kart_demo2/screens/home_screen.dart';
import 'package:animal_kart_demo2/onboarding/screens/onboarding_screen.dart';
import 'package:animal_kart_demo2/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onBoardingScreen = '/onboarding_screen';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String profileForm = '/profile-form';
  static const String home = '/home';
  static const String notification = '/notification';
  static const String buffaloDetails = '/buffalodetails';
  //static const String addBuffalocart = '/cart';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    final verificationId = args?['verificationId'] as String?;
  
    final phoneNumber = args?['phoneNumber'] as String? ?? '';
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onBoardingScreen:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case otp:
        return MaterialPageRoute(
          builder: (_) => OtpScreen(
            phoneNumber: phoneNumber, 
          ),
        );
        
      case profileForm:
        return MaterialPageRoute(
          builder: (_) => RegisterScreen(phoneNumberFromLogin: phoneNumber),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case buffaloDetails:
        final buffaloId = args?['buffaloId'] as String? ?? '';
        return MaterialPageRoute(builder: (_)=>  BuffaloDetailsScreen(buffaloId: buffaloId) );
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
