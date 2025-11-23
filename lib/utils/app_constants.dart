import 'package:animal_kart_demo2/models/onboarding_data.dart';
import 'package:intl/intl.dart';

const String kRobotoBold = 'RobotoBold';
const String kRoboto = 'Roboto';
const String kRobotoMedium = 'RobotoMedium';

class AppConstants {
  //common Constants
  static Duration kToastAnimDuration = Duration(milliseconds: 600);
  static Duration kToastDuration = Duration(milliseconds: 1800);
  static String kAppName = 'ANIMAL\nKART';
  static String countryCode = "+91";
  static String khyphen = "--";
  static String storageBucketName = 'gs://animalkart-559c3.firebasestorage.app';

  //Api constants
  static const String apiUrl =
      'https://markwave-live-services-couipk45fa-el.a.run.app';

  static const String applicationJson = 'application/json';

  //assets String
  static String appLogoAssert = 'assets/images/onboard_logo.png';
  static String onBoardAppLogo = "assets/images/onboard_logo1.png";
  static String AppNameAsset = "assets/images/app_name_text.png";

  //onboarding lsit
  static List<OnboardingData> onboardingData = [
    OnboardingData(
      image: "assets/images/buffalo_image2.png",
      subtitle:
          "Discover,hire and manage buffalo carts easily - anytime,anywhere",
      title: "Your Buffalo Cart Partner.",
    ),
    OnboardingData(
      image: "assets/images/buffalo_image3.png",
      subtitle:
          "Choose near by buffalo carts with transparent pricing and trusted owners",
      title: "Find the Cart Cart in Second.",
    ),
    OnboardingData(
      image: "assets/images/buffalo_image1.png",
      subtitle: "Live updates quick support,and smooth payments in one place",
      title: "Track Your Ride,Hassle - Free",
    ),
  ];
  String formatIndianAmount(num amount) {
    final formatter = NumberFormat.decimalPattern('en_IN');
    return formatter.format(amount);
  }
}
