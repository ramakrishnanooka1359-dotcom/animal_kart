import 'dart:async';
import 'package:animal_kart_demo2/buffalo/providers/buffalo_details_provider.dart';
import 'package:animal_kart_demo2/buffalo/widgets/buffalo_details_content.dart';
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
  int quantity = 2;
  bool isCpfSelected = true;
  late PageController _pageController;
  int currentIndex = 0;

  double get units => quantity * 0.5;
  
  String get unitText {
    return units <= 1 ? context.tr("unit") : context.tr("units");
  }
  
  int get cpfUnitsToPay {
    if (!isCpfSelected) return 0;
    return quantity.isEven ? quantity ~/ 2 : (quantity / 2).ceil();
  }
  
  int get freeCpfUnits {
    if (!isCpfSelected) return 0;
    return quantity ~/ 2;
  }

  int get totalCpfCostForBackend {
    if (!isCpfSelected) return 0;
    return cpfUnitsToPay * 13000;
  }

  int get baseUnitCostForBackend {
    return quantity * 175000;
  }

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

  void updateQuantity(int newQuantity) {
    setState(() {
      quantity = newQuantity;
    });
  }

  void toggleCpfSelection(bool value) {
    setState(() {
      isCpfSelected = value;
    });
  }

  void updateCurrentIndex(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        final totalBuffaloes = quantity;
        final totalCalves = quantity;
        final buffaloPrice = totalBuffaloes * buffalo.price;
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
          bottomNavigationBar: _buildPaymentSection(context, buffalo, totalAmount),
          body: BuffaloDetailsContent(
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
            onQuantityChanged: updateQuantity,
            onCpfSelectionChanged: toggleCpfSelection,
            pageController: _pageController,
            currentIndex: currentIndex,
            onPageChanged: updateCurrentIndex,
          ),
        );
      },
    );
  }

  Widget _buildPaymentSection(BuildContext context, buffalo, int totalAmount) {
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
                  _showCpfConfirmationDialog(context, () {
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
                  _showCpfConfirmationDialog(context, () {
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
          MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
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

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.tr("userMobileNotFound")),
            backgroundColor: Colors.red,
          ),
        );
      return;
    }

    final baseUnitCost = buffalo.price * quantity;
    final cpfUnitCost =
        isCpfSelected ? (cpfUnitsToPay * buffalo.insurance) : 0;

    final payload = {
      "userId": userMobile,
      "breedId": buffalo.id,
      "numUnits": units,
      "paymentMode": "MANUAL_PAYMENT",
      "baseUnitCost": baseUnitCost,
      "cpfUnitCost": cpfUnitCost,
    };

    debugPrint("Manual Payment Request Payload: $payload");

    final response =
        await ref.read(unitProvider).createUnit(payload: payload);

    if (!mounted) return;
    Navigator.pop(context);

    if (response != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              "${context.tr("orderPlaced")}",
            ),
            backgroundColor: kPrimaryDarkColor,
            duration: const Duration(seconds: 3),
          ),
        );

      Navigator.pushReplacementNamed(
        context,
        AppRouter.home,
        arguments: 1,
      );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.tr("orderFailed")),
            backgroundColor: Colors.red,
          ),
        );
    }
  } catch (e) {
    if (mounted) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.tr("errorOccurred")),
            backgroundColor: Colors.red,
          ),
        );

      debugPrint("Manual payment error: $e");
    }
  }
}


  void _showCpfConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
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