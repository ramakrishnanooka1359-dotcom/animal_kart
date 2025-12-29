import 'package:animal_kart_demo2/l10n/app_localizations.dart';
import 'package:animal_kart_demo2/orders/widgets/custom_widgets.dart';
import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:flutter/material.dart';


class TrackerScreen extends StatefulWidget {
  final String buffaloType;
  final double unitCount;
  final String purchaseDate;
  final double buffaloCount;
  final double calfCount;
  final double totalUnitcost;

  const TrackerScreen({
    super.key,
    required this.buffaloType,
    required this.unitCount,
    required this.purchaseDate,
    required this.buffaloCount,
    required this.calfCount,
    required this.totalUnitcost
  });

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final int _currentStep = 2; 
  final List<TrackerStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _initializeSteps();
  }

  void _initializeSteps() {
    _steps.addAll([
      TrackerStep(
        title: 'Purchase Confirmed',
        description: 'Murrah Buffalo (1 unit) purchased',
        date: 'Jan 15, 2024',
        status: StepStatus.completed,
        icon: Icons.shopping_cart,
      ),
      TrackerStep(
        title: 'Sent to Quarantine',
        description: 'Murrah Buffalo 1 unit sent to quarantine',
        date: 'Jan 18, 2024',
        status: StepStatus.completed,
        icon: Icons.local_shipping,
      ),
      TrackerStep(
        title: 'Received at Quarantine',
        description: 'Murrah Buffalo 1 unit received at quarantine',
        date: 'Jan 19, 2024',
        status: StepStatus.completed,
        icon: Icons.check_circle_outline,
      ),
      TrackerStep(
        title: 'Quarantine Passed',
        description: 'Murrah Buffalo 1 unit passed quarantine',
        date: 'Jan 25, 2024',
        status: StepStatus.pending,
        icon: Icons.health_and_safety,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Track Order',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).primaryTextColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: kPrimaryDarkColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/images/buffalo_image2.png",
                height: 60,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Breed ID: ${widget.buffaloType}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _valueRow(
                    context,
                    widget.buffaloCount % 1 == 0
                        ? widget.buffaloCount.toInt().toString()
                        : widget.buffaloCount.toString(),
                    widget.buffaloCount == 1
                        ? context.tr("buffalo")
                        : context.tr("buffaloes"),
                  ),
                  _valueRow(
                    context,
                    widget.calfCount % 1 == 0
                        ? widget.calfCount.toInt().toString()
                        : widget.calfCount.toString(),
                    widget.calfCount == 1
                        ? context.tr("calf")
                        : context.tr("calves"),
                  ),
                ],
              ),

                  const SizedBox(height: 4),
                  Text(
                    "${widget.unitCount % 1 == 0 ? widget.unitCount.toInt().toString() : widget.unitCount.toString()} "
                    "${widget.unitCount == 1 ? context.tr("unit") : context.tr("units")} + CPF",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 70,
              width: 1,
              color: Colors.grey.withValues(alpha:0.5),
              margin: const EdgeInsets.symmetric(horizontal: 10),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  FormatUtils.formatAmount(widget.totalUnitcost),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Tracking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimaryDarkColor,
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              return _buildTimelineStep(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(int index) {
    final step = _steps[index];
    final isCompleted = index <= _currentStep;
    final isLast = index == _steps.length - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Indicator column
          Column(
            children: [
              // Dot indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? kPrimaryDarkColor : Colors.grey[300],
                ),
                child: Icon(
                  step.icon,
                  size: 20,
                  color: isCompleted ? Colors.white : Colors.grey[400],
                ),
              ),
              // Connector line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    color: isCompleted && index < _currentStep 
                        ? kPrimaryDarkColor 
                        : Colors.grey[300],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content column
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isCompleted ? Colors.black : Colors.grey[400],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.date,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? Colors.black87 : Colors.grey[400],
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ?  Colors.black87 : Colors.grey[400],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueRow(BuildContext context, String value, String label) {
    return Text(
      "$value $label",
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    );
  }
}

enum StepStatus { completed, pending }

class TrackerStep {
  final String title;
  final String description;
  final String date;
  final StepStatus status;
  final IconData icon;

  TrackerStep({
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    required this.icon,
  });
}