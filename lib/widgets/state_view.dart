import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class StateView extends StatelessWidget {
  final IconData? icon;
  final String message;
  final bool loading;
  final VoidCallback? onRetry;

  const StateView._({this.icon, required this.message, this.loading = false, this.onRetry});

  factory StateView.loading([String message = 'Carregando dados...']) =>
      StateView._(message: message, loading: true);

  factory StateView.error(String message, {VoidCallback? onRetry}) =>
      StateView._(icon: Icons.error_outline, message: message, onRetry: onRetry);

  factory StateView.empty(String message) =>
      StateView._(icon: Icons.inbox_outlined, message: message);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading) const CircularProgressIndicator() else Icon(icon, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(message, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}