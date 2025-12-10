import 'package:animal_kart_demo2/auth/models/user_model.dart';

import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/services/biometric_service.dart';
import 'package:animal_kart_demo2/services/secure_storage_service.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/save_user.dart' as UserPrefsService;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/locale_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  bool _isBiometricEnabled = false;
  bool _isLoading = true;
  UserModel? _user;


  

  

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = await UserPrefsService.loadUserFromPrefs();
    if (mounted) {
      setState(() => _user = user);
    }
  }

  Future<void> _loadBiometricStatus() async {
    final enabled = await SecureStorageService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _isBiometricEnabled = enabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool newValue) async {
    if (newValue) {
      final hasBiometrics = await BiometricService.hasBiometrics();
      if (!hasBiometrics) {
        _showBiometricNotAvailableDialog();
        return;
      }

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

  void _showBiometricNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biometric Not Available'),
        content: const Text(
          'Your device does not support biometric authentication or no fingerprints are enrolled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return _buildProfileContent(context);
  }

  Widget _buildProfileContent(BuildContext context) {
    final currentLocale = ref.watch(localeProvider).locale;
   

    final profileData = {
      'Email': _user?.email ?? '',
      'Gender': _user?.gender ?? '',
      'Aadhar Card Number': _user?.aadharNumber ?? '',
      'Referred By Mobile': _user?.referedByMobile ?? '',
      'Referred By Name': _user?.referedByName ?? '',
    };

  
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
            _infoCard(context, items: profileData),
            const SizedBox(height: 20),
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
                        const Text(
                          "App Lock (Fingerprint)",
                          style: TextStyle(
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

            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => _showReferBottomSheet(context),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FF),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Center(
                    child: Text(
                      'Refer & Earn',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            
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

  Widget _infoCard(BuildContext context, {required Map<String, String> items}) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).lightThemeCardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (e.key.isNotEmpty)
                    Text(
                      context.tr(e.key),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    e.value,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
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
  const referralCode = "TRALAGO";

  showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            

            const SizedBox(height: 6),

            // Title
            const Text(
              'Refer & Earn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "Earn 1000 coins when your friend registers using your referral code!",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 14),

            // Referral Code Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.18), // soft green shadow
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    referralCode,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.6,
                    ),
                  ),

                 IconButton(
  icon: const Icon(Icons.copy, size: 20),
  onPressed: () {
    final message =
        "Use my referral code $referralCode and get 1000 coins on signup! 🐃🔥";

    Clipboard.setData(
      ClipboardData(text: message),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Referral message copied!"),
        duration: Duration(milliseconds: 900),
      ),
    );
  },
),

                ],
              ),
            ),

            const SizedBox(height: 14),

            // How it works
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "How it works",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 10),
            _stepTile("1️⃣  Share your referral code"),
            _stepTile("2️⃣  Friend installs & registers"),
            _stepTile("3️⃣  You earn 1000 coins instantly!"),

            const SizedBox(height: 18),

            // SHARE BUTTON (Modern, Clean)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _shareReferral(referralCode),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryDarkColor,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: const Text(
                  "Share Now",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

    Widget _stepTile(String text) 
    { return Padding( padding: const EdgeInsets.only(bottom: 8), 
    child: Row( children: [ const SizedBox(width: 4), 
    Expanded( child: 
    Text( text, 
    style: const TextStyle(
      fontSize: 14, 
      color: Colors.black87, 
      ),
        ),
        ),
          ],
          ),
            );
            }
  // void _showReferBottomSheet(BuildContext context) {
  //   const referralCode = "TRALAGO";
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text(
  //               'Refer & Earn',
  //               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 10),
  //             const Text(
  //               "You will get 1000 coins for each refer",
  //               style: TextStyle(fontSize: 16, color: Colors.grey),
  //             ),
  //             const SizedBox(height: 20),
  //             Container(
  //               padding: const EdgeInsets.symmetric(
  //                 vertical: 12,
  //                 horizontal: 20,
  //               ),
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(12),
  //                 color: Colors.grey.shade200,
  //               ),
  //               child: const Text(
  //                 referralCode,
  //                 style: TextStyle(
  //                   fontSize: 20,
  //                   letterSpacing: 2,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 25),
  //             ElevatedButton(
  //               onPressed: () => _shareReferral(referralCode),
  //               child: const Text('Share Now'),
  //             ),
  //             const SizedBox(height: 15),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  void _shareReferral(String code) {
    Share.share(
      "Use my referral code $code and get 1000 coins on signup! 🐃🔥",
    );
  }
}
