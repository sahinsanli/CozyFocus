import 'package:flutter/material.dart';

import 'core/services/app_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_scope.dart';
import 'home_shell.dart';

class CozyFocusApp extends StatelessWidget {
  const CozyFocusApp({required this.controller, super.key});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => MaterialApp(
          title: 'Cozy Focus',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: controller.darkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeShell(),
        ),
      ),
    );
  }
}
