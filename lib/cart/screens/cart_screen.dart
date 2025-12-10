import 'package:animal_kart_demo2/buffalo/providers/buffalo_provider.dart';
import 'package:animal_kart_demo2/cart/providers/cart_provider.dart';
import 'package:animal_kart_demo2/services/razorpay_service.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/utils/app_constants.dart';
import 'package:animal_kart_demo2/utils/svg_utils.dart';
import 'package:animal_kart_demo2/widgets/disable_addbutton_widget.dart';
import 'package:animal_kart_demo2/manualpayment/screens/manual_payment_screen.dart';
import 'package:animal_kart_demo2/widgets/payment_widgets/successful_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../buffalo/models/buffalo.dart';

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

      error: (err, _) =>
          Scaffold(body: Center(child: Text("Failed to load buffalos\n$err"))),

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
          backgroundColor: Theme.of(context).mainThemeBgColor,
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

          bottomNavigationBar: _checkoutButton(context, ref, items, cart),

          body: ListView(
            padding: const EdgeInsets.all(16),
            children: items.map((buff) {
              final cartItem = cart[buff.id]!;
              final units = cartItem.qty;
              final buffaloCount = units * 2;
              final insuranceUnits = cartItem.insuranceUnits;

              final price = buffaloCount * buff.price;
              final insuranceAmount = insuranceUnits * buff.insurance;
              final total = price + insuranceAmount;

              return Stack(
                children: [
                  /// MAIN CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 22),
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
                    child: _buildCardContent(
                      context,
                      ref,
                      buff,
                      units,
                      buffaloCount,
                      insuranceUnits,
                      price,
                      insuranceAmount,
                      total,
                    ),
                  ),

                  /// DELETE BUTTON (FLOATING TOP-RIGHT)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => _confirmDelete(context, ref, buff.id),
                      child: Container(
                        height: 30,
                        width: 30,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.06),
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(color: akBlackColor38, width: 0.5),
                          shape: BoxShape.circle,
                          color: akWhiteColor,
                        ),
                        child: SvgPicture.string(
                          SvgUtils().deleteIcon,
                          color: akRedColor,
                        ) /* Icon(Icons.delete, color: Colors.red, size: 20) */,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    WidgetRef ref,
    Buffalo buff,
    int units,
    int buffaloCount,
    int insuranceUnits,
    int price,
    int insuranceAmount,
    int total,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------- TOP ROW ----------------
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                buff.buffaloImages.first,
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
                      fontWeight: FontWeight.w700,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text("Units: $units",style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Buffaloes: $buffaloCount  (2 Calf)",style: TextStyle(fontWeight: FontWeight.bold),),
                  Text("Milk Yield: ${buff.milkYield} L/day"),

                  const SizedBox(height: 10),
                  _unitSelector(ref, buff.id, units),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        _insuranceSelector(context, ref, buff, units, insuranceUnits),

        const SizedBox(height: 22),

        // PRICE BREAKDOWN
        const Text(
          "Price Breakdown",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 10),

        _priceRow(
          "Buffalo Price",
          "₹${AppConstants().formatIndianAmount(price)}",
        ),
        _priceRow(
          "CPF (Cattle protection Fund)",
          "₹${AppConstants().formatIndianAmount(insuranceAmount)}",
        ),

        const Divider(height: 30),

        _priceRow(
          "Total",
          "₹${AppConstants().formatIndianAmount(total)}",
          isBold: true,
        ),

        const SizedBox(height: 20),

        _priceExplanation(buff, units, insuranceUnits),
      ],
    );
  }

  
  Widget _unitSelector(WidgetRef ref, String id, int units) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => ref.read(cartProvider.notifier).decreaseUnits(id),
            child: DisabledCircleButton(
          icon: Icons.remove,
          radius: 12,
          iconSize: 20,
        ),
           // child: _circleButtonSmall(Icons.remove),
          ),
          const SizedBox(width: 12),
          Text(
            "$units",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          GestureDetector(
  onTap: null, // disables tap completely
  child: DisabledCircleButton(icon: Icons.add),
),

          // GestureDetector(
          //   onTap: () => ref.read(cartProvider.notifier).increaseUnits(id),
          //   child: _circleButtonSmall(Icons.add),
          // ),
        ],
      ),
    );
  }

  // Widget _circleButtonSmall(IconData icon) {
  //   return CircleAvatar(
  //     radius: 11,
  //     backgroundColor: akBlackColor,
  //     child: Icon(icon, size: 16, color: Colors.white),
  //   );
  // }

  
  Widget _insuranceSelector(
    BuildContext context,
    WidgetRef ref,
    Buffalo buff,
    int units,
    int insuranceUnits,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8FF),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CPF Selection",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          Text("Max CPF: $units units"),
          Text("CPF per unit: ₹${buff.insurance}"),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "CPF Units",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
          Row(
            children: [
              /// ➖ DECREASE BUTTON
              GestureDetector(
                onTap: insuranceUnits > 0
                    ? () => ref
                        .read(cartProvider.notifier)
                        .decreaseInsurance(buff.id)
                    : null, // ✅ disabled at 0
                child: _circleButton(
                  Icons.remove,
                  isDisabled: insuranceUnits == 0,
                ),
              ),

              const SizedBox(width: 18),

              /// VALUE
              Text(
                "$insuranceUnits",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(width: 18),

              /// ➕ INCREASE BUTTON
              GestureDetector(
                onTap: insuranceUnits == 0
                    ? () => ref
                        .read(cartProvider.notifier)
                        .increaseInsurance(buff.id)
                    : null, // ✅ disabled when value is 1+
                child: _circleButton(
                  Icons.add,
                  isDisabled: insuranceUnits != 0,
                ),
              ),
            ],
          ),

                        // Row(
                        //   children: [
                        //     GestureDetector(
                        //       onTap: () => ref
                        //           .read(cartProvider.notifier)
                        //           .decreaseInsurance(buff.id),
                        //       child: _circleButton(Icons.remove),
                        //     ),
                        //     const SizedBox(width: 18),

                        //     Text(
                        //       "$insuranceUnits",
                        //       style: const TextStyle(
                        //         fontSize: 17,
                        //         fontWeight: FontWeight.w700,
                        //       ),
                        //     ),

                        //     const SizedBox(width: 18),

                        //     GestureDetector(
                        //       onTap: () => ref
                        //           .read(cartProvider.notifier)
                        //           .increaseInsurance(buff.id),
                        //       child: _circleButton(Icons.add),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ],
                ),
              );
            }
 // Widget _circleButton(IconData icon) {
  //   return CircleAvatar(
  //     radius: 12,
  //     backgroundColor: akBlackColor,
  //     child: Icon(icon, size: 18, color: Colors.white),
  //   );
  // }
Widget _circleButton(
  IconData icon, {
  bool isDisabled = false,
}) {
  return CircleAvatar(
    radius: 12,
    backgroundColor:
        isDisabled ? Colors.grey.shade400 : akBlackColor,
    child: Icon(
      icon,
      size: 18,
      color: isDisabled ? akWhiteColor : Colors.white,
    ),
  );
}

  // ===============================================================
  // PRICE ROW
  // ===============================================================
  Widget _priceRow(String left, String right, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontSize: isBold ? 19 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

Widget _checkoutButton(
  BuildContext context,
  WidgetRef ref,
  List<Buffalo> buffList,
  Map<String, CartItem> cartMap,
) {
  int totalAmount = 0;
  for (Buffalo b in buffList) {
    final c = cartMap[b.id]!;
    totalAmount +=
        (b.price * (c.qty * 2)) + (c.insuranceUnits * b.insurance);
  }

  return Container(
    padding: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 55,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final cartNotifier = ref.read(cartProvider.notifier);

              final razorpay = RazorPayService(
                onPaymentSuccess: () async {
                  await cartNotifier.clearCart();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => BookingSuccessScreen()),
                  );
                },
                onPaymentFailed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Payment failed, try again")),
                  );
                },
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
              "Online Payment",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

       
        SizedBox(
          height: 55,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final cartNotifier = ref.read(cartProvider.notifier);
              await cartNotifier.clearCart();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManualPaymentScreen(
                    totalAmount: totalAmount,  
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: const Text(
              "Manual Payment",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


}

// ===============================================================
// DELETE CONFIRMATION
// ===============================================================
void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text("Delete Item"),
      content: const Text("Do you want to remove this item?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () {
            ref.read(cartProvider.notifier).remove(id);
            Navigator.pop(context);
          },
          child: const Text("Yes"),
        ),
      ],
    ),
  );
}

// ===============================================================
// PRICE EXPLANATION BOX
// ===============================================================
Widget _priceExplanation(Buffalo buff, int units, int insuranceUnits) {
  final buffaloes = units * 2;
  final pricePerBuffalo = buff.price;
  final pricePerUnit = buff.price * 2;
  final totalBuffaloPrice = pricePerUnit * units;
  final insurancePerUnit = buff.insurance;
  final totalInsurance = insurancePerUnit * insuranceUnits;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFFAFDF6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFB2E3A8)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How Your Price Is Calculated",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),

        _calcLine("Units Selected", "$units units"),
        _calcLine("Total Buffaloes", "$buffaloes buffaloes"),
        _calcLine(
          "Price per Buffalo",
          "₹${AppConstants().formatIndianAmount(pricePerBuffalo)}",
        ),
        _calcLine(
          "Price Per Unit (2 buffaloes)",
          "₹${AppConstants().formatIndianAmount(pricePerUnit)}",
        ),
        _calcLine(
          "Total Buffalo Price",
          "₹${AppConstants().formatIndianAmount(totalBuffaloPrice)}",
        ),

        _calcLine(
          "CPF Per Buffalo",
          "₹${AppConstants().formatIndianAmount(insurancePerUnit)}",
        ),
        _calcLine("CPF Units Chosen", "$insuranceUnits units"),
        _calcLine(
          "Total CPF Cost",
          "₹${AppConstants().formatIndianAmount(totalInsurance)}",
        ),

        const SizedBox(height: 14),

        const Text(
          "✔ You can insure any number of buffaloes.\n"
          "✔ Example: If you buy 2 units (4 buffaloes), you can insure between 1–4.",
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    ),
  );
}

Widget _calcLine(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            "• $label:",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
