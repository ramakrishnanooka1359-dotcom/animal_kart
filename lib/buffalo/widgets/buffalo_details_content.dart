import 'package:animal_kart_demo2/buffalo/widgets/buffalo_image_slider.dart';
import 'package:animal_kart_demo2/buffalo/widgets/custom_buffalo_details.dart';
import 'package:animal_kart_demo2/buffalo/widgets/quantity_selector.dart';
import 'package:animal_kart_demo2/buffalo/widgets/cpf_selection_widget.dart';
import 'package:animal_kart_demo2/buffalo/widgets/insurance_sheet.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class BuffaloDetailsContent extends StatelessWidget {
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
  final Function(int) onQuantityChanged;
  final Function(bool) onCpfSelectionChanged;
  final PageController pageController;
  final int currentIndex;
  final Function(int) onPageChanged;

  const BuffaloDetailsContent({
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
    required this.onQuantityChanged,
    required this.onCpfSelectionChanged,
    required this.pageController,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 180),
      child: Column(
        children: [
          BuffaloImageSlider(
            images: buffalo.buffaloImages,
            pageController: pageController,
            currentIndex: currentIndex,
            onPageChanged: onPageChanged,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              buffalo.description,
              style: const TextStyle(fontSize: 17, height: 1.5),
            ),
          ),
          
          QuantitySelector(
            quantity: quantity,
            onQuantityChanged: onQuantityChanged,
            buffaloPrice: buffalo.price,
            units: units,
            unitText: unitText,
          ),
          
          const SizedBox(height: 14),
          InsuranceSheet(
            price: buffalo.price,
            insurance: buffalo.insurance,
            showCancelIcon: false,
            showNote: false,
            isDragShowIcon: false,
          ),
          
          const SizedBox(height: 14),
           cpfExplanationCard(context,buffalo),
          const SizedBox(height: 18),
          CpfSelectionWidget(
            buffalo: buffalo,
            quantity: quantity,
            isCpfSelected: isCpfSelected,
            units: units,
            unitText: unitText,
            cpfUnitsToPay: cpfUnitsToPay,
            freeCpfUnits: freeCpfUnits,
            buffaloPrice: buffaloPrice,
            cpfAmount: cpfAmount,
            totalAmount: totalAmount,
            onCpfSelectionChanged: onCpfSelectionChanged,
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildCpfExplanationCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                context.tr("cpfNote"),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.tr("cpfInfo"),
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}