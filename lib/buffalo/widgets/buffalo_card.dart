import 'package:animal_kart_demo2/buffalo/widgets/insurance_sheet.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/buffalo.dart';

class BuffaloCard extends ConsumerWidget {
  final Buffalo buffalo;

  const BuffaloCard({super.key, required this.buffalo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disabled = !buffalo.inStock;
    // final cart = ref.watch(cartProvider);
    // final isInCart = cart.containsKey(buffalo.id);

    final String firstImage = buffalo.buffaloImages.first;
    final bool isNetwork = firstImage.startsWith("http");

    return GestureDetector(
      onTap: disabled
          ? null
          : () {
              Navigator.pushNamed(
                context,
                AppRouter.buffaloDetails,
                arguments: {'buffaloId': buffalo.id},
              );
            },
      child: Opacity(
        opacity: disabled ? 0.4 : 1,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).lightThemeCardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                offset: const Offset(0, 4),
                color: Colors.black.withOpacity(0.06),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: isNetwork
                        ? Image.network(
                            firstImage,
                            height: 190,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            firstImage,
                            height: 190,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),

                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: buffalo.inStock
                            ? akWhiteColor
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        buffalo.inStock
                            ? context.tr("Available")
                            : context.tr("Out of Stock"),
                        style: TextStyle(
                          color: buffalo.inStock ? kPrimaryGreen : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                buffalo.breed,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_drink,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${buffalo.milkYield}${context.tr("L")}/${context.tr("day")}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        OutlinedButton.icon(
                          onPressed: () => _showInsuranceInfo(
                            context,
                            buffalo.price,
                            buffalo.insurance,
                          ),
                          icon: const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.black,
                          ),
                          label: Text(
                            context.tr("CPF "),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Theme.of(context).isLightTheme
                                ? Color(0xFFF9FAFB)
                                : akLightBlueCardLightColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            side: BorderSide.none,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    const Divider(
                      color: Colors.greenAccent,
                      thickness: 0.3,
                      height: 10,
                    ),

                    const SizedBox(height: 5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price Text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr("Price"),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "₹${buffalo.price}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.buffaloDetails,
                              arguments: {'buffaloId': buffalo.id},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                          ),
                          child: Text(
                            "View Details",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
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
      ),
    );
  }

  // ===================== SHOW INSURANCE MODAL =====================
  void _showInsuranceInfo(BuildContext context, int price, int insurance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).mainThemeBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => InsuranceSheet(
      price: price,
      insurance: insurance,
      showCancelIcon:true,
      showNote:true,
      isDragShowIcon:true

    ),
    );
  }

  
  
}


