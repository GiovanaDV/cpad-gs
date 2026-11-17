import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/placeholder_screen.dart';

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
    water: 'Consumo de água',
    climate: 'Clima local',
    services: 'Serviços e ocorrências',
    indicatorDetail: 'Detalhe do indicador',
    alerts: 'Alertas',
    alertDetail: 'Detalhe do alerta',
    report: 'Registrar ocorrência',
    settings: 'Limiares de alerta',
    about: 'Privacidade e sobre',
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == home) {
      return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings);
    }
    final title = _titles[settings.name] ?? 'Nexo';
    return MaterialPageRoute(
      builder: (_) => PlaceholderScreen(title: title, args: settings.arguments),
      settings: settings,
    );
  }
}