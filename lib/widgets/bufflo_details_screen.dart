import 'dart:async';
import 'package:animal_kart_demo2/controllers/cart_provider.dart';
import 'package:animal_kart_demo2/controllers/buffalo_details_provider.dart';
import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/screens/tabs_screens/cart_screen.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:animal_kart_demo2/utils/app_constants.dart';
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
  int qty = 1;
  bool isFavorite = false;

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

    final imageList = buffaloAsync.value!.buffaloImages;

    int nextPage = currentIndex + 1;
    if (nextPage == imageList.length) nextPage = 0;

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
      loading: () => Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimaryGreen)),
      ),

      error: (err, st) => Scaffold(body: Center(child: Text("Error: $err"))),

      data: (buffalo) {
        final imageList = buffalo.buffaloImages;

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
              context.tr("Buffalo Details"),
              style: TextStyle(color: Theme.of(context).primaryTextColor),
            ),
          ),

          body: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,

                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  padding: const EdgeInsets.only(bottom: 20),
                  margin: EdgeInsets.only(bottom: 50),

                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      // decoration: BoxDecoration(
                      //   color: Colors.red,

                      //   borderRadius: BorderRadius.circular(22),
                      // ),
                      // padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),

                          // ---------------------- IMAGE CAROUSEL ----------------------
                          SizedBox(
                            height: 350,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                PageView.builder(
                                  controller: _pageController,
                                  itemCount: imageList.length,
                                  onPageChanged: (i) =>
                                      setState(() => currentIndex = i),
                                  itemBuilder: (_, index) {
                                    final img = imageList[index];
                                    final isNetwork = img.startsWith("http");

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: /* Stack(
                                        children: [ */ ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: isNetwork
                                            ? Image.network(
                                                img,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              )
                                            : Image.asset(
                                                img,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                      ),
                                      // Positioned(
                                      //   top: 12,
                                      //   right: 12,
                                      //   child: GestureDetector(
                                      //     onTap: () {},
                                      //     child: Container(
                                      //       width: 34,
                                      //       height: 34,
                                      //       decoration: BoxDecoration(
                                      //         color: akWhiteColor,
                                      //         shape: BoxShape.circle,
                                      //       ),
                                      //       child: const Icon(
                                      //         Icons.favorite_border,
                                      //         color: akBlackColor,
                                      //         size: 20,
                                      //       ),
                                      //     ),
                                      //   ),
                                      //  ),
                                      //   ],
                                      // ),
                                    );
                                  },
                                ),

                                // DOT INDICATORS
                                Positioned(
                                  bottom: 12,
                                  child: Row(
                                    children: List.generate(
                                      imageList.length,
                                      (index) => AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        width: currentIndex == index ? 22 : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: currentIndex == index
                                              ? Colors.white
                                              : Colors.white54,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // ---------------------- TEXT DETAILS ----------------------
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  buffalo.breed,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Text(
                                  buffalo.description,
                                  style: TextStyle(
                                    fontSize: 18,
                                    height: 1.5,
                                    color: Theme.of(context).isLightTheme
                                        ? Colors.black87
                                        : akWhiteColor54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                // decoration: BoxDecoration(
                //   color: Theme.of(context).mainThemeBgColor,
                //   boxShadow: [
                //     BoxShadow(
                //       blurRadius: 8,
                //       offset: const Offset(0, -2),
                //       color: Colors.black.withOpacity(0.05),
                //     ),
                //   ],
                // ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // QTY SELECTOR
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 235, 241, 236),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                _qtyButton(Icons.remove, () {
                                  if (qty > 1) setState(() => qty--);
                                }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    "$qty",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                _qtyButton(Icons.add, () {
                                  setState(() => qty++);
                                }),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 30),

                        // ADD TO CART
                        Expanded(
                          flex: 2,

                          child: ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .setItem(buffalo.id, qty, buffalo.insurance);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CartScreen(showAppBar: true),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: kPrimaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              "Buy- ${AppConstants().formatIndianAmount(buffalo.price * qty)} ",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 12,
        backgroundColor: akBlackColor,
        child: Center(child: Icon(icon, size: 20, color: akWhiteColor)),
      ),
    );
  }
}
