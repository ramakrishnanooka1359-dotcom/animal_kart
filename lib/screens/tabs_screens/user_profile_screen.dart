import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../auth/providers/auth_provider.dart';
import '../../controllers/locale_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider).locale;
    final authState = ref.watch(authProvider);
    final userProfile = authState.userProfile;

    // Show loading indicator while user data is being fetched
    if (authState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error message if there's an error
    if (userProfile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load user data',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.refresh(authProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).mainThemeBgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            // ---------- PERSONAL INFORMATION ----------
            _infoCard(
              context,

              items: {
                // 'Name': userProfile.name ?? 'Not set',
                // 'Phone': userProfile.phone ?? userProfile.mobile ?? 'Not set',
                'Email': userProfile.email ?? 'Not set',
                'Gender': userProfile.gender ?? 'Not set',
                'Date of Birth': userProfile.dob ?? 'Not set',
                'Address': userProfile.address ?? 'Not set',
                'City': userProfile.city ?? 'Not set',
                'State': userProfile.state ?? 'Not set',
                'Pincode': userProfile.pincode ?? 'Not set',
              }..removeWhere((key, value) => value == 'Not set'),
            ), // Remove empty fields

            const SizedBox(height: 20),

            // ---------- AADHAAR ----------
            if (userProfile.aadhaarNumber != null &&
                userProfile.aadhaarNumber!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  context.tr('Aadhaar Card Number'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            if (userProfile.aadhaarNumber != null &&
                userProfile.aadhaarNumber!.isNotEmpty)
              _infoCard(context, items: {"": userProfile.aadhaarNumber!}),

            const SizedBox(height: 40),

            // ---------- LOGOUT BUTTON ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => _showLogoutConfirmation(context, ref),
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

  // Show logout confirmation dialog
  Future<void> _showLogoutConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
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
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // Show loading indicator
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Logging out...'),
            duration: Duration(seconds: 2),
          ),
        );

        // Call logout
        await ref.read(authProvider.notifier).logout();

        // Navigate to login screen and remove all previous routes
        // if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        // }
      } catch (e) {
        // if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        // }
      }
    }
  }
}

// ---------------------------------------------
// REUSABLE CARD WIDGET
// ---------------------------------------------
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
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
