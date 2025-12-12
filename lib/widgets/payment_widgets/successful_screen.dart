import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({super.key});

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  @override
  void initState() {
    super.initState();

    // Optional auto redirect after 3 sec
    // Timer(const Duration(seconds: 3), () {
    //   if (mounted) Navigator.pop(context);
    // });
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
          Text(
            context.tr("paymentSuccess"),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              context.tr("paymentThankYou"),
              textAlign: TextAlign.center,
              style: const TextStyle(
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
              Navigator.pop(context);
            },
            child: Text(
              context.tr("backToHome"),
              style: const TextStyle(
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
