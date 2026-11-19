import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'providers/alerts_provider.dart';
import 'providers/occurrences_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/territory_provider.dart';

void main() => runApp(const NexoApp());

class NexoApp extends StatelessWidget {
  const NexoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TerritoryProvider()..load()),
        ChangeNotifierProvider(create: (_) => OccurrencesProvider()..load()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
        ChangeNotifierProvider(
          lazy: false,
          create: (ctx) => AlertsProvider(
            ctx.read<TerritoryProvider>(),
            ctx.read<OccurrencesProvider>(),
            ctx.read<SettingsProvider>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Nexo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}