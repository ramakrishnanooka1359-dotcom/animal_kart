import 'package:animal_kart_demo2/controllers/buffalo_provider.dart';
import 'package:animal_kart_demo2/controllers/cart_provider.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/screens/services/razorpay_service.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/utils/app_constants.dart';
import 'package:animal_kart_demo2/utils/svg_utils.dart';
import 'package:animal_kart_demo2/widgets/successful_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class CartScreen extends ConsumerWidget {
  final bool showAppBar;
  const CartScreen({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final buffaloAsync = ref.watch(buffaloListProvider);

    return buffaloAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (err, _) => Scaffold(
        body: Center(
          child: Text(
            "Failed to load buffalos\n$err",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),

      data: (buffaloList) {
        final items = buffaloList.where((b) => cart.containsKey(b.id)).toList();

        if (items.isEmpty) {
          return Scaffold(
            appBar: showAppBar
                ? AppBar(
                    elevation: 2,
                    backgroundColor: Theme.of(context).mainThemeBgColor,
                    toolbarHeight: 48,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      context.tr("Cart"),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                    ),
                  )
                : null,
            body: Center(
              child: Text(
                context.tr("Your cart is empty"),
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).isLightTheme
              ? const Color(0xFFF8F8F8)
              : akDarkThemeBackgroundColor,

          appBar: showAppBar
              ? AppBar(
                  elevation: 2,
                  backgroundColor: Theme.of(context).mainThemeBgColor,
                  toolbarHeight: 48,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    context.tr("Cart"),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                )
              : null,

          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  final cartNotifier = ref.read(cartProvider.notifier);

                  final razorpay = RazorPayService(
                    onPaymentSuccess: () async {
                      await cartNotifier.clearCart();
                      ref.invalidate(cartProvider);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingSuccessScreen(),
                        ),
                      );
                    },
                    onPaymentFailed: () {
                      Navigator.pop(context); // Close loader
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.tr("Payment Failed Please try again"),
                          ),
                        ),
                      );
                    },
                  );

                  int totalAmount = 0;
                  for (var b in items) {
                    final c = cart[b.id]!;
                    totalAmount += (b.price * c.qty) + c.insurancePaid;
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  razorpay.openPayment(amount: totalAmount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: Text(
                  context.tr("Proceed to Payment"),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          body: ListView(
            padding: const EdgeInsets.all(16),
            children: items.map((buff) {
              final cartItem = cart[buff.id]!;
              final qty = cartItem.qty;
              final itemPrice = buff.price * qty;
              final insurance = cartItem.insurancePaid;

              final img = buff.buffaloImages.first;
              final isNetwork = img.startsWith("http");

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 22),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).lightThemeCardColor,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.06),
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: isNetwork
                                  ? Image.network(
                                      img,
                                      width: 110,
                                      height: 135,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      img,
                                      width: 110,
                                      height: 135,
                                      fit: BoxFit.cover,
                                    ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    buff.breed,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),

                                  Text(
                                    "${context.tr("Age")}: ${buff.age ?? '--'} ${context.tr("yrs")}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    "${context.tr("Quantity")}: $qty",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    " ${context.tr("Milk Yield")}: ${buff.milkYield} ${context.tr("L")}/${context.tr("day")}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F5F2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => ref
                                              .read(cartProvider.notifier)
                                              .decrease(buff.id),
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: akBlackColor,
                                            child: const Icon(
                                              Icons.remove,
                                              size: 20,
                                              color: akWhiteColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 22),
                                        Text(
                                          "$qty",
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 22),
                                        GestureDetector(
                                          onTap: () => ref
                                              .read(cartProvider.notifier)
                                              .increase(buff.id),
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: akBlackColor,
                                            child: const Icon(
                                              Icons.add,
                                              size: 20,
                                              color: akWhiteColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            GestureDetector(
                              onTap: () =>
                                  _confirmDelete(context, ref, buff.id),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.string(
                                  SvgUtils().deleteIcon,

                                  color: akRedColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      context.tr("insurance_note"),
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5FDEB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr("What happens next?"),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "✓${context.tr('12-day quarantine period begins')}",
                        ),
                        Text(
                          "✓ ${context.tr('Daily health monitoring updates')}",
                        ),
                        Text(
                          "✓ ${context.tr('Replacement guarantee if issues found')}",
                        ),
                        Text("✓ ${context.tr('GPS-tracked safe transport')}"),
                        Text(
                          "✓ ${context.tr('Complete documentation provided')}",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    context.tr("Price Breakdown"),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 14),
                  _priceRow(
                    context,
                    "Price:",
                    "₹${AppConstants().formatIndianAmount(itemPrice)}",
                  ),
                  const SizedBox(height: 6),
                  _priceRow(
                    context,
                    "Insurance",
                    "₹${AppConstants().formatIndianAmount(insurance)}",
                  ),
                  const Divider(height: 30),
                  _priceRow(
                    context,
                    "Sub Total",
                    "₹${AppConstants().formatIndianAmount(itemPrice + insurance)}",
                    isBold: true,
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _priceRow(
    BuildContext context,

    String title,
    String value, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${context.tr(title)}",
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 19 : 15,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
  showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 22),
                ),
              ),

              const SizedBox(height: 5),
              Text(
                context.tr("Message"),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Text(
                context.tr(context.tr("delete_alert")),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.4),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).remove(id);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      context.tr("Yes"),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      context.tr("No"),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
