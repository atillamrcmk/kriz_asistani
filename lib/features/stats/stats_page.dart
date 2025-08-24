import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler')),
      body: const Center(child: Text('Grafikler burada olacak.')),
    );
  }
}
