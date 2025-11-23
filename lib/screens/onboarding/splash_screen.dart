import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_constants.dart';
import '../../auth/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final currentUser = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    
    if (currentUser != null) {
      // User is logged in, check if they have completed the profile
      try {
        final authNotifier = ref.read(authProvider.notifier);
        final phoneNumber = currentUser.phoneNumber?.replaceAll('+91', '') ?? '';
        
        if (phoneNumber.isNotEmpty) {
          final isUserVerified = await authNotifier.verifyUser(phoneNumber);
          
          if (isUserVerified) {
            final userProfile = ref.read(authProvider).userProfile;
            
            if (userProfile?.isFormFilled == true) {
              // User has completed the form, go to home
              await prefs.setBool('isProfileCompleted', true);
              Navigator.pushReplacementNamed(context, AppRoutes.home);
              return;
            } else {
              // User exists but hasn't completed the form
              Navigator.pushReplacementNamed(
                context, 
                AppRoutes.profileForm,
                arguments: {'phoneNumber': phoneNumber},
              );
              return;
            }
          }
        }
      } catch (e) {
        // If there's an error verifying the user, treat as new user
        print('Error verifying user: $e');
      }
    }
    
    // User is not logged in or verification failed, go to onboarding
    Navigator.pushReplacementNamed(context, AppRoutes.onBoardingScreen);
  }

  @override
  Widget build(BuildContext context) {
    const Color animalKartGreen = Color(0xFF3A8F8A);

    return Scaffold(
      backgroundColor: animalKartGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo inside branded circle
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: animalKartGreen,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  AppConstants.appLogoAssert,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Name
            Text(
              AppConstants.kAppName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                height: 1.1,
                color: animalKartGreen,
              ),
            ),
            const SizedBox(height: 40),

            // Loader
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(animalKartGreen),
            ),
          ],
        ),
      ),
    );
  }
}
