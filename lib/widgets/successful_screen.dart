import 'dart:async';
import 'package:animal_kart_demo2/theme/app_theme.dart';
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

    Timer(const Duration(seconds: 3), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:
            Theme.of(context).isLightTheme
                ? kPrimaryDarkColor
                : akDialogBackgroundColor,
        elevation: 0,
        toolbarHeight: 90,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        title: Row(
          children: [
            Image.asset('assets/images/onboard_logo.png', height: 50),
            const SizedBox(width: 8),
          ],
        ),
        actions: [
          // ThemeToggleButton(),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              child: Image.asset("assets/gifs/success.gif", fit: BoxFit.cover),
            ),

            const SizedBox(height: 20),

            const Text(
              "Congratulations\nYour buffalo has been\nbooked successfully!",
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
