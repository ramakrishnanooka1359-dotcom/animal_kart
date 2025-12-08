import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayService {
  late Razorpay _razorpay;

  final VoidCallback? onPaymentOpen;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentFailed;
  final VoidCallback? onPaymentClose;

  RazorPayService({
    this.onPaymentOpen,
    this.onPaymentSuccess,
    this.onPaymentFailed,
    this.onPaymentClose,
  }) {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleWallet);

    // Razorpay added a "close" event in newer versions
    _razorpay.on("RZP_PAYMENT_LINK_CLOSED", _handleClose);
  }

  void openPayment({required int amount}) {
    // Tell UI that payment window is opening
    onPaymentOpen?.call();

    var options = {
      'key': 'rzp_test_ChtIh4impxVRVG',
      'amount': amount * 100, // in paise
      'name': 'Markwave Cart',
      'description': 'Buffalo Purchase',
      'prefill': {
        'contact': '9876543210',
        'email': 'test@gmail.com',
      },
    };

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    onPaymentSuccess?.call();
  }

  void _handleError(PaymentFailureResponse response) {
    onPaymentFailed?.call();
  }

  void _handleWallet(ExternalWalletResponse response) {
    debugPrint("WALLET: ${response.walletName}");
  }

  void _handleClose(dynamic _) {
    onPaymentClose?.call();
  }
}
