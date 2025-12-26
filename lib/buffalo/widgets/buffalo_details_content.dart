import 'package:animal_kart_demo2/buffalo/widgets/buffalo_image_slider.dart';
import 'package:animal_kart_demo2/buffalo/widgets/custom_buffalo_details.dart';
import 'package:animal_kart_demo2/buffalo/widgets/quantity_selector.dart';
import 'package:animal_kart_demo2/buffalo/widgets/cpf_selection_widget.dart';
import 'package:animal_kart_demo2/buffalo/widgets/insurance_sheet.dart';
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
            quantity: quantity,
            showCancelIcon: false,
            showNote: false,
            isDragShowIcon: false,
          ),
          
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
            cpfExplanationCard(context,buffalo),
        ],
      ),
    );
  }

  
}