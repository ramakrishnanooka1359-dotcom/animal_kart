import 'package:animal_kart_demo2/utils/app_colors.dart';
import 'package:flutter/material.dart';

class ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const ActiveFilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kPrimaryGreen.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: kPrimaryGreen.withValues(alpha:0.3),
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