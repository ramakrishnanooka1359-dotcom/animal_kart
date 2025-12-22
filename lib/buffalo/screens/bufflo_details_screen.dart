import 'dart:async';
import 'package:animal_kart_demo2/buffalo/providers/buffalo_details_provider.dart';
import 'package:animal_kart_demo2/buffalo/widgets/custom_buffalo_details.dart';
import 'package:animal_kart_demo2/buffalo/widgets/insurance_sheet.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/services/razorpay_service.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/widgets/payment_widgets/successful_screen.dart';
import 'package:animal_kart_demo2/buffalo/providers/unit_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuffaloDetailsScreen extends ConsumerStatefulWidget {
  final String buffaloId;

  const BuffaloDetailsScreen({super.key, required this.buffaloId});

  @override
  ConsumerState<BuffaloDetailsScreen> createState() =>
      _BuffaloDetailsScreenState();
}

class _BuffaloDetailsScreenState extends ConsumerState<BuffaloDetailsScreen> {
  int quantity = 2; // Number of buffaloes selected
  bool isCpfSelected = true;
  
  
  double get units => quantity * 0.5;
  String get unitText {
  return units <= 1 ? context.tr("unit") : context.tr("units");
}

  
  int get cpfUnitsToPay {
    if (!isCpfSelected) return 0;
    
    if (quantity.isEven) {
      
      return quantity ~/ 2;
    } else {
      // Odd number: ceil(quantity/2)
      return (quantity / 2).ceil();
    }
  }
  
  // Calculate free CPF units
  int get freeCpfUnits {
    if (!isCpfSelected) return 0;
    
    if (quantity.isEven) {
      // Even number: get 1 free CPF per unit
      return quantity ~/ 2;
    } else {
      // Odd number: floor(quantity/2) free
      return quantity ~/ 2;
    }
  }

  // Calculate total CPF cost for backend
  int get totalCpfCostForBackend {
    if (!isCpfSelected) return 0;
    return cpfUnitsToPay * 13000; // buffalo.insurance is 13000
  }

  // Calculate base unit cost for backend (175000 × quantity)
  int get baseUnitCostForBackend {
    return quantity * 175000; // buffalo.price is 175000
  }

  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.delayed(const Duration(seconds: 3), autoScroll);
  }

  void autoScroll() {
    if (!mounted) return;
    final buffaloAsync = ref.read(buffaloDetailsProvider(widget.buffaloId));
    if (!buffaloAsync.hasValue) return;

    final list = buffaloAsync.value!.buffaloImages;
    int nextPage = currentIndex + 1;
    if (nextPage >= list.length) nextPage = 0;

    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 3), autoScroll);
  }

  @override
  Widget build(BuildContext context) {
    final buffaloAsync = ref.watch(buffaloDetailsProvider(widget.buffaloId));

    return buffaloAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        body: Center(child: Text("${context.tr("error")}: $err")),
      ),
      data: (buffalo) {
        // Calculate costs
        final totalBuffaloes = quantity; // Number of buffaloes
        final totalCalves = quantity; // Number of calves (1 calf per buffalo)
        final buffaloPrice = totalBuffaloes * buffalo.price; // Price for buffaloes only
        final cpfAmount = cpfUnitsToPay * buffalo.insurance;
        final totalAmount = buffaloPrice + cpfAmount;

        return Scaffold(
          backgroundColor: Theme.of(context).mainThemeBgColor,
          appBar: AppBar(
            backgroundColor: Colors.grey.shade200,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Theme.of(context).primaryTextColor,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              context.tr("buffaloDetails"),
              style: const TextStyle(
                color: kPrimaryDarkColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          bottomNavigationBar: _paymentSection(context, buffalo, totalAmount),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 180),
            child: Column(
              children: [
                _imageSlider(buffalo),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    buffalo.description,
                    style: const TextStyle(fontSize: 17, height: 1.5),
                  ),
                ),
                
                // Quantity selector section
                _quantitySelectorSection(context, buffalo),
                
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
                _cpfCheckboxAndSelector(buffalo),
                const SizedBox(height: 18),
                
               
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quantitySelectorSection(BuildContext context, buffalo) {
    final totalBuffaloes = quantity;
    final totalCalves = quantity;
    final unitsValue = quantity * 0.5;
    final baseUnitCost = buffalo.price; // 175000 per buffalo

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kPrimaryGreen, 
          width: 1.5, 
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
          
          // Quantity counter with buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity information
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

                    //"${context.tr("units")}: ${units.toStringAsFixed(1)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              
              // Increase/Decrease buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Decrease button
                    GestureDetector(
                      onTap: quantity > 1
                          ? () {
                              setState(() {
                                quantity--;
                              });
                            }
                          : null,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: quantity > 1 ? akBlackColor : Colors.grey.shade400,
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
                    // Increase button
                    GestureDetector(
                      onTap: quantity < 20
                          ? () {
                              setState(() {
                                quantity++;
                              });
                            }
                          : null,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: quantity < 20 ? akBlackColor : Colors.grey.shade400,
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
          
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          
          // Price display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${context.tr("buffaloPrice")} :",


                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                "₹${buffalo.price}",
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
                "${context.tr("totalPrice")} (${buffalo.price} X $quantity) :",

               
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                "₹${buffalo.price * quantity}",
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

  Widget _imageSlider(buffalo) {
    final imageList = buffalo.buffaloImages;

    return Container(
      color: Colors.grey.shade200,
      height: 320,
      child: PageView.builder(
        controller: _pageController,
        itemCount: imageList.length,
        onPageChanged: (idx) => setState(() => currentIndex = idx),
        itemBuilder: (_, index) {
          final img = imageList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(img, fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }

  Widget _cpfCheckboxAndSelector(buffalo) {
  final cpfPerBuffalo = buffalo.insurance; // This should be 13000
  final totalCpf = cpfUnitsToPay * cpfPerBuffalo;
  final totalBuffaloes = quantity;
  final baseUnitCost = buffalo.price * quantity; // Total buffalo price

  return Column(
    children: [
      // CPF Container
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
            // Checkbox for CPF selection
            Row(
              children: [
                Checkbox(
                  value: isCpfSelected,
                  onChanged: null, 
                  // onChanged: (value) {
                  //   setState(() {
                  //     isCpfSelected = value ?? false;
                  //   });
                  // },
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

            // Only show CPF details if checkbox is selected
            if (isCpfSelected) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),

              // CPF Breakdown Section
              
              _cpfDetailRow(
                context.tr("totalBuffaloes"),
                "$totalBuffaloes ${totalBuffaloes == 1 ? context.tr("buffalo") : context.tr("buffaloes")}",
              ),

              _cpfDetailRow(
                context.tr("units"),
                "${units.toStringAsFixed(1)}",
              ),

              _cpfDetailRow(
                "${context.tr("Free CPF discount")} (${freeCpfUnits} ${freeCpfUnits == 1 ? 'unit' : 'units'})",
                "- ₹${freeCpfUnits * cpfPerBuffalo}",
                valueColor: Colors.orange,
              ),

              _cpfDetailRow(
                  "${context.tr("CPF for")} ${units.toStringAsFixed(1)} $unitText",

                //"${context.tr("CPF for")} ${units.toStringAsFixed(1)} ${units == 1 ? 'unit' : 'units'}",
                "₹${totalCpf}",
              ),

              const SizedBox(height: 4),
              const Divider(thickness: 1.5),
              const SizedBox(height: 4),
              _cpfDetailRow(
                context.tr("Total CPF Cost"),
                "₹${totalCpf}",
                valueColor: kPrimaryDarkColor,
                isBold: true,
              ),
            ],
          ],
        ),
      ),

      // Total Price Summary Container (Separate)
      if (isCpfSelected) ...[
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPrimaryGreen.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: kPrimaryGreen.withOpacity(0.1),
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

              _cpfDetailRow(
                "${units.toStringAsFixed(1)} $unitText ${context.tr("Price")}",

              //  "${units.toStringAsFixed(1)} ${units == 1 ? 'Unit' : 'Units'} ${context.tr("Price")}",
                "₹${baseUnitCost}",
              ),

              _cpfDetailRow(
                "${units.toStringAsFixed(1)} $unitText ${context.tr("CPF Cost")}",

               // "${units.toStringAsFixed(1)} ${units == 1 ? 'Unit' : 'Units'} ${context.tr("CPF Cost")}",
                "₹${totalCpf}",
              ),

              const SizedBox(height: 12),
              const Divider(thickness: 2),
              const SizedBox(height: 12),

              _cpfDetailRow(
                context.tr("Total Price"),
                "₹${baseUnitCost + totalCpf}",
                valueColor: kPrimaryGreen,
                isBold: true,
                fontSize: 19,
              ),

              // More Details Section
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
                        // Buffalo Price Breakdown
                        Text(
                          "Buffalo Price Breakdown:",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _detailCalculationRow(
                          "Number of Buffaloes",
                          "$quantity",
                        ),
                        _detailCalculationRow(
                          "Price per Buffalo",
                          "₹${buffalo.price}",
                        ),
                        _detailCalculationRow(
                          "Total Buffalo Price",
                          "₹${buffalo.price} × $quantity = ₹${baseUnitCost}",
                          isBold: true,
                          valueColor: Colors.blue.shade700,
                        ),
                        
                        const Divider(height: 20),
                        
                        // CPF Breakdown
                        Text(
                          "CPF Breakdown:",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _detailCalculationRow(
                          "Total Units",
                          "${units.toStringAsFixed(1)} ($quantity buffaloes × 0.5)",
                        ),
                        _detailCalculationRow(
                          "CPF per Unit",
                          "₹${cpfPerBuffalo}",
                        ),
                        _detailCalculationRow(
                          "CPF Units to Pay",
                          "$quantity ${quantity == 1 ? 'buffalo' : 'buffaloes'}",
                        ),
                        _detailCalculationRow(
                          "Free CPF",
                          "$freeCpfUnits ${freeCpfUnits == 1 ? 'unit' : 'units'} (₹${freeCpfUnits * cpfPerBuffalo})",
                          valueColor: Colors.orange,
                        ),
                        _detailCalculationRow(
                          "Total CPF Cost",
                          "₹${cpfPerBuffalo} × $cpfUnitsToPay = ₹${totalCpf}",
                          isBold: true,
                          valueColor: Colors.orange.shade700,
                        ),
                        
                        const Divider(height: 20),
                        
                        // Grand Total
                        _detailCalculationRow(
                          "Grand Total",
                          "₹${baseUnitCost} + ₹${totalCpf} = ₹${baseUnitCost + totalCpf}",
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
        ),
      ],
    ],
  );
}

Widget _cpfDetailRow(
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

Widget _detailCalculationRow(
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

  Widget _paymentSection(BuildContext context, buffalo, int totalAmount) {
    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 55,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (!isCpfSelected) {
                  showCpfConfirmationDialog(context, () {
                    _processOnlinePayment(totalAmount);
                  });
                } else {
                  _processOnlinePayment(totalAmount);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: Text(
                context.tr("onlinePayment"),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 55,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (!isCpfSelected) {
                  showCpfConfirmationDialog(context, () {
                    _handleManualPayment(buffalo);
                  });
                } else {
                  _handleManualPayment(buffalo);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: Text(
                context.tr("manualPayment"),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processOnlinePayment(int totalAmount) {
    final razorpay = RazorPayService(
      onPaymentSuccess: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BookingSuccessScreen()),
        );
      },
      onPaymentFailed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr("paymentFailed"))),
        );
      },
    );

    razorpay.openPayment(amount: totalAmount);
  }

  Future<void> _handleManualPayment(buffalo) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final userMobile = prefs.getString('userMobile');

      if (userMobile == null) {
        Navigator.pop(context);
        showToast(context.tr("userMobileNotFound"));
        return;
      }

      // Calculate costs according to CORRECT structure
      final baseUnitCost = buffalo.price * quantity; // 175000 × quantity
      final cpfUnitCost = isCpfSelected ? (cpfUnitsToPay * buffalo.insurance) : 0;

      // Prepare payload according to CORRECT structure
      final payload = {
        "userId": userMobile,
        "breedId": buffalo.id,
        "numUnits": units, // Send calculated units (quantity × 0.5)
        "paymentMode": "MANUAL_PAYMENT",
        "baseUnitCost": baseUnitCost, // 175000 × quantity
        "cpfUnitCost": cpfUnitCost, // 13000 × cpfUnitsToPay
      };
      
      debugPrint("Manual Payment Request Payload: $payload");

      final response = await ref
          .read(unitProvider)
          .createUnit(payload: payload);

      if (!mounted) return;
      Navigator.pop(context);

      if (response != null) {
        showToast(
          "${context.tr("orderPlaced")} ${context.tr("orderId")}: ${response.id}",
        );

        Navigator.pushReplacementNamed(context, AppRouter.home, arguments: 1);
      } else {
        showToast(context.tr("orderFailed"));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showToast("${context.tr("errorOccurred")}: $e");
        debugPrint("Manual payment error: $e");
      }
    }
  }

  void showCpfConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(context.tr("noCpfSelected")),
        content: Text(context.tr("cpfWarning")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr("no")),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(context.tr("yes")),
          ),
        ],
      ),
    );
  }


Widget _priceSummaryRow(
  String label,
  String value, {
  bool isBold = false,
  bool isTotal = false,
  bool isInfo = false,
  bool showStrikethrough = false,
  Color? valueColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isBold || isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? kPrimaryDarkColor : Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 17 : 14,
            fontWeight: isBold || isTotal ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? (isTotal ? kPrimaryGreen : Colors.black87),
            decoration: showStrikethrough ? TextDecoration.lineThrough : null,
            decorationColor: Colors.red,
            decorationThickness: 2,
          ),
        ),
      ],
    ),
  );
}
}




