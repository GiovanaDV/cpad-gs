import 'package:material_ui/material_ui.dart';
import '../core/app_theme.dart';

/// Ícone do Nexo em círculo branco (legível sobre a AppBar roxa).
class NexoMark extends StatelessWidget {
  final double size;
  const NexoMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: ClipOval(
        child: Image.asset('assets/images/nexo_icon.png', fit: BoxFit.cover, semanticLabel: 'Logo do Nexo'),
      ),
    );
  }
}

/// Nome "Nexo" estilizado (com o X em onda).
class NexoWordmark extends StatelessWidget {
  final double height;
  const NexoWordmark({super.key, this.height = 56});

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/nexo_wordmark.png', height: height, semanticLabel: 'Nexo');
  }
}

/// Cartão de marca: nome estilizado + slogan. Sempre sobre fundo branco.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const NexoWordmark(height: 52),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'conexão entre dados, território e pessoas',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.navy),
          ),
        ],
      ),
    );
  }
}