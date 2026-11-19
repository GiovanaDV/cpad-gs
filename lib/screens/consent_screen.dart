import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/bullet_list.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreed = false;

  Future<void> _finish(bool accepted) async {
    final settings = context.read<SettingsProvider>();
    final navigator = Navigator.of(context);
    await settings.setConsent(accepted);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidade e consentimento')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Icon(Icons.privacy_tip_outlined, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.sm),
          Text('Sua privacidade no Nexo', style: text.headlineMedium),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Você pode usar os painéis e os alertas sem aceitar. O consentimento é necessário apenas '
            'para registrar ocorrências, que é o único recurso que guarda um texto escrito por você.',
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('O que o Nexo guarda', style: text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                const BulletList(
                  icon: Icons.check_circle_outline,
                  items: [
                    'Categoria, setor e descrição da ocorrência que você escrever.',
                    'A hora do registro, arredondada (sem minutos).',
                    'Suas decisões sobre alertas e os limiares que você configurar.',
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('O que o Nexo NÃO coleta', style: text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                const BulletList(
                  icon: Icons.block,
                  items: [
                    'Nome, CPF, telefone, e-mail ou endereço.',
                    'Sua localização (GPS). Só as coordenadas do bairro são usadas para buscar o clima.',
                    'Identificadores do aparelho ou da sua conta.',
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Onde ficam os dados e seus direitos', style: text.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                const BulletList(
                  icon: Icons.phone_android,
                  items: [
                    'Os dados ficam somente neste aparelho. Nenhuma ocorrência é enviada a servidores.',
                    'Você pode revogar o consentimento e apagar seus dados a qualquer momento, na tela de privacidade.',
                    'Não escreva dados pessoais na descrição. O app bloqueia CPF, telefone e e-mail.',
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          CheckboxListTile(
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Li e concordo com o tratamento descrito acima para registrar ocorrências neste aparelho.'),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: _agreed ? () => _finish(true) : null,
            child: const Text('Aceitar e continuar'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: () => _finish(false),
            child: const Text('Usar sem registrar ocorrências'),
          ),
        ],
      ),
    );
  }
}