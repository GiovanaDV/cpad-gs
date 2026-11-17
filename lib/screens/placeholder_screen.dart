import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/state_view.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final Object? args;

  const PlaceholderScreen({super.key, required this.title, this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: StateView.empty('Tela "$title" em construção.\nParâmetro recebido: ${args ?? "nenhum"}'),
      ),
    );
  }
}