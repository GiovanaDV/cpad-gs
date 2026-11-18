import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class BulletList extends StatelessWidget {
  final List<String> items;
  final IconData icon;

  const BulletList({super.key, required this.items, required this.icon});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(item, style: Theme.of(context).textTheme.bodySmall)),
              ],
            ),
          ),
      ],
    );
  }
}