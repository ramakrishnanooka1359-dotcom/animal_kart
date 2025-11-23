import 'package:animal_kart_demo2/controllers/cart_provider.dart';
import 'package:animal_kart_demo2/screens/tabs_screens/cart_screen.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  List<Map<String, dynamic>> wishlist = [
    {
      "id": "MURRAH-001",
      "age": 3,
      "breed": "Murrah Buffalo",
      "buffalo_images": [
        "https://storage.googleapis.com/markwave-kart/productimages/murrah_1.jpeg",
        "https://storage.googleapis.com/markwave-kart/productimages/murrah_2.jpeg",
        "https://storage.googleapis.com/markwave-kart/productimages/murrah_3.jpeg",
        "https://storage.googleapis.com/markwave-kart/productimages/murrah_4.jpeg",
      ],
      "description":
          "The Murrah is a premium dairy buffalo known for its jet-black coat...",
      "price": 175000,
      "insurance": 13000,
      "milkYield": 12,
      "inStock": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).mainThemeBgColor,

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: wishlist.length,
                itemBuilder: (context, index) {
                  final item = wishlist[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _wishlistCard(
                      img: item["buffalo_images"][0],
                      name: item["breed"],
                      price: item["price"],
                      onRemove: () {
                        setState(() => wishlist.removeAt(index));
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5DBE8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onPressed: () {
                  if (wishlist.isEmpty) return;

                  final item = wishlist.first;
                  final cartNotifier = ref.read(cartProvider.notifier);

                  cartNotifier.setItem(
                    item["id"],
                    1, // qty = 1
                    item["insurance"], // insurance
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(showAppBar: true),
                    ),
                  );
                },
                child: const Text(
                  "Add to cart",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wishlistCard({
    required String img,
    required String name,
    required int price,
    required VoidCallback onRemove,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).lightThemeCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  img,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "₹$price",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
