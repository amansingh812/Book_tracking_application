import 'package:flutter/material.dart';

class UsageMeter extends StatelessWidget {
  final int used;
  final int total;
  final String description;

  const UsageMeter({
    super.key,
    required this.used,
    required this.total,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Quota',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(4.0),
            minHeight: 8.0,
          ),
        ],
      ),
    );
  }
}
