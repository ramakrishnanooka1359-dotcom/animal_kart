import 'package:animal_kart_demo2/buffalo/widgets/payment_summary.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CpfSelectionWidget extends StatelessWidget {
  final dynamic buffalo;
  final int quantity;
  final bool isCpfSelected;
  final double units;
  final String unitText;
  final int cpfUnitsToPay;
  final int freeCpfUnits;
  final int buffaloPrice;
  final int cpfAmount;
  final int totalAmount;
  final Function(bool) onCpfSelectionChanged;

  const CpfSelectionWidget({
    super.key,
    required this.buffalo,
    required this.quantity,
    required this.isCpfSelected,
    required this.units,
    required this.unitText,
    required this.cpfUnitsToPay,
    required this.freeCpfUnits,
    required this.buffaloPrice,
    required this.cpfAmount,
    required this.totalAmount,
    required this.onCpfSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cpfPerBuffalo = buffalo.insurance;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F8FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isCpfSelected,
                    onChanged: null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr("includeCpf"),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isCpfSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),

              if (isCpfSelected) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                
                _buildCpfDetailRow(
                  context.tr("totalBuffaloes"),
                  "$quantity ${quantity == 1 
                    ? context.tr("buffalo") 
                    : context.tr("buffaloes")}",
                ),
                _buildCpfDetailRow(
                  context.tr("units"),
                  units.toStringAsFixed(1),
                ),
                _buildCpfDetailRow(
                  "${context.tr("Free CPF discount")} "
                  "($freeCpfUnits ${freeCpfUnits == 1 ? 'unit' : 'units'})",
                  "- ₹${freeCpfUnits * cpfPerBuffalo}",
                  valueColor: Colors.orange,
                ),
                _buildCpfDetailRow(
                  "${context.tr("CPF for")} ${units.toStringAsFixed(1)} $unitText",
                  "₹$cpfAmount",
                ),
                const SizedBox(height: 4),
                const Divider(thickness: 1.5),
                const SizedBox(height: 4),
                _buildCpfDetailRow(
                  context.tr("Total CPF Cost"),
                  "₹$cpfAmount",
                  valueColor: kPrimaryDarkColor,
                  isBold: true,
                ),
              ],
            ],
          ),
        ),

        if (isCpfSelected) ...[
          const SizedBox(height: 16),
          PaymentSummary(
            buffalo: buffalo,
            quantity: quantity,
            units: units,
            unitText: unitText,
            buffaloPrice: buffaloPrice,
            cpfAmount: cpfAmount,
            totalAmount: totalAmount,
            cpfUnitsToPay: cpfUnitsToPay,
            freeCpfUnits: freeCpfUnits,
          ),
        ],
      ],
    );
  }

  Widget _buildCpfDetailRow(
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
}