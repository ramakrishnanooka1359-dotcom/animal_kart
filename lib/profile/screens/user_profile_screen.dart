import 'package:animal_kart_demo2/auth/models/user_model.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/services/biometric_service.dart';
import 'package:animal_kart_demo2/services/refer_service.dart';
import 'package:animal_kart_demo2/services/secure_storage_service.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/save_user.dart' as UserPrefsService;
import 'package:animal_kart_demo2/widgets/user_profile/info_card.dart';
import 'package:animal_kart_demo2/widgets/user_profile/refer_bottomsheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/locale_provider.dart';
import 'package:translator/translator.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool _isBiometricEnabled = false;
  bool _isLoading = true; // Loading flag for user + translation
  UserModel? _user;
  Map<String, String> translatedData = {};
  final translator = GoogleTranslator();


  @override
  void initState() {
    super.initState();
    _loadProfileAndBiometric();
  }



String maskAadhaar(String aadhaar) {
  final cleaned = aadhaar.replaceAll(RegExp(r'\s+'), '');

  if (cleaned.length < 4) return '****';

  final last4 = cleaned.substring(cleaned.length - 4);
  return 'XXXX-XXXX-$last4'; 
}




  Future<void> _loadProfileAndBiometric() async {
    // Load user data
    final user = await UserPrefsService.loadUserFromPrefs();
    _user = user;
//_coins = await ReferCoinService.getCoins();

    // Load biometric status
    final enabled = await SecureStorageService.isBiometricEnabled();
    _isBiometricEnabled = enabled;

    // Translate user data
    await _translateUserData();

    if (mounted) {
      setState(() {
        _isLoading = false; // All done, show full screen
      });
    }
  }

  Future<void> _translateUserData() async {
  if (_user == null) return;

  final langCode = ref.read(localeProvider).locale.languageCode;
  final Map<String, String> data = {};

  Future<void> addIfNotEmpty(String key, String? value) async {
    if (value != null && value.trim().isNotEmpty) {
      data[key] = await _translateValue(value, langCode);
    }
  }

  await addIfNotEmpty('Email', _user!.email);
  await addIfNotEmpty('Gender', _user!.gender);

  // ✅ Aadhaar fix
  final aadhaar = _user!.aadharNumber;

if (aadhaar != null &&
    aadhaar.toString().trim().isNotEmpty &&
    aadhaar.toString() != '0') {
  data['Aadhaar Card Number'] =
      maskAadhaar(aadhaar.toString());
}

   translatedData = data;
}

    

  Future<String> _transliterateName(String name, String langCode) async {
    if (name.isEmpty || langCode == 'en') return name;
    try {
      final transliteration =
          await translator.translate(name, from: 'en', to: langCode);
      return transliteration.text;
    } catch (_) {
      return name;
    }
  }

  Future<String> _translateValue(String value, String langCode) async {
    if (value.isEmpty || langCode == 'en') return value;
    try {
      final translation = await translator.translate(value, to: langCode);
      return translation.text;
    } catch (_) {
      return value;
    }
  }

  Future<void> _toggleBiometric(bool newValue) async {
    if (newValue) {
      // final hasBiometrics = await BiometricService.hasBiometrics();
      // if (!hasBiometrics) {
      //   _showBiometricNotAvailableDialog();
      //   return;
      // }

      final success = await BiometricService.authenticate();
      if (success) {
        await SecureStorageService.enableBiometric(true);
        setState(() => _isBiometricEnabled = true);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fingerprint lock enabled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Ask for confirmation before disabling
      final shouldDisable = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Disable App Lock'),
          content: const Text(
            'Are you sure you want to disable fingerprint lock?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Disable'),
            ),
          ],
        ),
      );

      if (shouldDisable == true) {
        await SecureStorageService.enableBiometric(false);
        setState(() => _isBiometricEnabled = false);
      }
    }
  }

  // void _showBiometricNotAvailableDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Biometric Not Available'),
  //       content: const Text(
  //         'Your device does not support biometric authentication or no fingerprints are enrolled.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(context).pop(),
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    ref.listen<LocaleProvider>(localeProvider, (_, __) async {
      // On language change, re-translate and refresh
      if (_user != null) {
        setState(() => _isLoading = true);
        await _translateUserData();
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    });

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).mainThemeBgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentLocale = ref.watch(localeProvider).locale;
    //  final profileData = {
    //   'Email': _user?.email ?? '',
    //   'Gender': _user?.gender ?? '',
    //   'Aadhar Card Number': _user?.aadharNumber.toString() ?? '',
    //   'Referred By Mobile': _user?.referedByMobile ?? '',
    //   'Referred By Name': _user?.referedByName ?? '',
    // };

    return Scaffold(
      backgroundColor: Theme.of(context).mainThemeBgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ---------- LANGUAGE ----------
            ListTile(
              title: Text(
                context.tr('selectLanguage'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: DropdownButton<Locale>(
                value: currentLocale,
                items: [
                  DropdownMenuItem(
                    value: const Locale('en'),
                    child: Text(context.tr('english')),
                  ),
                  DropdownMenuItem(
                    value: const Locale('hi'),
                    child: Text(context.tr('hindi')),
                  ),
                  DropdownMenuItem(
                    value: const Locale('te'),
                    child: Text(context.tr('telugu')),
                  ),
                ],
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    ref.read(localeProvider.notifier).setLocale(newLocale);
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            // ---------- PERSONAL INFO ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                context.tr('Personal Information'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),


            const SizedBox(height: 12),
            InfoCardWidget(items: translatedData),
            const SizedBox(height: 20),
          // App lock
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).lightThemeCardColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('app_lock_fingerprint'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _isLoading
                            ? const SizedBox(
                                width: 30,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Switch(
                          value: _isBiometricEnabled,
                          onChanged: _toggleBiometric,
                        ),
                      ],
                    ),
                    if (_isBiometricEnabled) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'App will lock when minimized and reopened',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Refer & Earn Button
            
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: GestureDetector(
            //     onTap: () => _showReferBottomSheet(context),
            //     child: Container(
            //       width: double.infinity,
            //       height: 55,
            //       decoration: BoxDecoration(
            //         color: const Color(0xFFE8F0FF),
            //         borderRadius: BorderRadius.circular(15),
            //         border: Border.all(color: Colors.blue.shade200),
            //       ),
            //       child: Center(
            //         child: Text(
            //           context.tr('refer_earn'),
            //           style: const TextStyle(
            //             color: Colors.blue,
            //             fontSize: 20,
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),

            const SizedBox(height: 20),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => _showLogoutConfirmation(context),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD6D6),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Center(
                    child: Text(
                      context.tr('logout'),
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
         title: Text(context.tr('logout')),
        //title: const Text('Logout'),
        content: Text(context.tr('logout_message')),
       // content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('cancel')),

            //child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.tr('logout')),
            //child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await SecureStorageService.enableBiometric(false);

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
    }
  }
void _showReferBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (_) => const ReferBottomSheet(referralCode: "TRALAGO"),
  );
}

}