import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';

class PaymentSummary extends StatelessWidget {
  final dynamic buffalo;
  final int quantity;
  final double units;
  final String unitText;
  final int buffaloPrice;
  final int cpfAmount;
  final int totalAmount;
  final int cpfUnitsToPay;
  final int freeCpfUnits;

  const PaymentSummary({
    super.key,
    required this.buffalo,
    required this.quantity,
    required this.units,
    required this.unitText,
    required this.buffaloPrice,
    required this.cpfAmount,
    required this.totalAmount,
    required this.cpfUnitsToPay,
    required this.freeCpfUnits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryGreen.withValues(alpha:0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: kPrimaryGreen.withValues(alpha:0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr("Total Price Summary"),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationThickness: 2,
            ),
          ),
          const SizedBox(height: 16),

          _buildDetailRow(
            "${units.toStringAsFixed(1)} $unitText ${context.tr("Price")}",
            "₹$buffaloPrice",
          ),
          _buildDetailRow(
            "${units.toStringAsFixed(1)} $unitText ${context.tr("CPF Cost")}",
            "₹$cpfAmount",
          ),
          const SizedBox(height: 12),
          const Divider(thickness: 2),
          const SizedBox(height: 12),
          _buildDetailRow(
            context.tr("Total Price"),
            "₹$totalAmount",
            valueColor: kPrimaryGreen,
            isBold: true,
            fontSize: 19,
          ),

          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.symmetric(vertical: 2),
            title: Text(
              context.tr("More Details"),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Buffalo Price Breakdown:",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCalculationRow(
                      "Number of Buffaloes",
                      "$quantity",
                    ),
                    _buildCalculationRow(
                      "Price per Buffalo",
                      "₹${buffalo.price}",
                    ),
                    _buildCalculationRow(
                      "Total Buffalo Price",
                      "₹${buffalo.price} × $quantity = ₹$buffaloPrice",
                      isBold: true,
                      valueColor: Colors.blue.shade700,
                    ),
                    
                    const Divider(height: 20),
                    
                    Text(
                      "CPF Breakdown:",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCalculationRow(
                      "Total Units",
                      "${units.toStringAsFixed(1)} ($quantity buffaloes × 0.5)",
                    ),
                    _buildCalculationRow(
                      "CPF per Unit",
                      "₹${buffalo.insurance}",
                    ),
                    _buildCalculationRow(
                      "CPF Units to Pay",
                      "$quantity ${quantity == 1 ? 'buffalo' : 'buffaloes'}",
                    ),
                    _buildCalculationRow(
                      "Free CPF",
                      "$freeCpfUnits ${freeCpfUnits == 1 ? 'unit' : 'units'} "
                      "(₹${freeCpfUnits * buffalo.insurance})",
                      valueColor: Colors.orange,
                    ),
                    _buildCalculationRow(
                      "Total CPF Cost",
                      "₹${buffalo.insurance} × $cpfUnitsToPay = ₹$cpfAmount",
                      isBold: true,
                      valueColor: Colors.orange.shade700,
                    ),
                    
                    const Divider(height: 20),
                    
                    _buildCalculationRow(
                      "Grand Total",
                      "₹$buffaloPrice + ₹$cpfAmount = ₹$totalAmount",
                      isBold: true,
                      valueColor: kPrimaryGreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: valueColor ?? kPrimaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}