import 'package:flutter/material.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/human_decision_banner.dart';
import '../widgets/data_status_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexo'),
        actions: [
          IconButton(
            tooltip: 'Privacidade e sobre',
            icon: const Icon(Icons.privacy_tip_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text('Conexão entre dados, território e pessoas.', style: text.titleMedium),
          const SizedBox(height: AppSpacing.md),
          const HumanDecisionBanner(),
          const SizedBox(height: AppSpacing.md),
          const DataStatusCard(),
          const SizedBox(height: AppSpacing.lg),
          Text('Painéis do território', style: text.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          _tile(context, Icons.water_drop_outlined, 'Consumo de água', AppRoutes.water),
          const SizedBox(height: AppSpacing.sm),
          _tile(context, Icons.cloud_outlined, 'Clima local', AppRoutes.climate),
          const SizedBox(height: AppSpacing.sm),
          _tile(context, Icons.build_outlined, 'Serviços e ocorrências', AppRoutes.services),
          const SizedBox(height: AppSpacing.lg),
          Text('Ações', style: text.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          _tile(context, Icons.notifications_active_outlined, 'Alertas preditivos', AppRoutes.alerts),
          const SizedBox(height: AppSpacing.sm),
          _tile(context, Icons.edit_note, 'Registrar ocorrência', AppRoutes.report),
          const SizedBox(height: AppSpacing.sm),
          _tile(context, Icons.tune, 'Limiares de alerta', AppRoutes.settings),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, String route) {
    return AppCard(
      semanticLabel: 'Abrir $label',
      onTap: () => Navigator.pushNamed(context, route, arguments: label),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}