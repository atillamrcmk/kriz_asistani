// lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _tile(BuildContext ctx, String title, String path, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(title),
      onPressed: () => ctx.push(path), // go yerine push kullanıyorsun
      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kriz Asistanı')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _tile(context, '⚡ Hemen Destek', '/panic', Icons.bolt),
            const SizedBox(height: 12),
            _tile(context, '🤖 Duygu Analizi', '/triage', Icons.psychology),
            const SizedBox(height: 12),
            _tile(context, '📓 Günlük', '/journal', Icons.book_rounded),
            const SizedBox(height: 12),
            _tile(
              context,
              '🧘 Egzersizler',
              '/exercises',
              Icons.self_improvement,
            ),
            const SizedBox(height: 12),
            _tile(context, '📈 İstatistikler', '/stats', Icons.show_chart),
            const SizedBox(height: 12),
            _tile(context, '⚙️ Ayarlar', '/settings', Icons.settings),
            const SizedBox(height: 12),
            // ✅ Yeni sohbet girişi
            _tile(
              context,
              '💬 Sohbet (Gemini)',
              '/chat',
              Icons.chat_bubble_outline,
            ),
          ],
        ),
      ),
    );
  }
}
