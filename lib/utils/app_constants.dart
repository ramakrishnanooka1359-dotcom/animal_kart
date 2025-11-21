import 'package:animal_kart_demo2/models/onboarding_data.dart';

class AppConstants {
  //common Constants
  static Duration kToastAnimDuration = Duration(milliseconds: 600);
  static Duration kToastDuration = Duration(milliseconds: 1800);
  static String kAppName = 'ANIMAL\nKART';
  static String countryCode = "+91";
  static String khyphen = "--";

  //Api constants
  static const String apiUrl =
      'https://markwave-admin-dasboard-couipk45fa-ew.a.run.app';

  static const String applicationJson = 'application/json';

  //assets String
  static String appLogoAssert = 'assets/images/onboard_logo.png';

  //onboarding lsit
  static List<OnboardingData> onboardingData = [
    OnboardingData(
      image: "assets/images/buffalo_images.jpg",
      subtitle: "Find the  in Seconds",
      title:
          "Choose nearby buffalo carts with transparent pricing and trusted owners.",
    ),
    OnboardingData(
      image: "assets/images/buffalo_images2.jpg",
      subtitle: "Verified Buffalo Owners",
      title:
          "Every cart owner is verified to make sure you get a safe experience.",
    ),
    OnboardingData(
      image: "assets/images/buffalo_images3.jpeg",
      subtitle: "Fast & Easy Booking",
      title: "Book your preferred buffalo cart instantly with one tap.",
    ),
  ];
}
