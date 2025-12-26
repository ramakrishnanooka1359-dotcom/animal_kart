import 'dart:io';

import 'package:animal_kart_demo2/auth/models/user_model.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/profile/providers/profile_provider.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/services/biometric_service.dart';
import 'package:animal_kart_demo2/services/secure_storage_service.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/profile/widgets/info_card.dart';
import 'package:animal_kart_demo2/profile/widgets/refer_bottomsheet_widget.dart';
import 'package:animal_kart_demo2/widgets/coin_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  bool _isLoading = true;
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(profileProvider.notifier).fetchCurrentUser();
    });

    _loadBiometricStatus();
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

  String maskAadhaar(String aadhaar) {
    final cleaned = aadhaar.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length < 4) return 'XXXX';
    final last4 = cleaned.substring(cleaned.length - 4);
    return 'XXXX-XXXX-$last4';
  }

  Future<Map<String, String>> buildTranslatedData(UserModel user) async {
    final langCode = ref.read(localeProvider).locale.languageCode;
    final Map<String, String> data = {};

    Future<void> add(String key, String? value) async {
      if (value != null && value.trim().isNotEmpty) {
        data[key] = await _translateValue(value, langCode);
      }
    }

    await add('Email', user.email);
    await add('Gender', user.gender);

    if (user.aadharNumber != 0) {
      data['Aadhaar Number'] = maskAadhaar(user.aadharNumber.toString());
    }

    if (user.coins != null) {
      data['Coins'] = user.coins!.toStringAsFixed(0);
    }

    await add('Referred Mobile', user.referedByMobile);
    await add('Referred Name', user.referedByName);

    return data;
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
      final success = await BiometricService.authenticate();
      if (success) {
        await SecureStorageService.enableBiometric(true);
        setState(() => _isBiometricEnabled = true);
      }
    } else {
      final shouldDisable = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Disable App Lock'),
          content: const Text(
            'Are you sure you want to disable fingerprint lock?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
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

  void _showReferBottomSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => ReferBottomSheet(
        referralCode: user.mobile,
        unitPrice: 363000,
        userCoins: user.coins ?? 0,
        currentUser: user,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final currentLocale = ref.watch(localeProvider).locale;
    final user = profileState.currentUser;

    if ((_isLoading || profileState.isLoading) && user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).mainThemeBgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).mainThemeBgColor,
      body: user == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  profileState.error ?? 'No profile data found',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
          : FutureBuilder<Map<String, String>>(
              future: buildTranslatedData(user),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (profileState.error != null)
                        Container(
                          color: Colors.red.shade100,
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            profileState.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 20),

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
                          items: const [
                            DropdownMenuItem(
                              value: Locale('en'),
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: Locale('hi'),
                              child: Text('Hindi'),
                            ),
                            DropdownMenuItem(
                              value: Locale('te'),
                              child: Text('Telugu'),
                            ),
                          ],
                          onChanged: (locale) {
                            if (locale != null) {
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(locale);
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

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
                      InfoCardWidget(
                        items: Map.from(snapshot.data!)..remove('Coins'),
                      ),

                      // InfoCardWidget(items: snapshot.data!),
                      const SizedBox(height: 20),
const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: CoinBadge(),
        ),
if (!Platform.isIOS)
  Padding( 
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).lightThemeCardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.tr('app_lock_fingerprint'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Switch(
            value: _isBiometricEnabled,
            onChanged: _toggleBiometric,
          ),
        ],
      ),
    ),
  ),


                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () => _showReferBottomSheet(context, user),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FF),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                context.tr('refer_earn'),
                                style: const TextStyle(
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
                            height: 55,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD6D6),
                              borderRadius: BorderRadius.circular(15),
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
                );
              },
            ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.tr('logout')),
        content: Text(context.tr('logout_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              await prefs.clear();
              Navigator.pop(context, true);
            },
            child: Text(context.tr('logout')),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await SecureStorageService.enableBiometric(false);
      Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (_) => false);
    }
  }
}
