import 'package:animal_kart_demo2/orders/models/order_model.dart';
import 'package:animal_kart_demo2/orders/providers/orders_providers.dart';
import 'package:animal_kart_demo2/orders/screens/invoice_screen.dart';
import 'package:animal_kart_demo2/orders/screens/pdf_viewer_screen.dart';
import 'package:animal_kart_demo2/orders/widgets/active_chipfilter_widget.dart';
import 'package:animal_kart_demo2/orders/widgets/emptystate_widget.dart';
import 'package:animal_kart_demo2/orders/widgets/filterBottomSheet_widget.dart';
import 'package:animal_kart_demo2/orders/widgets/orders_card_widget.dart';

import 'package:animal_kart_demo2/orders/widgets/statuslabel_widget.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Filter state provider
final filterStateProvider = StateProvider<FilterState>((ref) {
  return FilterState();
});
final sortProvider = StateProvider<bool>((ref) => false);

class FilterState {
  String? statusFilter;
  bool sortByLatest = true;

  FilterState({
    this.statusFilter,
    this.sortByLatest = true,
  });

  FilterState copyWith({
    String? statusFilter,
    bool? sortByLatest,
    bool clearStatusFilter = false,
  }) {
    return FilterState(
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      sortByLatest: sortByLatest ?? this.sortByLatest,
    );
  }
}

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

void openFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const OrdersFilterBottomSheet(),
  );
}

  Future<void> _loadOrders() async {
    try {
      await ref.read(ordersProvider.notifier).loadOrders();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load orders: $error'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(ordersProvider);
    final isLoading = ref.watch(ordersLoadingProvider);
    final filterState = ref.watch(filterStateProvider);

    // Apply filters and sorting
    List<OrderUnit> filteredOrders = orders.where((order) {
      if (filterState.statusFilter == null) return true;
      return order.paymentStatus.toUpperCase() == filterState.statusFilter;
    }).toList();

    // Apply sorting
    filteredOrders.sort((a, b) {
      if (filterState.sortByLatest) {
        return b.placedAt.compareTo(a.placedAt);
      } else {
        return a.placedAt.compareTo(b.placedAt);
      }
    });

    final hasActiveFilters = filterState.statusFilter != null || !filterState.sortByLatest;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadOrders,
          color: kPrimaryGreen,
          child: Column(
            children: [
              // Filter Icon at Top Right
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: hasActiveFilters 
                              ? kPrimaryGreen.withValues(alpha:0.1) 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasActiveFilters 
                                ? kPrimaryGreen.withValues(alpha:0.3)
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          color: hasActiveFilters ? kPrimaryGreen : Colors.grey[700],
                          size: 24,
                        ),
                        onPressed: () => openFilterBottomSheet(context),
                      ),

                      ),
                      if (hasActiveFilters)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : filteredOrders.isEmpty
                    ?OrdersEmptyState(
                        noOrders: orders.isEmpty,
                        hasFilters: hasActiveFilters,
                      )
                        : Column(
                            children: [
                              if (hasActiveFilters)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: kPrimaryGreen.withValues(alpha:0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.filter_alt,
                                              size: 16,
                                              color: kPrimaryGreen,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            'Active Filters',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1A1A1A),
                                            ),
                                          ),
                                          const Spacer(),
                                          GestureDetector(
                                            onTap: () {
                                              // Reset all filters
                                              ref.read(filterStateProvider.notifier).state = FilterState();
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              child: Icon(
                                                Icons.close,
                                                size: 18,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          if (filterState.statusFilter != null)
                                            ActiveFilterChip(
                                              label: getStatusLabel(filterState.statusFilter!),
                                              onRemove: () {
                                                // Clear only the status filter
                                                ref.read(filterStateProvider.notifier).state =
                                                    filterState.copyWith(clearStatusFilter: true);
                                              },
                                            ),
                                          if (!filterState.sortByLatest)
                                            ActiveFilterChip(
                                              label: 'Oldest First',
                                              onRemove: () {
                                                // Clear only the sort filter
                                                ref.read(filterStateProvider.notifier).state =
                                                    filterState.copyWith(sortByLatest: true);
                                              },
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              
                              // Orders Count
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Text(
                                      '${filteredOrders.length} ${filteredOrders.length == 1 ? 'Order' : 'Orders'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // Orders List
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom: 16,
                                  ),
                                  itemCount: filteredOrders.length,
                                  itemBuilder: (context, index) {
                                    final order = filteredOrders[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: BuffaloOrderCard(
                                        order: order,
                                        onTapInvoice: () async {
                                          final filePath = await InvoiceGenerator.generateInvoice(
                                            order,
                                          );
                                          if (context.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PdfViewerScreen(filePath: filePath),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



