import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Function(int) onQuantityChanged;
  final int buffaloPrice;
  final double units;
  final String unitText;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    required this.buffaloPrice,
    required this.units,
    required this.unitText,
  });

  @override
  Widget build(BuildContext context) {
    final totalBuffaloes = quantity;
    final totalCalves = quantity;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryGreen, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr("selectQuantity"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                context.tr("maxBuffaloes"),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${context.tr("Quantity")}: $quantity",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$totalBuffaloes ${totalBuffaloes == 1 
                      ? context.tr("buffalo") 
                      : context.tr("buffaloes")}, "
                    "$totalCalves ${totalCalves == 1 
                      ? context.tr("calf") 
                      : context.tr("calves")}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                     "${units.toStringAsFixed(1)} $unitText",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color:kPrimaryGreen,
                      letterSpacing: 0.5
                    ),
                  ),
                  
                ],
              ),
              
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: quantity > 1
                          ? () => onQuantityChanged(quantity - 1)
                          : null,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: quantity > 1 
                            ? Colors.black 
                            : Colors.grey.shade400,
                        child: const Icon(
                          Icons.remove,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "$quantity",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: quantity < 20
                          ? () => onQuantityChanged(quantity + 1)
                          : null,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: quantity < 20 
                            ? Colors.black 
                            : Colors.grey.shade400,
                        child: const Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
           Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '* ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryGreen,
                  height: 1.4,
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: 'Free '),
                      TextSpan(
                        text: '1-year CPF coverage',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: kPrimaryGreen,
                        ),
                      ),
                      TextSpan(text: ' for 2nd buffalo with each unit'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 5),
          const Divider(),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${context.tr("buffaloPrice")} :",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                "₹$buffaloPrice",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${context.tr("totalPrice")} ($buffaloPrice X $quantity) :",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                "₹${buffaloPrice * quantity}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}