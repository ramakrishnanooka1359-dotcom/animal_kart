import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class InsuranceSheet extends StatelessWidget {
  final int price;
  final int insurance;
  final bool showCancelIcon;
  final bool showNote;
  final bool isDragShowIcon;

  const InsuranceSheet({
    Key? key,
    required this.price,
    required this.insurance,
    this.showCancelIcon = true,
    this.showNote = true,
    this.isDragShowIcon = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int row1Total = price + insurance;
    final int row2Total = price;
    final int grandTotal = row1Total + row2Total;

    TextStyle headerStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle

          if (isDragShowIcon)
            
                Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
            ),
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr("CPF (Cattle Protection Fund) Offer"),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),

              if (showCancelIcon)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.black12,
                    child: Icon(Icons.close, color: Colors.black),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Insurance Table
          _buildInsuranceTable(
            context,
            price,
            insurance,
            row1Total,
            row2Total,
            headerStyle,
          ),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFDFF7ED),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Grand Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text(
                  grandTotal.toString(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                ),
              ],
            ),
          ),

          // Optional Note
          if (showNote)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color(0xFFEFFFF7)
                    : const Color(0xFF1F3B4D),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                context.tr("insurance_note"),
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ),

          const SizedBox(height: 5),

          // Grand Total Section
          

          
        ],
      ),
    );
  }

  Widget _buildInsuranceTable(
    BuildContext context,
    int price,
    int insurance,
    int row1Total,
    int row2Total,
    TextStyle headerStyle,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF10B981), width: 1),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFDFF7ED),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Expanded(child: Text(context.tr("S.No"), style: headerStyle)),
                Expanded(child: Text(context.tr("Price"), style: headerStyle)),
                Expanded(child: Text(context.tr("Insurance"), style: headerStyle, textAlign: TextAlign.right)),
                Expanded(child: Text(context.tr("Total"), style: headerStyle, textAlign: TextAlign.right)),
              ],
            ),
          ),

          // Row 1
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            color: const Color(0xFF10B981),
            child: Row(
              children: [
                const Expanded(child: Text("1", style: TextStyle(fontSize: 14, color: Colors.white))),
                Expanded(child: Text(price.toString(), style: const TextStyle(fontSize: 14, color: Colors.white))),
                Expanded(child: Text(insurance.toString(), textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, color: Colors.white))),
                Expanded(child: Text(row1Total.toString(), textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, color: Colors.white))),
              ],
            ),
          ),

          // Row 2
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF4FFFA),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Expanded(child: Text("2", style: TextStyle(fontSize: 14))),
                Expanded(child: Text(price.toString(), style: const TextStyle(fontSize: 14))),

                // Strike-through insurance value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        insurance.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        context.tr("Free"),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Total (price only)
                Expanded(
                  child: Text(
                    row2Total.toString(),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
