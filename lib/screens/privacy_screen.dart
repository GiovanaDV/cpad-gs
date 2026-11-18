import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../providers/alerts_provider.dart';
import '../providers/occurrences_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/bullet_list.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  Future<bool> _confirm(BuildContext context, String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(96, 48)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _revoke(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _confirm(
      context,
      'Revogar consentimento?',
      'Você deixará de poder registrar ocorrências. Os dados já salvos continuam no aparelho até você apagá-los.',
    );
    if (!ok) return;
    await settings.setConsent(false);
    messenger.showSnackBar(const SnackBar(content: Text('Consentimento revogado.')));
  }

  Future<void> _deleteData(BuildContext context) async {
    final occurrences = context.read<OccurrencesProvider>();
    final alerts = context.read<AlertsProvider>();
    final settings = context.read<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await _confirm(
      context,
      'Apagar meus dados?',
      'Serão apagadas as ocorrências registradas por você, suas decisões sobre alertas e os limiares configurados. '
          'Esta ação não pode ser desfeita.',
    );
    if (!ok) return;
    await occurrences.deleteCitizenData();
    await alerts.clearDecisions();
    await settings.resetThresholds();
    messenger.showSnackBar(const SnackBar(content: Text('Seus dados foram apagados deste aparelho.')));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final text = Theme.of(context).textTheme;

    final consentText = !settings.consentAnswered
        ? 'Consentimento ainda não respondido.'
        : settings.consentAccepted
            ? 'Consentimento aceito em ${DateFormat('dd/MM/yyyy HH:mm').format(settings.consentAt!)}.'
            : 'Consentimento não concedido: o registro de ocorrências está desativado.';

    return Scaffold(
      appBar: AppBar(title: const Text('Privacidade e sobre')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seu consentimento', style: text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(consentText),
                const SizedBox(height: AppSpacing.md),
                if (settings.consentAccepted)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: () => _revoke(context),
                    icon: const Icon(Icons.do_not_disturb_on_outlined),
                    label: const Text('Revogar consentimento'),
                  )
                else
                  FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.consent),
                    icon: const Icon(Icons.privacy_tip_outlined),
                    label: const Text('Revisar e aceitar'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seus dados neste aparelho', style: text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Tudo fica salvo apenas neste aparelho. Você pode apagar suas ocorrências, suas decisões '
                  'sobre alertas e seus limiares quando quiser.',
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: () => _deleteData(context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Apagar meus dados'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Como protegemos a privacidade', style: text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                const BulletList(
                  icon: Icons.shield_outlined,
                  items: [
                    'Anonimização: sem nome, CPF, telefone, e-mail, endereço ou GPS.',
                    'Minimização: a hora do registro é arredondada, sem minutos.',
                    'Validação: o texto livre é bloqueado se tiver CPF, telefone, e-mail ou números longos.',
                    'Armazenamento local: nenhuma ocorrência é enviada a servidores.',
                    'A busca de clima envia apenas as coordenadas do bairro.',
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sobre o Nexo', style: text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Projeto acadêmico da FIAP, Global Solution 2026.2 (Cross-Platform Application Development). '
                  'Os dados de consumo e ocorrências de exemplo são sintéticos; o clima vem da API pública Open-Meteo. '
                  'Os alertas apoiam, mas não substituem, a decisão humana.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}