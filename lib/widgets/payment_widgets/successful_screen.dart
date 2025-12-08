
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';

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

          const Text(
            "Your payment was successful",
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
              "Thank you for your payment. We will be in contact with more details shortly",
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
              Navigator.pop(context); 
            },
            child: const Text(
              "Back to Home",
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
