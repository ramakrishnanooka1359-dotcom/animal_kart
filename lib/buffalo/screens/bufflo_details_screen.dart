import 'dart:async';
import 'package:animal_kart_demo2/buffalo/providers/buffalo_details_provider.dart';
import 'package:animal_kart_demo2/buffalo/widgets/custom_buffalo_details.dart';
import 'package:animal_kart_demo2/services/razorpay_service.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/widgets/payment_widgets/manual_payment_screen.dart';
import 'package:animal_kart_demo2/widgets/payment_widgets/successful_screen.dart';
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
  int insuranceUnits = 0;
  int currentIndex = 0;

  late PageController _pageController;

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
      error: (err, _) => Scaffold(body: Center(child: Text("Error: $err"))),
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
              icon: Icon(Icons.arrow_back_ios_new,
                  color: Theme.of(context).primaryTextColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text("Buffalo Details"),
          ),
          bottomNavigationBar:
              _paymentSection(context, buffalo, totalAmount),
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
                const SizedBox(height: 24),
                cpfExplanationCard(buffalo),
              
                const SizedBox(height: 24),
                _insuranceSelector(buffalo),
                const SizedBox(height: 28),
                priceExplanation(
                  buffalo:buffalo,
                  units:units,
                  insuranceUnits:insuranceUnits,
                  buffaloPrice:buffaloPrice,
                  cpfAmount:cpfAmount,
                  total:totalAmount,
                ),
              ],
            ),
          ),
        );
      },
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



  
  Widget _insuranceSelector(buffalo) {
    final maxCpf = units;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("CPF Selection",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text("Max CPF: $maxCpf"),
        Text("CPF per Buffalo: ₹${buffalo.insurance}"),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("CPF Units"),
          Row(children: [
            GestureDetector(
              onTap: insuranceUnits > 0
                  ? () => setState(() => insuranceUnits--)
                  : null,
              child: circleButton(Icons.remove,
                  isDisabled: insuranceUnits == 0),
            ),
            const SizedBox(width: 14),
            Text("$insuranceUnits",
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(width: 14),
            GestureDetector(
              onTap: insuranceUnits < maxCpf
                  ? () => setState(() => insuranceUnits++)
                  : null,
              child: circleButton(Icons.add,
                  isDisabled: insuranceUnits == maxCpf),
            ),
          ])
        ])
      ]),
    );
  }


  Widget _paymentSection(
      BuildContext context, buffalo, int totalAmount) {
    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          height: 55,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final razorpay = RazorPayService(
                onPaymentSuccess: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BookingSuccessScreen()),
                  );
                },
                onPaymentFailed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Payment failed")),
                  );
                },
              );

              razorpay.openPayment(amount: totalAmount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
            ),
            child: const Text("Online Payment",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 55,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ManualPaymentScreen(totalAmount: totalAmount),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
            ),
            child: const Text("Manual Payment",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

 


  
}
