import 'package:flutter/material.dart';
import '../../core/utils/emergency_sheet.dart';
import '../../core/theme/theme_controller.dart';
import 'settings_controller.dart';

class SettingsView extends StatelessWidget {
  final SettingsController c;
  final ThemeController themeC;
  final VoidCallback onBackToHome;

  const SettingsView({
    super.key,
    required this.c,
    required this.themeC,
    required this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      children: [
        const _SectionHeader('Tema Seçimi'),
        _ThemeRadioTile(
          title: 'Açık Tema',
          icon: Icons.light_mode,
          value: ThemeMode.light,
          group: themeC.themeMode,
          onChanged: (m) => themeC.setMode(m),
        ),
        _ThemeRadioTile(
          title: 'Koyu Tema',
          icon: Icons.dark_mode,
          value: ThemeMode.dark,
          group: themeC.themeMode,
          onChanged: (m) => themeC.setMode(m),
        ),
        _ThemeRadioTile(
          title: 'Sistem Varsayılanı',
          icon: Icons.phone_android,
          value: ThemeMode.system,
          group: themeC.themeMode,
          onChanged: (m) => themeC.setMode(m),
        ),

        const _SectionHeader('Bildirimler'),
        SwitchListTile(
          title: const Text('Hatırlatmalar'),
          subtitle: const Text(
            'Akşam saatlerinde kısa nefes/rahatlama önerileri',
          ),
          value: c.eveningReminders,
          onChanged: (v) => c.setReminders(v),
        ),

        const _SectionHeader('Egzersiz'),
        ListTile(
          leading: Icon(Icons.flag_circle_outlined, color: cs.primary),
          title: const Text('Günlük Egzersiz Hedefi'),
          subtitle: Text('${c.dailyExerciseGoal} / gün'),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: c.dailyExerciseGoal,
              onChanged: (v) {
                if (v != null) c.setDailyGoal(v);
              },
              items: const [2, 3, 4, 5, 6, 8, 10, 12]
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                  .toList(),
            ),
          ),
        ),

        const _SectionHeader('Acil Durum'),
        ListTile(
          leading: Icon(Icons.phone_in_talk, color: cs.primary),
          title: const Text('Acil Yardım Testi'),
          subtitle: const Text('112 / Alo 183 için çift onay akışını dene'),
          onTap: () => showEmergencySheet(context),
        ),

        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Hakkında'),
          subtitle: Text(c.appVersionText),
          onTap: onBackToHome,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _ThemeRadioTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode group;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeRadioTile({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.group,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Radio<ThemeMode>(
        value: value,
        groupValue: group,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
      onTap: () => onChanged(value),
    );
  }
}
