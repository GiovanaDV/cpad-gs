import 'package:material_ui/material_ui.dart';
import '../models/series.dart';
import '../screens/alert_detail_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/climate_dashboard_screen.dart';
import '../screens/consent_screen.dart';
import '../screens/home_screen.dart';
import '../screens/indicator_detail_screen.dart';
import '../screens/privacy_screen.dart';
import '../screens/report_screen.dart';
import '../screens/services_dashboard_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/thresholds_screen.dart';
import '../screens/water_dashboard_screen.dart';
import '../widgets/state_view.dart';

class AppRoutes {
  static const splash = '/splash';
  static const consent = '/consent';
  static const home = '/';
  static const water = '/water';
  static const climate = '/climate';
  static const services = '/services';
  static const indicatorDetail = '/indicator';
  static const alerts = '/alerts';
  static const alertDetail = '/alert';
  static const report = '/report';
  static const settings = '/settings';
  static const about = '/about';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      splash => const SplashScreen(),
      consent => const ConsentScreen(),
      home => const HomeScreen(),
      water => const WaterDashboardScreen(),
      climate => const ClimateDashboardScreen(),
      services => const ServicesDashboardScreen(),
      indicatorDetail => IndicatorDetailScreen(series: settings.arguments as Series),
      alerts => const AlertsScreen(),
      alertDetail => AlertDetailScreen(alertId: settings.arguments as String),
      report => const ReportScreen(),
      AppRoutes.settings => const ThresholdsScreen(),
      about => const PrivacyScreen(),
      _ => const _UnknownRouteScreen(),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nexo')),
      body: StateView.empty('Tela não encontrada.'),
    );
  }
}