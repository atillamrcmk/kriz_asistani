import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showEmergencySheet(BuildContext context) async {
  final cs = Theme.of(context).colorScheme;

  await showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acil Yardım',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.phone, color: cs.primary),
              title: const Text('112 Acil Çağrı'),
              onTap: () => launchUrl(Uri.parse('tel:112')),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: cs.primary),
              title: const Text('Alo 183 Sosyal Destek'),
              subtitle: const Text('Şiddet, istismar, sosyal destek'),
              onTap: () => launchUrl(Uri.parse('tel:183')),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: cs.primary),
              title: const Text('YEDAM 115 (Bağımlılık Desteği)'),
              subtitle: const Text('Bağımlılık ve eş tanılı krizler'),
              onTap: () => launchUrl(Uri.parse('tel:115')),
            ),
            const SizedBox(height: 16),
            Text(
              'Not: Acil durumlarda lütfen tereddüt etmeden 112’yi arayın.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    ),
  );
}
