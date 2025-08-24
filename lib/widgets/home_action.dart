import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeAction extends StatelessWidget {
  const HomeAction({super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Ana Sayfa',
      icon: const Icon(Icons.home_outlined),
      onPressed: () => context.go('/'),
    );
  }
}
