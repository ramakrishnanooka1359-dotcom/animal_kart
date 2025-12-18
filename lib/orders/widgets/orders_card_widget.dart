import 'package:animal_kart_demo2/l10n/app_localizations.dart';
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
 final bool isPendingPayment =
        order.paymentStatus.toUpperCase() == "PENDING_PAYMENT";
    final bool isAdminVerificationPending = order.paymentStatus.toUpperCase() == "PENDING_ADMIN_VERIFICATION";
    final bool isPaid = order.paymentStatus.toUpperCase() == "PAID";
   final String paymentStatus = order.paymentStatus.toUpperCase();
    late final Color statusColor;
    late final String statusText;
    final bool showPaymentType =
      (isPaid || isAdminVerificationPending) &&
      order.paymentType != null;

    

    switch (paymentStatus) {
  case "PAID":
    statusColor = Colors.green;
    statusText = context.tr("paid");
    break;

  case "PENDING_ADMIN_VERIFICATION":
    statusColor = Colors.blue;
    statusText = context.tr("pending");
    break;

  case "PENDING_PAYMENT":
  default:
    statusColor = Colors.orange;
    statusText = context.tr("pending");
}

   


    

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
                    children: [
                      Text(
                        "Order Id : ${order.id}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      // Text(
                      //   "Order Placed on: ${DateUtilsHelper.formatPlacedAt(order.placedAt.toString())}",
                      //   style: const TextStyle(
                      //     fontSize: 13,
                      //     fontWeight: FontWeight.w700,
                      //   ),
                      // ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ---------------- FULL WIDTH DIVIDER ----------------
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey.withOpacity(0.4),
            ),

            /// ---------------- IMAGE + DETAILS + AMOUNT ----------------
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            _valueRow(
                              context,
                              "${order.buffaloCount}",
                              context.tr("buffalo"),
                            ),
                            const SizedBox(width: 6),
                            _valueRow(
                              context,
                              "${order.calfCount}",
                              context.tr("calf"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                            children: [
                              TextSpan(
                                text: "${order.numUnits} ",
                                style: const TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: "${context.tr("unit")} + CPF",
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "₹${_formatAmount(order.totalCost)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            /// ---------------- DIVIDER BELOW IMAGE ----------------
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.grey.withOpacity(0.4),
            ),

            /// ---------------- INFO + BUTTONS ----------------
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isPendingPayment)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Pending Payment",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    if (isPendingPayment)
                  GestureDetector(
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
                      child: const Text(
                        "PAY",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                    if (showPaymentType) ...[
                      /// PAYMENT TYPE CHIP (VISIBLE FOR PAID + ADMIN VERIFICATION)
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
                    const SizedBox(width: 6),
                      if (isAdminVerificationPending)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF7E57C2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Admin Verification Pending",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                    ],
                  ),
                  const SizedBox(height: 6),

                  if (isPendingPayment || isAdminVerificationPending)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isPendingPayment
                                ? "Please fill the form with cheque or bank details to complete payment"
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

  /// ---------------- VALUE + LABEL
  Widget _valueRow(BuildContext context, String value, String label) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        children: [
          TextSpan(
            text: "$value ",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: label,
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  static String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
