import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:animal_kart_demo2/utils/app_constants.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';


Widget circleButton(IconData icon, {bool isDisabled = false}) {
  return CircleAvatar(
    radius: 12,
    backgroundColor:
        isDisabled ? Colors.grey.shade400 : akBlackColor,
    child: Icon(icon, size: 18, color: Colors.white),
  );
}


Widget priceRow(String title, int value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          "₹${AppConstants().formatIndianAmount(value)}",
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 18 : 15,
          ),
        ),
      ],
    ),
  );
}


Widget priceExplanation({
  required buffalo,
  required int units,
  required int insuranceUnits,
  required int buffaloPrice,
  required int cpfAmount,
  required int total,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFFAFDF6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFB2E3A8)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        "Price Summary",
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 12),
      priceRow("Buffalo Price", buffaloPrice),
      priceRow("CPF Amount", cpfAmount),
      const Divider(height: 24),
      priceRow("Total Payable", total, isBold: true),
    ]),
  );
}


Widget cpfExplanationCard(buffalo) {
  final price = buffalo.price * 2;
  final cpf = buffalo.insurance;
  final assetValue = 6396000;
  final revenue10Years = 7407000;
  final breakEvenMonths = 34;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFFF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryGreen),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          "CPF Offer (Cattle Protection Fund)",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        cpfPoint("1 Unit Purchase gives you ✅ 2 Buffaloes + 2 Calves"),
         cpfPoint("1 Unit CPF (cattle protection fund) costs ₹26000"),

        cpfPoint(
          "Total Investment Value: ₹${AppConstants().formatIndianAmount(price)}",
        ),

        cpfPoint(
          "After 10 years, Expected Asset Market Value: ₹${AppConstants().formatIndianAmount(assetValue)}",
        ),

        cpfPoint(
          "After 10 years, Expected Milk Revenue: ₹${AppConstants().formatIndianAmount(revenue10Years)}",
        ),

        cpfPoint(
          "Your Revenue Break-even will be achieved within $breakEvenMonths months",
        ),

        const Divider(height: 25),

        cpfPoint(
          "For every purchase of 1 unit (2 Murrah buffaloes), the CPF for the second buffalo is provided completely free for a full duration of 1 year.",
          isHighlight: true,
        ),
      ]),
    ),
  );
}


Widget cpfPoint(String text, {bool isHighlight = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(
          Icons.check_circle,
          size: 18,
          color: isHighlight ? kPrimaryGreen : Colors.grey,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight:
                  isHighlight ? FontWeight.w700 : FontWeight.w500,
              color: isHighlight ? kPrimaryGreen : Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}


Future<void> showCpfConfirmationDialog(BuildContext context, Function onYesPressed) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm without CPF"),
          content: const Text("Are you sure you want to proceed without CPF? This may affect your insurance coverage."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text(
                "No",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                onYesPressed(); // Execute the payment action
              },
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }