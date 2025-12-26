class CoinTransactionResponse {
  final List<CoinTransactionItem> transactions;

  CoinTransactionResponse({required this.transactions});

  factory CoinTransactionResponse.fromJson(Map<String, dynamic> json) {
    final list = json['transactions'];

    return CoinTransactionResponse(
      transactions: list == null
          ? []
          : (list as List)
              .map((e) => CoinTransactionItem.fromJson(e))
              .toList(),
    );
  }
}

class CoinTransactionItem {
  final CoinTransaction transaction;

  CoinTransactionItem({required this.transaction});

  factory CoinTransactionItem.fromJson(Map<String, dynamic> json) {
    return CoinTransactionItem(
      transaction: json['transaction'] == null
          ? CoinTransaction.empty()
          : CoinTransaction.fromJson(json['transaction']),
    );
  }
}

class CoinTransaction {
  final double coins;
  final String createdAt;
  final String name;

  final double? noOfUnitsBuy;
  final String? giverName;

  CoinTransaction({
    required this.coins,
    required this.createdAt,
    required this.name,
    this.noOfUnitsBuy,
    this.giverName,
  });

  factory CoinTransaction.empty() {
    return CoinTransaction(
      coins: 0,
      createdAt: '',
      name: '',
    );
  }

  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    return CoinTransaction(
      coins: (json['coins'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
      name: json['name'] ?? '',
      noOfUnitsBuy: (json['no_of_units_buy'] as num?)?.toDouble() ?? 0.0,
      giverName: json['giverName'],
    );
  }
}
