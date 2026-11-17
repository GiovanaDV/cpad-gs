import 'package:flutter/material.dart';
import '../models/series.dart';
import '../screens/climate_dashboard_screen.dart';
import '../screens/home_screen.dart';
import '../screens/indicator_detail_screen.dart';
import '../screens/placeholder_screen.dart';
import '../screens/services_dashboard_screen.dart';
import '../screens/water_dashboard_screen.dart';

class AppRoutes {
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

  static const _titles = {
    alerts: 'Alertas',
    alertDetail: 'Detalhe do alerta',
    report: 'Registrar ocorrência',
    settings: 'Limiares de alerta',
    about: 'Privacidade e sobre',
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      home => const HomeScreen(),
      water => const WaterDashboardScreen(),
      climate => const ClimateDashboardScreen(),
      services => const ServicesDashboardScreen(),
      indicatorDetail => IndicatorDetailScreen(series: settings.arguments as Series),
      _ => PlaceholderScreen(title: _titles[settings.name] ?? 'Nexo', args: settings.arguments),
    };
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}