import 'package:animal_kart_demo2/orders/models/order_model.dart';
import 'package:animal_kart_demo2/orders/providers/orders_providers.dart';
import 'package:animal_kart_demo2/orders/screens/invoice_screen.dart';
import 'package:animal_kart_demo2/orders/screens/pdf_viewer_screen.dart';
import 'package:animal_kart_demo2/orders/widgets/orders_card_widget.dart';
import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Filter state provider
final filterStateProvider = StateProvider<FilterState>((ref) {
  return FilterState();
});

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

  void _showFilterBottomSheet(BuildContext context) {
    // Create a local copy of the filter state
    FilterState localFilterState = ref.read(filterStateProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter & Sort',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 24),
                        onPressed: () => Navigator.pop(context),
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Sort Section
                  const Text(
                    'Sort by Date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _SortChip(
                          label: 'Latest First',
                          icon: Icons.arrow_downward,
                          selected: localFilterState.sortByLatest,
                          onTap: () {
                            setModalState(() {
                              localFilterState = localFilterState.copyWith(sortByLatest: true);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SortChip(
                          label: 'Oldest First',
                          icon: Icons.arrow_upward,
                          selected: !localFilterState.sortByLatest,
                          onTap: () {
                            setModalState(() {
                              localFilterState = localFilterState.copyWith(sortByLatest: false);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Filter Section
                  const Text(
                    'Filter by Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatusChip(
                        label: 'All Orders',
                        selected: localFilterState.statusFilter == null,
                        color: Colors.grey,
                        onTap: () {
                          setModalState(() {
                            localFilterState = localFilterState.copyWith(clearStatusFilter: true);
                          });
                        },
                      ),
                      _StatusChip(
                        label: 'Pending',
                        selected: localFilterState.statusFilter == 'PENDING_PAYMENT',
                        color: Colors.orange,
                        onTap: () {
                          setModalState(() {
                            localFilterState = localFilterState.copyWith(statusFilter: 'PENDING_PAYMENT');
                          });
                        },
                      ),
                      _StatusChip(
                        label: 'Paid',
                        selected: localFilterState.statusFilter == 'PAID',
                        color: Colors.green,
                        onTap: () {
                          setModalState(() {
                            localFilterState = localFilterState.copyWith(statusFilter: 'PAID');
                          });
                        },
                      ),
                      _StatusChip(
                        label: 'Admin Review',
                        selected: localFilterState.statusFilter == 'PENDING_ADMIN_VERIFICATION',
                        color: const Color(0xFF7E57C2),
                        onTap: () {
                          setModalState(() {
                            localFilterState = localFilterState.copyWith(statusFilter: 'PENDING_ADMIN_VERIFICATION');
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Reset to default state
                            localFilterState = FilterState();
                            ref.read(filterStateProvider.notifier).state = FilterState();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: kPrimaryGreen, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              color: kPrimaryGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Apply the local filter state to the provider
                            ref.read(filterStateProvider.notifier).state = localFilterState;
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                              ? kPrimaryGreen.withOpacity(0.1) 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasActiveFilters 
                                ? kPrimaryGreen.withOpacity(0.3)
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
                          onPressed: () => _showFilterBottomSheet(context),
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
                        ? _buildEmptyState(orders.isEmpty, hasActiveFilters)
                        : Column(
                            children: [
                              // Active Filters Display
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
                                              color: kPrimaryGreen.withOpacity(0.1),
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
                                            _ActiveFilterChip(
                                              label: _getStatusLabel(filterState.statusFilter!),
                                              onRemove: () {
                                                // Clear only the status filter
                                                ref.read(filterStateProvider.notifier).state =
                                                    filterState.copyWith(clearStatusFilter: true);
                                              },
                                            ),
                                          if (!filterState.sortByLatest)
                                            _ActiveFilterChip(
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

  Widget _buildEmptyState(bool noOrders, bool hasFilters) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                noOrders ? Icons.shopping_bag_outlined : Icons.filter_alt_off_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              noOrders ? "No Orders Yet" : "No Matching Orders",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              noOrders
                  ? "Your orders will appear here once\nyou make your first purchase"
                  : "Try adjusting your filters to see\nmore orders",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(filterStateProvider.notifier).state = FilterState();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimaryGreen,
                  side: BorderSide(color: kPrimaryGreen, width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDING_PAYMENT':
        return 'Pending Payment';
      case 'PAID':
        return 'Paid';
      case 'PENDING_ADMIN_VERIFICATION':
        return 'Admin Review';
      default:
        return status;
    }
  }
}

// Custom Sort Chip Widget
class _SortChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? kPrimaryGreen.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? kPrimaryGreen : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? kPrimaryGreen : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? kPrimaryGreen : Colors.grey[700],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Status Chip Widget
class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: color,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Active Filter Chip Widget
class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kPrimaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: kPrimaryGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kPrimaryGreen,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16,
              color: kPrimaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}