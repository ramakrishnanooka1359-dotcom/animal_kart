import 'package:animal_kart_demo2/buffalo/widgets/custom_buffalo_details.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class InsuranceSheet extends StatelessWidget {
  final int price;
  final int insurance;
  final bool showCancelIcon;
  final bool showNote;
  final bool isDragShowIcon;

  const InsuranceSheet({
    super.key,
    required this.price,
    required this.insurance,
    this.showCancelIcon = true,
    this.showNote = true,
    this.isDragShowIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    final int row1Total = price + insurance;
    final int row2Total = price;
    final int grandTotal = row1Total + row2Total;

    final TextStyle headerStyle = TextStyle(
      fontSize: isSmallScreen ? 12 : 14,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// DRAG HANDLE
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

              /// HEADER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr("CPF (Cattle Protection Fund) Offer"),
                      maxLines: 2,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

              const SizedBox(height: 16),

              /// INSURANCE TABLE
              _buildInsuranceTable(
                context,
                price,
                insurance,
                row1Total,
                row2Total,
                headerStyle,
              ),

              const SizedBox(height: 12),

              /// GRAND TOTAL
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFDFF7ED),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr("grandTotal"),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      grandTotal.toString(),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              /// NOTE
              if (showNote) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFFFF7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    context.tr("insurance_note"),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// ===================== TABLE =====================
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
        border: Border.all(color: const Color(0xFF10B981)),
      ),
      child: Column(
        children: [
          /// HEADER
          _tableRow(
            context,
            isHeader: true,
            bgColor: const Color(0xFFDFF7ED),
            children: [
              _cell(context.tr("S.No"), headerStyle),
              _cell(context.tr("Price"), headerStyle),
              _cell(context.tr("CPF"), headerStyle, center: true),
              _cell(context.tr("Total"), headerStyle, right: true),
            ],
          ),

          /// ROW 1
          _tableRow(
            context,
            bgColor: const Color(0xFF10B981),
            children: [
              _cell("1", const TextStyle(color: Colors.white)),
              _cell(price.toString(), const TextStyle(color: Colors.white)),
              _cell(
                insurance.toString(),
                const TextStyle(color: Colors.white),
                center: true,
              ),
              _cell(
                row1Total.toString(),
                const TextStyle(color: Colors.white),
                right: true,
              ),
            ],
          ),

          /// ROW 2 (STRIKE + FREE)
          _tableRow(
            context,
            isLast: true,
            bgColor: const Color(0xFFF4FFFA),
            children: [
              _cell("2", const TextStyle(color: Colors.black)),
              _cell(price.toString(), const TextStyle(color: Colors.black)),
             Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ExactStrikeText(
                          text: "₹$insurance",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          strikeThickness: 2.2,
                          strikeColor: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr("Free"),
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _cell(
                row2Total.toString(),
                const TextStyle(color: Colors.black),
                right: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ===================== CELL =====================
        Widget _cell(
          String text,
          TextStyle style, {
          bool center = false,
          bool right = false,
        }) {
          return Expanded(
            child: Align(
              alignment: center
                  ? Alignment.center
                  : right
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(text, style: style),
              ),
            ),
          );
        }

      Widget _tableRow(
        BuildContext context, {
        required List<Widget> children,
        bool isHeader = false,
        bool isLast = false,
        Color bgColor = Colors.transparent,
      }) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: isHeader
                ? const BorderRadius.vertical(top: Radius.circular(18))
                : isLast
                    ? const BorderRadius.vertical(bottom: Radius.circular(18))
                    : BorderRadius.zero,
          ),
          child: Row(children: children),
        );
      }
    }
