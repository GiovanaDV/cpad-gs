import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/load_status.dart';
import '../providers/occurrences_provider.dart';
import '../providers/territory_provider.dart';
import 'app_card.dart';
import 'state_view.dart';

class DataStatusCard extends StatelessWidget {
  const DataStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TerritoryProvider>();
    final o = context.watch<OccurrencesProvider>();

    if (t.status == LoadStatus.loading || o.status == LoadStatus.loading) {
      return AppCard(child: StateView.loading());
    }
    if (t.status == LoadStatus.error) {
      return AppCard(child: StateView.error(t.errorMessage!, onRetry: t.load));
    }
    if (o.status == LoadStatus.error) {
      return AppCard(child: StateView.error(o.errorMessage!, onRetry: o.load));
    }

    final source = t.weatherFromCache ? 'salvo (offline)' : 'ao vivo (Open-Meteo)';
    return AppCard(
      semanticLabel: 'Resumo dos dados carregados',
      child: Text(
        '${t.water.length} leituras de água · ${t.weather.length} dias de clima\n'
        '${o.items.length} ocorrências · clima: $source',
      ),
    );
  }
}