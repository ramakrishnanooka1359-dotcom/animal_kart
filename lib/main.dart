import 'package:animal_kart_demo2/auth/screens/biometric_lock_screen.dart';
import 'package:animal_kart_demo2/auth/firebase_options.dart';
import 'package:animal_kart_demo2/theme/theme_provider.dart';
import 'package:animal_kart_demo2/utils/location_service.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:flutter_localizations/flutter_localizations.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_provider.dart';
import 'routes/routes.dart';
import 'theme/app_theme.dart' as AppTheme;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    // DevicePreview(
    //   enabled: !kReleaseMode,
    //   builder: (context) => 
    ProviderScope(
      child: OKToast(
        child: MyApp(isDarkMode: isDarkMode, isLoggedIn: isLoggedIn),
      ),
    ),
   // )
  );
}

class MyApp extends ConsumerStatefulWidget {
  final bool isDarkMode;
  final bool isLoggedIn;

  const MyApp({super.key, required this.isDarkMode, required this.isLoggedIn});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    // Add small delay to ensure context is ready if needed, though initState is early
    await Future.delayed(const Duration(seconds: 1));

    final position = await LocationService.getCurrentLocation();

    if (position != null) {
     

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('latitude', position.latitude);
      await prefs.setDouble('longitude', position.longitude);
    } else {
      debugPrint("Failed to get location or permission denied");
      // Optional: Show toast or snackbar if appropriate, but be careful at startup
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeNotifierProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Animal Kart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,
      locale: locale.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('hi', ''), // Hindi
        Locale('te', ''), // Telugu
      ],
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,

      builder: (context, child) {
       
        if (!widget.isLoggedIn) {
          return child ?? const SizedBox();
        }
        //         final currentRoute = ModalRoute.of(context)?.settings.name;
        // debugPrint('Current route: $currentRoute');

        // Check if we're on the home route and user is logged in
        // final isHomeRoute =
        //     currentRoute == AppRouter.home ||
        //     currentRoute == '/' ||
        //     currentRoute == null;
        // if (isHomeRoute && isLoggedIn) {
        //   return ;
        // }

        
        
        return BiometricLockScreen(
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
