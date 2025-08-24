import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_7/core/utils/emergency_sheet.dart';
import 'package:flutter_application_7/widgets/home_action.dart';

class QuickAidPage extends StatefulWidget {
  const QuickAidPage({super.key});
  @override
  State<QuickAidPage> createState() => _QuickAidPageState();
}

class _QuickAidPageState extends State<QuickAidPage> {
  int phase = 0; // 0: al, 1: tut, 2: ver
  int secs = 4;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    phase = 0;
    secs = 4;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        secs--;
        if (secs <= 0) {
          if (phase == 0) {
            phase = 1;
            secs = 4;
          } else if (phase == 1) {
            phase = 2;
            secs = 6;
          } else {
            phase = 0;
            secs = 4;
          }
        }
      });
    });
  }

  String get label => switch (phase) {
    0 => 'Nefes al',
    1 => 'Tut',
    _ => 'Ver',
  };

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('1 Dakikada Sakinleş'),
        actions: const [HomeAction()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [cs.primary, cs.primaryContainer.withOpacity(0.2)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text('$label\n$secs', textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              const Text('4-4-6 döngüsünü 3 tur tamamla.'),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: _start,
                child: const Text('Yeniden Başlat'),
              ),
              TextButton.icon(
                onPressed: () => showEmergencySheet(context),
                icon: const Icon(Icons.phone),
                label: const Text('Acil Yardım Seçenekleri'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
