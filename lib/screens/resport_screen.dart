import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../core/categories.dart';
import '../core/territory.dart';
import '../core/validators.dart';
import '../models/occurrence.dart';
import '../providers/occurrences_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/info_banner.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String? _category;
  String? _sector;
  bool _saving = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<OccurrencesProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);

    final now = DateTime.now();
    final occurrence = Occurrence(
      category: _category!,
      sector: _sector!,
      description: _descriptionController.text.trim(),
      // Minimização de dados: guarda só a hora, sem minutos.
      createdAt: DateTime(now.year, now.month, now.day, now.hour),
      source: 'cidadão',
    );

    try {
      await provider.add(occurrence);
      messenger.showSnackBar(const SnackBar(content: Text('Ocorrência registrada de forma anônima. Obrigado!')));
      navigator.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(const SnackBar(content: Text('Não foi possível salvar. Tente novamente.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final consent = context.watch<SettingsProvider>().consentAccepted;
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar ocorrência')),
      body: consent ? _form(context) : _noConsent(context),
    );
  }

  Widget _noConsent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Para registrar ocorrências, o Nexo precisa do seu consentimento para guardar o texto neste aparelho.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.consent),
              child: const Text('Revisar consentimento'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const InfoBanner(
            icon: Icons.privacy_tip_outlined,
            text: 'Registro anônimo: o app não pede nome, CPF, telefone nem localização. '
                'Só categoria, setor, descrição e a hora (sem minutos) são salvos neste aparelho.',
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _category,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: [for (final c in OccurrenceCategories.all) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => _category = v,
            validator: (v) => Validators.requiredChoice(v, 'Selecione a categoria'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: _sector,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Setor do bairro'),
            items: [for (final s in Territory.sectors) DropdownMenuItem(value: s, child: Text(s))],
            onChanged: (v) => _sector = v,
            validator: (v) => Validators.requiredChoice(v, 'Selecione o setor'),
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _descriptionController,
            maxLength: 200,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              helperText: 'Não inclua nomes, CPF, telefone, e-mail ou endereço completo.',
              helperMaxLines: 2,
              alignLabelWithHint: true,
            ),
            validator: Validators.description,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send),
            label: Text(_saving ? 'Salvando...' : 'Registrar ocorrência'),
          ),
        ],
      ),
    );
  }
}