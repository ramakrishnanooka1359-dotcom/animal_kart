import 'package:animal_kart_demo2/auth/models/user_model.dart';
import 'package:animal_kart_demo2/auth/providers/auth_provider.dart';
import 'package:animal_kart_demo2/buffalo/screens/buffalo_list_screen.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/orders/screens/orders_screen.dart';
import 'package:animal_kart_demo2/profile/screens/user_profile_screen.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/utils/save_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
      int _selectedIndex = 0;

      late final List<Widget> _pages;
      UserModel? localUser;

      @override
      void initState() {
        super.initState();
        _loadLocalUser();
        _pages = const [
          BuffaloListScreen(),
          // CartScreen(showAppBar: false),
          OrdersScreen(),
          UserProfileScreen(),
        ];
      }
      Future<void> _loadLocalUser() async {
      localUser = await loadUserFromPrefs();
          setState(() {});
      }

      void _onItemTapped(int index) {
       setState(() => _selectedIndex = index);
      }

  @override
  Widget build(BuildContext context) {
    // final cart = ref.watch(cartProvider);
    final authState = ref.watch(authProvider);
    final userProfile = authState.userProfile;

    return Scaffold(
      backgroundColor: Theme.of(context).mainThemeBgColor,

      // ---------- CONDITIONAL COMMON APPBAR ----------
                appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Theme.of(context).isLightTheme
                  ? kPrimaryDarkColor
                  : akDialogBackgroundColor,
              elevation: 0,
              toolbarHeight: 90,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),

              // Center title only for Orders & Profile
              centerTitle: _selectedIndex != 0,

              // ---------------- TITLE ----------------
              title: () {
                // PROFILE
                if (_selectedIndex == 2) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        localUser?.name ?? 'User Profile',
                        style: TextStyle(
                          color: Theme.of(context).primaryTextColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                        Text(
                          '+91 ${localUser?.mobile ?? ''}',
                          style: TextStyle(
                            color: Theme.of(context).primaryTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  );
                }

               
                if (_selectedIndex == 1) {
                  return const Text(
                    "Order History",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }

              
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/onboard_logo.png',
                      height: 50,
                    ),
                  ],
                );
              }(),

              // ---------------- ACTIONS ----------------
              actions: () {
                if (_selectedIndex == 1) return const <Widget>[]; // Orders
                if (_selectedIndex == 2) return const <Widget>[]; // Profile

                // HOME → show notification
                return <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.notifications_none_sharp,
                          color: Colors.white,
                        ),
                        onPressed: () {
                           Navigator.pushNamed(context, AppRouter.notification);
                        },
                      ),
                    ),
                  ),
                ];
              }(),
            ),

      body: _pages[_selectedIndex],

      // ---------- CUSTOM BOTTOM NAV ----------
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).isLightTheme
                ? kCardBg
                : akDialogBackgroundColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(index: 0, icon: Icons.home_rounded, label: "Home"),
              // Stack(
              //   clipBehavior: Clip.none,
              //   children: [
              //     _navItem(
              //       index: 1,
              //       icon: Icons.shopping_bag_outlined,
              //       label: "My Cart",
              //     ),
              //     if (cart.isNotEmpty)
              //       Positioned(
              //         right: -6,
              //         top: -4,
              //         child: Container(
              //           padding: const EdgeInsets.all(5),
              //           decoration: const BoxDecoration(
              //             color: Colors.red,
              //             shape: BoxShape.circle,
              //           ),
              //           child: Text(
              //             cart.length.toString(),
              //             style: const TextStyle(
              //               fontSize: 11,
              //               color: Colors.white,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ),
              //       ),
              //   ],
              // ),
              _navItem(index: 1, icon: Icons.shopping_cart, label: "Orders"),

              _navItem(index: 2, icon: Icons.person_outline, label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }

 Widget _navItem({
        required int index,
        required IconData icon,
        required String label,
      }) {
        final isSelected = _selectedIndex == index;

        return GestureDetector(
          onTap: () => _onItemTapped(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected ? kPrimaryGreen : Colors.grey.shade600,
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(label),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? kPrimaryGreen : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      }
    }
