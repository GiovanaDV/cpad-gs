import 'package:material_ui/material_ui.dart';
import '../core/app_theme.dart';

class InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoBanner({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: scheme.tertiaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: scheme.onTertiaryContainer),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: TextStyle(color: scheme.onTertiaryContainer))),
        ],
      ),
    );
  }
}