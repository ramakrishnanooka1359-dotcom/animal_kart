import 'package:animal_kart_demo2/controllers/buffalo_provider.dart';
import 'package:animal_kart_demo2/controllers/cart_provider.dart';
import 'package:animal_kart_demo2/screens/services/razorpay_service.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/widgets/successful_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartScreen extends ConsumerWidget {
  final bool showAppBar;
  const CartScreen({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final buffaloAsync = ref.watch(buffaloListProvider);

    return buffaloAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),

      error:
          (err, _) => Scaffold(
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
            appBar:
                showAppBar
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
                      title: const Text(
                        "Cart",
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
            body: const Center(
              child: Text("Your cart is empty", style: TextStyle(fontSize: 18)),
            ),
          );
        }

        return Scaffold(
          backgroundColor:
              Theme.of(context).isLightTheme
                  ? const Color(0xFFF8F8F8)
                  : akDarkThemeBackgroundColor,

          appBar:
              showAppBar
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
                    title: const Text(
                      "Cart",
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
              color: Theme.of(context).cardColor,
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
                          content: Text("Payment Failed Please try again"),
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
                    builder:
                        (_) => const Center(child: CircularProgressIndicator()),
                  );

                  razorpay.openPayment(amount: totalAmount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: const Text(
                  "Proceed to Payment",
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
            children:
                items.map((buff) {
                  final cartItem = cart[buff.id]!;
                  final qty = cartItem.qty;
                  final itemPrice = buff.price * qty;
                  final insurance = cartItem.insurancePaid;

                  final img = buff.buffaloImages.first;
                  final isNetwork = img.startsWith("http");

                  return Container(
                    margin: const EdgeInsets.only(bottom: 22),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).lightThemeCardColor,
                      borderRadius: BorderRadius.circular(22),
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
                              borderRadius: BorderRadius.circular(14),
                              child:
                                  isNetwork
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
                                    "Age: ${buff.age ?? '--'} yrs",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    "Quantity: $qty",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    "Milk Yield: ${buff.milkYield} L/day",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 26,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F5F2),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap:
                                              () => ref
                                                  .read(cartProvider.notifier)
                                                  .decrease(buff.id),
                                          child: const Icon(
                                            Icons.remove,
                                            size: 22,
                                            color: Colors.black,
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
                                          onTap:
                                              () => ref
                                                  .read(cartProvider.notifier)
                                                  .increase(buff.id),
                                          child: const Icon(
                                            Icons.add,
                                            size: 22,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            GestureDetector(
                              onTap:
                                  () => _confirmDelete(context, ref, buff.id),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "Note:\nIf you purchase 2 Murrah buffaloes you will receive insurance for the second buffalo completely Free",
                            style: TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5FDEB),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "What happens next?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text("✓ 12-day quarantine period begins"),
                              Text("✓ Daily health monitoring updates"),
                              Text("✓ Replacement guarantee if issues found"),
                              Text("✓ GPS-tracked safe transport"),
                              Text("✓ Complete documentation provided"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Price Breakdown",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 14),
                        _priceRow("Price:", "₹$itemPrice"),
                        const SizedBox(height: 6),
                        _priceRow("Insurance:", "₹$insurance"),
                        const Divider(height: 30),
                        _priceRow(
                          "Sub Total",
                          "₹${itemPrice + insurance}",
                          isBold: true,
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  Widget _priceRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
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
              const Text(
                "Message",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              const Text(
                "Are you sure you want to delete\nthis buffalo from your cart?",
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
                    child: const Text(
                      "Yes",
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
                    child: const Text(
                      "No",
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
