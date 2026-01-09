import 'package:flutter/material.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

class EraBmsApp extends StatelessWidget {
  const EraBmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ERA BMS',
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
