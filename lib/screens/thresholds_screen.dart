import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/alert_thresholds.dart';
import '../core/app_theme.dart';
import '../core/validators.dart';
import '../providers/settings_provider.dart';
import '../widgets/info_banner.dart';

class ThresholdsScreen extends StatefulWidget {
  const ThresholdsScreen({super.key});

  @override
  State<ThresholdsScreen> createState() => _ThresholdsScreenState();
}

class _ThresholdsScreenState extends State<ThresholdsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _water = TextEditingController();
  final _heat = TextEditingController();
  final _rain = TextEditingController();
  final _occurrences = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fill(context.read<SettingsProvider>().thresholds);
  }

  @override
  void dispose() {
    _water.dispose();
    _heat.dispose();
    _rain.dispose();
    _occurrences.dispose();
    super.dispose();
  }

  void _fill(AlertThresholds t) {
    _water.text = _fmt(t.waterTrendPercent);
    _heat.text = _fmt(t.heatTempC);
    _rain.text = _fmt(t.rainDailyMm);
    _occurrences.text = t.openOccurrences.toString();
  }

  static String _fmt(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString().replaceAll('.', ',');

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final settings = context.read<SettingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await settings.saveThresholds(AlertThresholds(
      waterTrendPercent: Validators.parseNumber(_water.text)!,
      heatTempC: Validators.parseNumber(_heat.text)!,
      rainDailyMm: Validators.parseNumber(_rain.text)!,
      openOccurrences: Validators.parseNumber(_occurrences.text)!.round(),
    ));
    messenger.showSnackBar(const SnackBar(content: Text('Limiares salvos. Os alertas foram recalculados.')));
    navigator.pop();
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required String helper,
    required double min,
    required double max,
    bool integer = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: !integer),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(integer ? r'[0-9]' : r'[0-9.,]'))],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(labelText: label, suffixText: suffix, helperText: helper, helperMaxLines: 3),
        validator: (v) => Validators.number(v, min: min, max: max, integer: integer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Limiares de alerta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const InfoBanner(
              icon: Icons.balance,
              text: 'Limiares baixos detectam problemas mais cedo, mas geram mais falsos alarmes. '
                  'Limiares altos reduzem falsos alarmes, mas podem deixar passar problemas. '
                  'O equilíbrio é uma decisão do gestor.',
            ),
            const SizedBox(height: AppSpacing.md),
            _field(
              controller: _water,
              label: 'Alta de consumo de água',
              suffix: '%',
              helper: 'Alerta quando o consumo de um setor sobe mais que isso em 7 dias. Faixa: 1 a 100.',
              min: 1,
              max: 100,
            ),
            _field(
              controller: _heat,
              label: 'Temperatura máxima prevista',
              suffix: '°C',
              helper: 'Alerta de calor quando a previsão dos próximos 7 dias passa desse valor. Faixa: 20 a 50.',
              min: 20,
              max: 50,
            ),
            _field(
              controller: _rain,
              label: 'Chuva diária prevista',
              suffix: 'mm',
              helper: 'Alerta de chuva forte quando a previsão passa desse volume por dia. Faixa: 5 a 200.',
              min: 5,
              max: 200,
            ),
            _field(
              controller: _occurrences,
              label: 'Ocorrências abertas por setor',
              suffix: 'ocorr.',
              helper: 'Alerta quando um setor acumula esta quantidade de ocorrências abertas. Faixa: 1 a 20.',
              min: 1,
              max: 20,
              integer: true,
            ),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar limiares'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: () {
                setState(() => _fill(const AlertThresholds()));
                _formKey.currentState?.validate();
              },
              icon: const Icon(Icons.restore),
              label: const Text('Restaurar valores padrão'),
            ),
          ],
        ),
      ),
    );
  }
}