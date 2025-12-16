import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ReferBottomSheet extends StatelessWidget {
  final String referralCode;
  final double unitPrice;
  final double userCoins;

  const ReferBottomSheet({
    super.key,
    required this.referralCode,
    this.unitPrice = 363000,
    this.userCoins = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        isSmallScreen ? 8 : 12,
        16,
        isSmallScreen ? 12 : 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),

          /// Title
          Text(
            "Refer & Earn",
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          /// Subtitle
          Text(
            "Invite friends, earn coins, and convert them into full units.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),

          /// Section Title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "How it works",
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),

          /// Steps (Compact)
          _stepCard(
            isSmallScreen,
            icon: Icons.shopping_cart,
            title: "Purchase Unit",
            description: "Buy a unit and unlock referral rewards.",
          ),
          _stepCard(
            isSmallScreen,
            icon: Icons.currency_rupee,
            title: "Earn Coins",
            description: "Every referral gives 5% unit value as coins.",
          ),
          _stepCard(
            isSmallScreen,
            icon: Icons.auto_graph,
            title: "Complete Unit",
            description: "Accumulate coins equal to one unit.",
          ),
          _stepCard(
            isSmallScreen,
            icon: Icons.swap_horiz,
            title: "Transfer",
            description: "Transfer by entering basic details",
          ),

          SizedBox(height: isSmallScreen ? 8 : 12),

          /// Share Button
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 44 : 48,
            child: ElevatedButton(
              onPressed: _shareReferral,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryDarkColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Share Referral Code",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),

          /// Transfer Button (Conditional)
          if (userCoins >= unitPrice) ...[
            SizedBox(height: isSmallScreen ? 6 : 8),
            SizedBox(
              width: double.infinity,
              height: isSmallScreen ? 44 : 48,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransferUnitScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: kPrimaryDarkColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Transfer Unit",
                  style: TextStyle(
                    fontSize: 14,
                    color: kPrimaryDarkColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Compact Step Card
  Widget _stepCard(
    bool compact, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: compact ? 6 : 10),
      padding: EdgeInsets.symmetric(
        vertical: compact ? 6 : 10,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: compact ? 14 : 18,
            backgroundColor: kPrimaryDarkColor.withOpacity(0.12),
            child: Icon(
              icon,
              size: compact ? 14 : 18,
              color: kPrimaryDarkColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: compact ? 11 : 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareReferral() {
    Share.share(
      "Use my referral code $referralCode and earn coins towards a full unit 🐃🔥",
    );
  }
}

/// Dummy Transfer Screen
class TransferUnitScreen extends StatelessWidget {
  const TransferUnitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transfer Unit")),
      body: const Center(child: Text("Transfer Unit Form Goes Here")),
    );
  }
}
