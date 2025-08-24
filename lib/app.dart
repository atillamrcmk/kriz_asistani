import 'package:flutter/material.dart';
import 'core/router.dart';
import 'core/theme.dart';

class KrizAsistaniApp extends StatelessWidget {
  const KrizAsistaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kriz Asistanı',
      theme: buildTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
