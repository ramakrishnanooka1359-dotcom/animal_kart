import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_kart_demo2/utils/app_constants.dart';

import '../models/coins_model.dart';
import '../providers/coin_provider.dart';

class TransferUnitScreen extends ConsumerWidget {
  const TransferUnitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coinAsync = ref.watch(coinProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: coinAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (response) {
            //  final transactions = response?.transactions;
final transactions = response?.transactions ?? [];
double totalCoins = 0;

for (var item in transactions) {
  totalCoins += item.transaction.coins;
}

              // double totalCoins = 0;

              // for (var item in transactions!) {
              //   totalCoins += item.transaction.coins;
              // }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// BACK
                  IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 14),

                  /// HEADER
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'coins',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatAmount(totalCoins),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Spend coins to unlock your Buffalo! Purchase 1 unit today and get free CPF for an entire year.',
                              style: TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        AppConstants.coinDetailsImage,
                        width: 90,
                        height: 90,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  const Divider(),

                  /// ONLY EARNINGS (NO SPENDS)
                  _StatItem(
                    title: "lifetime earnings",
                    value: _formatAmount(totalCoins),
                  ),

                  const Divider(),
                  const SizedBox(height: 18),

                  const Text(
                    "COIN LEDGER",
                    style: TextStyle(
                      letterSpacing: 2,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// LEDGER LIST
                 Expanded(
  child: transactions.isEmpty || totalCoins == 0
      ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: Colors.black26,
              ),
              SizedBox(height: 12),
              Text(
                "No coins are available yet",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        )
      : ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final txn = transactions[index].transaction;

            return CoinLedgerItem(
              amount: _formatAmount(txn.coins),
              label: _buildLabel(txn),
              date: _formatDate(txn.createdAt),
            );
          },
        ),
),

                  // Expanded(
                  //   child: ListView.builder(
                  //     itemCount: transactions.length,
                  //     itemBuilder: (context, index) {
                  //       final txn = transactions[index].transaction;

                  //       return CoinLedgerItem(
                  //         amount: _formatAmount(txn.coins),
                  //         label: _buildLabel(txn),
                  //         date: _formatDate(txn.createdAt),
                  //       );
                  //     },
                  //   ),
                  // ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// STAT ITEM
class _StatItem extends StatelessWidget {
  final String title;
  final String value;

  const _StatItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

/// LEDGER ITEM (ALWAYS CREDIT)
class CoinLedgerItem extends StatelessWidget {
  final String amount;
  final String label;
  final String date;

  const CoinLedgerItem({
    super.key,
    required this.amount,
    required this.label,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: const Icon(
              Icons.north_east,
              size: 16,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black38,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// HELPERS

String _buildLabel(CoinTransaction txn) {
  if (txn.noOfUnitsBuy != null) {
    return 'Referred ${txn.name} purchased ${txn.noOfUnitsBuy} unit';
  }
  if (txn.giverName != null) {
    return 'Coins received from ${txn.giverName}';
  }
  return 'Referred ${txn.name} purchased ${txn.noOfUnitsBuy} unit';
}

String _formatAmount(double value) {
  return value.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

String _formatDate(String date) {
  try {
    // API format: dd-MM-yyyy
    final parts = date.split('-');

    final day = parts[0];
    final month = parts[1];
    final year = parts[2];

    const months = {
      '01': 'JAN',
      '02': 'FEB',
      '03': 'MAR',
      '04': 'APR',
      '05': 'MAY',
      '06': 'JUN',
      '07': 'JUL',
      '08': 'AUG',
      '09': 'SEP',
      '10': 'OCT',
      '11': 'NOV',
      '12': 'DEC',
    };

    return '$day ${months[month]} $year';
  } catch (_) {
    return date;
  }
}
