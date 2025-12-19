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
  int units = 1;
  bool isCpfSelected = true;
  

  int get insuranceUnits => isCpfSelected ? units : 0;

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

     // error: (err, _) => Scaffold(body: Center(child: Text("Error: $err"))),
      data: (buffalo) {
        final buffaloCount = units * 2;
        final buffaloPrice = buffaloCount * buffalo.price;
        final cpfAmount = insuranceUnits * buffalo.insurance;
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
                
                // Unit selector section
                _unitSelectorSection(context, buffalo),
                
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
                
                priceExplanation(
                  context: context,
                  buffalo: buffalo,
                  units: units,
                  insuranceUnits: insuranceUnits,
                  buffaloPrice: buffaloPrice,
                  cpfAmount: cpfAmount,
                  total: totalAmount,
                ),
                
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _unitSelectorSection(BuildContext context, buffalo) {
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
                context.tr("selectUnits"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                context.tr("maxUnits"),

                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Unit counter with buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Unit information
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${context.tr("units")}: $units",
                    
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${context.tr("buffaloes")}: ${units * 2} (2 ${context.tr("calves")})",

                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
                      onTap: units > 1
                          ? () {
                              setState(() {
                                units--;
                              });
                            }
                          : null,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: units > 1 ? akBlackColor : Colors.grey.shade400,
                        child: Icon(
                          Icons.remove,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "$units",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Increase button
                    GestureDetector(
                      onTap: units < 10
                          ? () {
                              setState(() {
                                units++;
                              });
                            }
                          : null,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: units < 10 ? akBlackColor : Colors.grey.shade400,
                        child: Icon(
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
                "${context.tr("pricePerUnit")}:",


                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                "₹${buffalo.price * 2}",
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
              "${context.tr("totalBuffaloPrice")}:",

                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                "₹${buffalo.price * 2 * units}",
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
    final totalCpf = insuranceUnits * cpfPerBuffalo;
    final totalBuffaloes = units * 2;
    final freeCpfUnits = units; // 1 free CPF per unit

    return Container(
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
                onChanged: (value) {
                  setState(() {
                    isCpfSelected = value ?? false;
                  });
                },
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

Text(
  context.tr("cpfSelection"),
  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
),

const SizedBox(height: 10),

// CPF details with calculation explanation
_cpfDetailRow(
  context.tr("totalBuffaloes"),
  "$totalBuffaloes ${context.tr("buffaloes")}",
),

_cpfDetailRow(
  context.tr("freeCpfPerUnit"),
  "$freeCpfUnits ${context.tr("buffaloes")}",
),

_cpfDetailRow(
  context.tr("cpfToBePaid"),
  "$insuranceUnits ${context.tr("buffaloes")}",
),

_cpfDetailRow(
  context.tr("cpfPerBuffalo"),
  "₹$cpfPerBuffalo",
),

_cpfDetailRow(
  context.tr("totalCpfCost"),
  "₹$totalCpf",
),

const SizedBox(height: 8),

           
          ],
        ],
      ),
    );
  }

  Widget _cpfDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kPrimaryGreen,
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
        
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
  SnackBar(content: Text(context.tr("paymentFailed"))),
);
;
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

    // Calculate costs - IMPORTANT: baseUnitCost should be price per unit (2 buffaloes)
    final baseUnitCost = buffalo.price * 2; 
    final cpfUnitCost = isCpfSelected ? buffalo.insurance : 0;

    // Prepare payload according to new structure
    final payload = {
      "userId": userMobile,
      "breedId": buffalo.id,
      "numUnits": units,
      "paymentMode": "MANUAL_PAYMENT",
      "baseUnitCost": baseUnitCost,
      "cpfUnitCost": cpfUnitCost,
    };
    
    debugPrint("Manual Payment Request Payload: $payload");

    final response = await ref
        .read(unitProvider)
        .createUnit(payload: payload);

    if (!mounted) return;
    Navigator.pop(context);

    if (response != null) {
      // Show success message with order details
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
  final cpfPerBuffalo = buffalo.insurance; // This should be 13000
  final totalBuffaloes = units * 2;
  final freeCpfUnits = units; // 1 free CPF per unit

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFFAFDF6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFB2E3A8)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr("priceBreakdown"),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
       _calcLine(
  context.tr("unitsSelected"),
  "$units ${context.tr("unit")}",
),

_calcLine(
  context.tr("totalBuffaloes"),
  "$totalBuffaloes",
),

_calcLine(
  context.tr("pricePerBuffalo"),
  "₹${buffalo.price}",
),

_calcLine(
  context.tr("buffalo_price"),
  "₹$buffaloPrice",
),

const SizedBox(height: 8),

// CPF calculation details
Text(
  context.tr("cpfCalculation"),
  style: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.blue,
  ),
),

const SizedBox(height: 6),

_calcLine(
  context.tr("totalBuffaloes"),
  "$totalBuffaloes",
),

_calcLine(
  context.tr("freeCpf"),
  "$freeCpfUnits",
),

_calcLine(
  context.tr("cpfToBePaid"),
  "$insuranceUnits",
),

_calcLine(
  context.tr("cpfPerBuffalo"),
  "₹$cpfPerBuffalo",
),

_calcLine(
  context.tr("totalCpfCost"),
  "₹$cpfAmount",
),

        
        // Savings information
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                
  "${context.tr("youSave")}:",


                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryGreen,
                ),
              ),
              Text(
                "₹${freeCpfUnits * cpfPerBuffalo}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kPrimaryGreen,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              
        context.tr("totalAmount"),


              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "₹$total",
              style: const TextStyle(
                fontSize: 22,
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

Widget _calcLine(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            "• $label:",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}