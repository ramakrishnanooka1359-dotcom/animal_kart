import 'package:animal_kart_demo2/auth/models/user_model.dart';

import 'package:animal_kart_demo2/buffalo/screens/buffalo_list_screen.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/orders/providers/orders_providers.dart';
import 'package:animal_kart_demo2/orders/screens/orders_screen.dart';
import 'package:animal_kart_demo2/profile/screens/user_profile_screen.dart';
import 'package:animal_kart_demo2/profile/providers/profile_provider.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/utils/save_user.dart';
import 'package:animal_kart_demo2/widgets/internet_check_wrapper.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translator/translator.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int selectedIndex;

  const HomeScreen({super.key, this.selectedIndex = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;
  UserModel? localUser;
  final translator = GoogleTranslator();
  String? localizedUserName;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _pages = const [
      InternetCheckWrapper(showFullPage: true, child: BuffaloListScreen()),
      InternetCheckWrapper(showFullPage: true, child: OrdersScreen()),
      InternetCheckWrapper(showFullPage: true, child: UserProfileScreen()),
    ];
    _loadLocalUser();
  }

  Future<void> _loadLocalUser() async {
    localUser = await loadUserFromPrefs();
    setState(() {});
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      ref.read(ordersProvider.notifier).loadOrders();
    } else if (index == 2) {
      ref.read(profileProvider.notifier).fetchCurrentUser();
    }
    setState(() => _selectedIndex = index);
  }

  //void _goToOrdersTab() => setState(() => _selectedIndex = 1);
  void _goToHomeTab() => setState(() => _selectedIndex = 0);

  @override
  Widget build(BuildContext context) {
    return InternetCheckWrapper(
      showSnackbar: true,
      child: WillPopScope(
        onWillPop: () async {
          if (_selectedIndex != 0) {
            _goToHomeTab();
            return false;
          } else {
            SystemNavigator.pop();
            return false;
          }
        },

        child: Scaffold(
          backgroundColor: Theme.of(context).mainThemeBgColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).isLightTheme
                ? kPrimaryDarkColor
                : Colors.grey[850],
            elevation: 0,
            toolbarHeight: 90,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            centerTitle: _selectedIndex != 0,
            title: _buildTitle(context),
            actions: _buildActions(context),
          ),
          body: IndexedStack(index: _selectedIndex, children: _pages),
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (_selectedIndex == 2) {
      // Profile Screen
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
              color: Theme.of(context).secondaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (_selectedIndex == 1) {
      // Orders
      return Text(
        context.tr("orderHistory"),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      // Home
      return Image.asset('assets/images/onboard_logo.png', height: 50);
    }
  }

  List<Widget> _buildActions(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return [
          // const Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 12),
          //   child: CoinBadge(),
          // ),
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
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.notification);
                },
              ),
            ),
          ),
        ];
      case 1:
        return const [];
      case 2:
        return const [];
      default:
        return const [];
    }
  }

  // ---------- Bottom Navigation ----------
  Widget _buildBottomNav() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).isLightTheme
              ? Colors.white
              : Colors.grey[850],
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
            _navItem(
              index: 0,
              activeIcon: Icons.home_rounded,
              inactiveIcon: Icons.home_outlined,
              label: "Home",
            ),
            _navItem(
              index: 1,
              activeIcon: Icons.shopping_cart,
              inactiveIcon: Icons.shopping_cart_outlined,
              label: "orders",
            ),
            _navItem(
              index: 2,
              activeIcon: Icons.person,
              inactiveIcon: Icons.person_outline,
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? activeIcon : inactiveIcon,
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
