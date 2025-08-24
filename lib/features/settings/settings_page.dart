import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/home_action.dart';
import '../../core/utils/emergency_sheet.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoNightMode = true;
  bool _notifications = true; // ileride gerçek bildirim izniyle bağlarız

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        actions: const [HomeAction()],
      ),
      body: ListView(
        children: [
          // GÖRÜNÜM
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Görünüm',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SwitchListTile(
            title: const Text('Gece Modu (otomatik)'),
            subtitle: const Text('22:00–06:00 arasında göz yormayan tema'),
            value: _autoNightMode,
            onChanged: (v) {
              setState(() => _autoNightMode = v);
              _snack(
                v
                    ? 'Gece modu otomatik açılacak..'
                    : 'Gece modu otomatik kapalı.',
              );
            },
          ),

          // BİLDİRİMLER
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Bildirimler',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SwitchListTile(
            title: const Text('Hatırlatmalar'),
            subtitle: const Text(
              'Akşam saatlerinde kısa nefes/rahatlama önerileri',
            ),
            value: _notifications,
            onChanged: (v) {
              setState(() => _notifications = v);
              _snack(v ? 'Hatırlatmalar açıldı.' : 'Hatırlatmalar kapatıldı.');
            },
          ),

          // GÜVENLİK & GİZLİLİK
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Güvenlik ve Gizlilik',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: cs.primary),
            title: const Text('KVKK ve Açık Rıza'),
            subtitle: const Text('Veri işleme politikaları ve hakların'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // ileride ayrı sayfaya gidecek
              _snack('KVKK metni yakında.');
            },
          ),
          ListTile(
            leading: Icon(Icons.record_voice_over, color: cs.primary),
            title: const Text('Sevilen Ses (yakında)'),
            subtitle: const Text('Yakınından izinli ses kaydı ekle'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _snack('Ses kütüphanesi yakında.'),
          ),
          ListTile(
            leading: Icon(Icons.contact_phone, color: cs.primary),
            title: const Text('Yakın Kişi (yakında)'),
            subtitle: const Text('Acil durumda aranacak kişi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _snack('Rehberden kişi seçimi yakında.'),
          ),

          // ACİL
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Acil Durum',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ListTile(
            leading: Icon(Icons.phone_in_talk, color: cs.primary),
            title: const Text('Acil Yardım Testi'),
            subtitle: const Text('112 / Alo 183 için çift onay akışını dene'),
            onTap: () => showEmergencySheet(context),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // HAKKINDA
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Hakkında'),
            subtitle: const Text('Kriz Asistanı • Sürüm 0.1.0'),
            onTap: () => context.go('/'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
