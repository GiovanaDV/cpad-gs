import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_routes.dart';
import '../core/app_theme.dart';
import '../widgets/nexo_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 800),
          builder: (_, value, child) => Opacity(opacity: value, child: child),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/nexo_icon.png', width: 180, semanticLabel: 'Logo do Nexo'),
              const SizedBox(height: AppSpacing.lg),
              const NexoWordmark(height: 56),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'conexão entre dados, território e pessoas',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.navy),
              ),
            ],
          ),
        ),
      ),
    );
  }
}