import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:animal_kart_demo2/utils/app_constants.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';

Widget circleButton(IconData icon, {bool isDisabled = false}) {
  return CircleAvatar(
    radius: 12,
    backgroundColor:
        isDisabled ? Colors.grey.shade400 : akBlackColor,
    child: Icon(icon, size: 18, color: Colors.white),
  );
}

Widget priceRow(BuildContext context, String titleKey, int value,
    {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.tr(titleKey),
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
  required BuildContext context,
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('price_summary'),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),

        priceRow(context, "buffalo_price", buffaloPrice),
        priceRow(context, "cpf_amount", cpfAmount),

        const Divider(height: 24),

        priceRow(context, "total_payable", total, isBold: true),
      ],
    ),
  );
}

Widget cpfExplanationCard(BuildContext context, buffalo) {
  final price = buffalo.price * 2;
  final cpf = buffalo.insurance;
  final assetValue = 10775000;
;
  final revenue10Years = 5538000;
  final breakEvenMonths = 43;
;

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

          cpfPoint(context.tr('cpf_point1')),
          cpfPoint(context.tr('cpf_point2')),

          cpfPoint(
            "${context.tr('total_investment_value')} "
            "₹${AppConstants().formatIndianAmount(price)}",
          ),

          cpfPoint(
            "${context.tr('asset_value_10_years')} "
            "₹${AppConstants().formatIndianAmount(assetValue)}",
          ),

          cpfPoint(
            "${context.tr('revenue_10_years')} "
            "₹${AppConstants().formatIndianAmount(revenue10Years)}",
          ),

          cpfPoint(
            "${context.tr('revenue_breakeven')} "
            "$breakEvenMonths ${context.tr('months')}",
          ),

          const Divider(height: 25),

          cpfPoint(
            context.tr('cpf_free_note'),
            isHighlight: true,
          ),
           cpfPoint(
            context.tr('cpf_warn_note'),
            isHighlight: true,
          ),
        ],
      ),
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

Future<void> showCpfConfirmationDialog(
    BuildContext context, Function onYesPressed) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(context.tr('confirm_without_cpf')),
        content: Text(context.tr('confirm_without_cpf_msg')),
        actions: <Widget>[
          TextButton(
            onPressed: () {
                Navigator.of(context).pop(); // Close dialog
            },
            child: Text(
              context.tr('no'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onYesPressed();
            },
            child: Text(
              context.tr('yes'),
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      );
    },
  );
}

class ExactStrikeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double strikeThickness;
  final Color strikeColor;

  const ExactStrikeText({
    super.key,
    required this.text,
    required this.style,
    this.strikeThickness = 2.2,
    this.strikeColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: TextDirection.ltr,
        )..layout();

        final textHeight = textPainter.size.height;

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            Text(text, style: style),
            Positioned(
              top: textHeight * 0.55, // 🎯 precise strike position
              left: 0,
              right: 0,
              child: Container(
                height: strikeThickness, // 🎯 exact thickness
                color: strikeColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
