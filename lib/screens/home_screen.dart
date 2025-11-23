import 'package:animal_kart_demo2/controllers/cart_provider.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/screens/tabs_screens/buffalo_list_screen.dart';
import 'package:animal_kart_demo2/screens/tabs_screens/cart_screen.dart';
import 'package:animal_kart_demo2/screens/tabs_screens/user_profile_screen.dart';
import 'package:animal_kart_demo2/screens/tabs_screens/wishlist_screen.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/auth/providers/auth_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _pages = const [
      BuffaloListScreen(),
      WishlistScreen(),
      CartScreen(showAppBar: false), // <- AppBar handled inside CartScreen
      UserProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final authState = ref.watch(authProvider);
    final userProfile = authState.userProfile;

    return Scaffold(
      backgroundColor: Theme.of(context).mainThemeBgColor,

      // ---- CONDITIONAL APPBAR ----
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).isLightTheme
            ? kPrimaryDarkColor
            : akDialogBackgroundColor,
        elevation: 0,
        toolbarHeight: 90,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        centerTitle: true,
        title:
            _selectedIndex ==
                3 // Profile tab
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userProfile?.name ?? 'User Profile',
                    style: TextStyle(
                      color: Theme.of(context).primaryTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (userProfile?.phone != null)
                    Text(
                      '+91 ${userProfile!.phone}',
                      style: TextStyle(
                        color: Theme.of(context).subTotalsTextColor,
                        fontSize: 18,
                      ),
                    ),
                ],
              )
            : Row(
                children: [
                  Image.asset('assets/images/onboard_logo.png', height: 50),
                  const SizedBox(width: 8),
                ],
              ),
        actions:
            _selectedIndex ==
                3 // Profile tab
            ? [] // Hide actions on profile tab
            : [
                // ThemeToggleButton(),
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
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
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

              // _navItem(index: 1, icon: Icons.favorite_border, label: "Saved"),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _navItem(
                    index: 2,
                    icon: Icons.shopping_bag_outlined,
                    label: "My Cart",
                  ),
                  if (cart.isNotEmpty)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cart.length.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              _navItem(index: 3, icon: Icons.person_outline, label: "Profile"),
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

  // Widget _navItem({
  //   required int index,
  //   required IconData icon,
  //   required String label,
  // }) {
  //   final isSelected = _selectedIndex == index;

  //   return GestureDetector(
  //     onTap: () => _onItemTapped(index),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         AnimatedContainer(
  //           duration: const Duration(milliseconds: 220),
  //           height: 6,
  //           width: 6,
  //           decoration: BoxDecoration(
  //             color: isSelected ? kPrimaryGreen : Colors.transparent,
  //             shape: BoxShape.circle,
  //           ),
  //         ),
  //         const SizedBox(height: 6),
  //         AnimatedContainer(
  //           duration: const Duration(milliseconds: 220),
  //           padding: EdgeInsets.symmetric(
  //             horizontal: isSelected ? 18 : 0,
  //             vertical: isSelected ? 10 : 0,
  //           ),
  //           decoration: BoxDecoration(
  //             color: isSelected ? kPrimaryGreen : Colors.transparent,
  //             borderRadius: BorderRadius.circular(30),
  //           ),
  //           child: Row(
  //             children: [
  //               Icon(
  //                 icon,
  //                 size: 26,
  //                 color: isSelected ? Colors.black : Colors.grey.shade700,
  //               ),
  //               if (isSelected) ...[
  //                 const SizedBox(width: 8),
  //                 Text(
  //                   context.tr(label),
  //                   style: const TextStyle(
  //                     color: Colors.black,
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
