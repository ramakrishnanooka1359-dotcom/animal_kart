import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayService {
  late Razorpay _razorpay;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailed;

  VoidCallback? onPaymentOpen;
  VoidCallback? onPaymentClose;

  RazorPayService({
    this.onPaymentOpen,
    this.onPaymentClose,
    this.onPaymentFailed,
    this.onPaymentSuccess,
  }) {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleWallet);
  }

  void openPayment({required int amount}) {
    // Call when process starts
    if (onPaymentOpen != null) onPaymentOpen!();

    var options = {
      'key': 'rzp_test_ChtIh4impxVRVG',
      'amount': amount * 100,
      'name': 'Markwave Cart',
      'description': 'Buffalo Purchase',
      'prefill': {'contact': '9876543210', 'email': 'test@gmail.com'},
    };

    // Razorpay opens at this moment
    Future.delayed(const Duration(milliseconds: 400), () {
      if (onPaymentClose != null) onPaymentClose!();
    });

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    if (onPaymentSuccess != null) onPaymentSuccess!();
  }

  void _handleError(PaymentFailureResponse response) {
    if (onPaymentFailed != null) onPaymentFailed!();
  }

  void _handleWallet(ExternalWalletResponse response) {
    debugPrint("WALLET: $response");
  }
}
