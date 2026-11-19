import 'package:material_ui/material_ui.dart';
import '../core/load_status.dart';
import 'state_view.dart';

class StatusGate extends StatelessWidget {
  final LoadStatus status;
  final String? error;
  final VoidCallback onRetry;
  final WidgetBuilder builder;

  const StatusGate({
    super.key,
    required this.status,
    required this.error,
    required this.onRetry,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      LoadStatus.loading => StateView.loading(),
      LoadStatus.error => StateView.error(error ?? 'Ocorreu um erro.', onRetry: onRetry),
      LoadStatus.ready => builder(context),
    };
  }
}