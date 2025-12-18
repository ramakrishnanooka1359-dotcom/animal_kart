import 'package:animal_kart_demo2/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';

class TrackerScreen extends StatefulWidget {
  final String buffaloType = 'Murrah Buffalo';
  final int unitCount = 1;
  final String purchaseDate = '2024-01-15';

  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final int _currentStep = 2; // Index for "Received at Quarantine"
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            const SizedBox(height: 10),
            _buildTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.brown.withOpacity(0.1),
                child: const Icon(Icons.pets, color: Colors.brown, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.buffaloType,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.unitCount} Unit • Purchase Date: ${widget.purchaseDate}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.56,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '56% Complete',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 40, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: FixedTimeline.tileBuilder(
        theme: TimelineThemeData(
          nodePosition: 0, // This pushes the line to the LEFT
          connectorTheme: const ConnectorThemeData(
            thickness: 3.0,
            color: Color(0xffd3d3d3),
          ),
          indicatorTheme: const IndicatorThemeData(
            size: 30.0,
          ),
        ),
        builder: TimelineTileBuilder.connected(
          indicatorBuilder: (context, index) {
            final step = _steps[index];
            return OutlinedDotIndicator(
              borderWidth: 2.0,
              color: index <= _currentStep ? Colors.green : Colors.grey[300]!,
              child: Icon(
                step.icon,
                size: 15,
                color: index <= _currentStep ? Colors.green : Colors.grey[400],
              ),
            );
          },
          connectorBuilder: (context, index, type) {
            return SolidLineConnector(
              color: index <= _currentStep ? Colors.green : Colors.grey[200],
            );
          },
          contentsBuilder: (context, index) {
            final step = _steps[index];
            return Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.date,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (index <= _currentStep)
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: index <= _currentStep ? Colors.green : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.description,
                    style: TextStyle(color: Colors.grey[700], fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  if (index < _steps.length - 1)
                    Divider(color: Colors.grey[200], thickness: 1),
                ],
              ),
            );
          },
          itemCount: _steps.length,
        ),
      ),
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