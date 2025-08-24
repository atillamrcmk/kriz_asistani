import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'confirm.dart';

Future<void> showEmergencySheet(BuildContext context) async {
  final cs = Theme.of(context).colorScheme;

  Future<void> _call(String number) async {
    final ok1 = await showConfirm(
      context,
      title: 'Arama Onayı',
      message: '$number numarasını aramak istiyor musun?',
      confirmText: 'Ara',
    );
    if (!ok1) return;

    // Yanlış aramayı önlemek için 3 sn bekleme uyarısı
    final ok2 = await showConfirm(
      context,
      title: 'Son Onay',
      message: '3 saniye içinde arama başlayacak. Hazır mısın?',
      confirmText: 'Hazırım',
    );
    if (!ok2) return;

    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Arama başlatılamadı')));
      }
    }
  }

  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.local_fire_department, color: cs.primary),
              title: const Text('112 Acil Çağrı Merkezi'),
              onTap: () => _call('112'),
            ),
            ListTile(
              leading: Icon(Icons.support_agent, color: cs.primary),
              title: const Text('Alo 183 (Sosyal Destek)'),
              onTap: () => _call('183'),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.contact_phone, color: cs.primary),
              title: const Text('Yakın Kişiyi Ara (yakında)'),
              subtitle: const Text(
                'Ayarlar > Yakın Kişi ekleyerek aktifleştir',
              ),
              onTap: () async {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yakında: Yakın kişi seçimi')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}
