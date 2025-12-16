import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final coinProvider = StateNotifierProvider<CoinNotifier, int>((ref) {
  return CoinNotifier();
});

class CoinNotifier extends StateNotifier<int> {
  CoinNotifier() : super(0);

  void setCoins(int value) {
    state = value;
  }

  void addCoins(int value) {
    state += value;
  }

  void reset() {
    state = 0;
  }
}
