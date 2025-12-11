
import 'package:animal_kart_demo2/routes/routes.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';

class PaymentPendingScreen extends StatefulWidget {
  const PaymentPendingScreen({super.key});

  @override
  State<PaymentPendingScreen> createState() => _PaymentPendingScreenState();
}

class _PaymentPendingScreenState extends State<PaymentPendingScreen> {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      backgroundColor: Colors.white,

     
      body: Column(
        children: [
          const Spacer(),

          Container(
            height: 120,
            width: 120,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimaryGreen,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 70,
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Your payment status is Pending",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Thank you for your payment.Our admin team is reviewing the submitted details and will verify the payment within 3 business days. You will be notified once the verification is complete.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ),

          const Spacer(),
          const Spacer(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
                 Navigator.pushReplacementNamed(
                  context,
                  AppRouter.home,
                  arguments: 1,   
              );
            },
            child: const Text(
              "Back to Orders",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
