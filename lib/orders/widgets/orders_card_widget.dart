import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/orders/widgets/dat_time_helper_widget.dart';
import 'package:animal_kart_demo2/orders/widgets/tracker_screen.dart';
import 'package:animal_kart_demo2/utils/convert.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../../manualpayment/screens/manual_payment_screen.dart';

class BuffaloOrderCard extends StatelessWidget {
  final OrderUnit order;
  final Future<void> Function() onTapInvoice;

  const BuffaloOrderCard({
    super.key,
    required this.order,
    required this.onTapInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final String status = order.paymentStatus.toUpperCase();
    final bool isAdminVerificationPending = order.paymentStatus.toUpperCase() == "PENDING_ADMIN_VERIFICATION";
    final bool isPaid = status == "PAID";
     final bool showPaymentType =
      (isPaid || isAdminVerificationPending) &&
      order.paymentType != null;

    final bool isPendingPayment = status == "PENDING_PAYMENT";
    final bool isAdminReview = status == "PENDING_ADMIN_VERIFICATION";

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: isPendingPayment
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManualPaymentScreen(
                    totalAmount: order.totalCost,
                    unitId: order.id,
                    userId: order.userId,
                    buffaloId: order.breedId,
                  ),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        mainAxisSize: MainAxisSize.min,               
                        children: [
                          Text(
                            "Order Id : ${order.id}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          
                          Text(
                            //'',
                          "Placed on : ${formatToIndianDateTime(order.userCreatedAt)}",

                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                  if (isPaid)
                    _statusChip("PAID", Colors.green),

                  if (isPendingPayment)
                    _statusChip("PENDING", Colors.orange),

                  if (isAdminReview)
                    _statusChip("ADMIN REVIEW", const Color(0xFF7E57C2)),
                ],
              ),
            ),

            _divider(),

            /// ================= DETAILS =================
Padding(
  padding: const EdgeInsets.all(14),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start, // aligns everything at the top
    children: [
      // ---------------- IMAGE ----------------
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          "assets/images/buffalo_image2.png",
          height: 70,
          width: 100,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(width: 10),

      // ---------------- BUFFALO INFO ----------------
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Breed ID: ${order.breedId}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _valueRow(context, "${order.buffaloCount}", context.tr("buffalo")),
                const SizedBox(width: 6),
                _valueRow(context, "${order.calfCount}", context.tr("calf")),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "${order.numUnits} ${context.tr("unit")} + CPF",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),

        // ---------------- VERTICAL DIVIDER ----------------
        Container(
          height: 70, // match image or content height
          width: 1,
          color: Colors.grey.withOpacity(0.5),
          margin: const EdgeInsets.symmetric(horizontal: 10),
        ),

      // ---------------- TOTAL COLUMN ----------------
          Column(
                    mainAxisAlignment: MainAxisAlignment.start, // top alignment
                    crossAxisAlignment: CrossAxisAlignment.start, // 👈 important: align left
                    children: [
                      Text(
                        "Total",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    // const SizedBox(height: 4),
                      Text(
                        "₹${_formatAmount(order.totalCost)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),


            _divider(),

            /// ================= BOTTOM SECTION =================
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      /// PAY → ONLY PENDING PAYMENT
                      if (isPendingPayment)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ManualPaymentScreen(
                                    totalAmount: order.totalCost,
                                    unitId: order.id,
                                    userId: order.userId,
                                    buffaloId: order.breedId,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                                                margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: const Text(
                                  "PAY NOW",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                    if (showPaymentType) ...[

                        if (isPaid)
                        GestureDetector(
                          onTap: (){
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TrackerScreen(),
                            ),
                          );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              context.tr("Track"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                     
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPaid ? Colors.green : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order.paymentType!
                              .replaceAll("_", " ")
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      /// INVOICE ONLY WHEN PAID
                      if (isPaid)
                        GestureDetector(
                          onTap: onTapInvoice,
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              context.tr("invoice"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                    ]
                  ),

                  const SizedBox(height: 6),

                  /// INFO MESSAGE
                  if (isPendingPayment || isAdminReview)
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isPendingPayment
                                ? "Cheque/Bank details in next step"
                                : "Order is under review by Admin",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= HELPERS =================

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.grey.withOpacity(0.4),
    );
  }

  Widget _valueRow(BuildContext context, String value, String label) {
    return Text(
      "$value $label",
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    );
  }

  static String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
