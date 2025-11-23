import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final int qty;
  final int insurancePaid;

  CartItem({required this.qty, required this.insurancePaid});

  Map<String, dynamic> toJson() =>
      {"qty": qty, "insurancePaid": insurancePaid};

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      CartItem(qty: json["qty"], insurancePaid: json["insurancePaid"]);
}

class CartController extends StateNotifier<Map<String, CartItem>> {
  CartController() : super({}) {
    _loadCart();
  }

  /// ---------- LOAD CART ----------
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("cartData");

    if (jsonString == null) return;

    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    final loaded = decoded.map(
      (key, value) =>
          MapEntry(key, CartItem.fromJson(value as Map<String, dynamic>)),
    );

    state = loaded;
  }

  /// ---------- SAVE CART ----------
  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      state.map((key, item) => MapEntry(key, item.toJson())),
    );

    prefs.setString("cartData", encoded);
  }

  /// ---------- CLEAR CART ----------
  Future<void> clearCart() async {
    state = {};
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("cartData");
  }

  /// ---------- ADD / UPDATE ITEM ----------
  void setItem(String id, int qty, int insurancePerBuffalo) {
    if (qty <= 0) {
      remove(id);
      return;
    }

    final insurancePaid = insurancePerBuffalo;

    state = {
      ...state,
      id: CartItem(qty: qty, insurancePaid: insurancePaid),
    };

    _saveCart(); // SAVE AFTER UPDATE
  }

  /// ---------- REMOVE ITEM ----------
  void remove(String id) {
    final copy = {...state};
    copy.remove(id);
    state = copy;
    _saveCart();
  }

  /// ---------- INCREASE ----------
  void increase(String id) {
    final old = state[id]!;
    setItem(id, old.qty + 1, old.insurancePaid);
  }

  /// ---------- DECREASE ----------
  void decrease(String id) {
    final old = state[id]!;
    setItem(id, old.qty - 1, old.insurancePaid);
  }
}

final cartProvider =
    StateNotifierProvider<CartController, Map<String, CartItem>>(
  (ref) => CartController(),
);
