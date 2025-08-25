import 'package:flutter/material.dart';
import 'package:flutter_application_7/features/safety/safety_controller.dart';

class SafetyPlanView extends StatefulWidget {
  final SafetyPlanController c;
  final Function({
    required List<String> warningSigns,
    required List<String> copingStrategies,
    required List<String> distractions,
    required List<Contact> supportContacts,
    required List<Contact> professionalContacts,
    required List<String> meansSafety,
  })
  onSave;
  final VoidCallback onClear;

  const SafetyPlanView({
    super.key,
    required this.c,
    required this.onSave,
    required this.onClear,
  });

  @override
  State<SafetyPlanView> createState() => _SafetyPlanViewState();
}

class _SafetyPlanViewState extends State<SafetyPlanView> {
  final _warningSignsCtrl = TextEditingController();
  final _copingStrategiesCtrl = TextEditingController();
  final _distractionsCtrl = TextEditingController();
  final _supportContactNameCtrl = TextEditingController();
  final _supportContactPhoneCtrl = TextEditingController();
  final _supportContactNoteCtrl = TextEditingController();
  final _professionalContactNameCtrl = TextEditingController();
  final _professionalContactPhoneCtrl = TextEditingController();
  final _professionalContactNoteCtrl = TextEditingController();
  final _meansSafetyCtrl = TextEditingController();

  List<String> warningSigns = [];
  List<String> copingStrategies = [];
  List<String> distractions = [];
  List<Contact> supportContacts = [];
  List<Contact> professionalContacts = [];
  List<String> meansSafety = [];

  @override
  void initState() {
    super.initState();
    if (widget.c.plan != null) {
      warningSigns = widget.c.plan!.warningSigns;
      copingStrategies = widget.c.plan!.copingStrategies;
      distractions = widget.c.plan!.distractions;
      supportContacts = widget.c.plan!.supportContacts;
      professionalContacts = widget.c.plan!.professionalContacts;
      meansSafety = widget.c.plan!.meansSafety;
    }
  }

  @override
  void dispose() {
    _warningSignsCtrl.dispose();
    _copingStrategiesCtrl.dispose();
    _distractionsCtrl.dispose();
    _supportContactNameCtrl.dispose();
    _supportContactPhoneCtrl.dispose();
    _supportContactNoteCtrl.dispose();
    _professionalContactNameCtrl.dispose();
    _professionalContactPhoneCtrl.dispose();
    _professionalContactNoteCtrl.dispose();
    _meansSafetyCtrl.dispose();
    super.dispose();
  }

  void _addItem(List<String> list, TextEditingController ctrl) {
    final text = ctrl.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        list.add(text);
        ctrl.clear();
      });
    }
  }

  void _addContact(
    List<Contact> contacts,
    TextEditingController nameCtrl,
    TextEditingController phoneCtrl,
    TextEditingController noteCtrl,
  ) {
    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final note = noteCtrl.text.trim();
    if (name.isNotEmpty && phone.isNotEmpty) {
      setState(() {
        contacts.add(
          Contact(name: name, phone: phone, note: note.isEmpty ? null : note),
        );
        nameCtrl.clear();
        phoneCtrl.clear();
        noteCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Güvenlik Planı Oluştur',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),

        // Uyarıcılar
        _SectionHeader('1. Uyarıcılar (Kriz belirtileri neler?)'),
        TextField(
          controller: _warningSignsCtrl,
          decoration: const InputDecoration(hintText: 'Örn: Hızlı kalp atışı'),
        ),
        ElevatedButton(
          onPressed: () => _addItem(warningSigns, _warningSignsCtrl),
          child: const Text('Ekle'),
        ),
        ...warningSigns.map((s) => ListTile(title: Text(s))),

        // İçsel Başa Çıkma
        _SectionHeader('2. İçsel Başa Çıkma (Kendin ne yapabilirsin?)'),
        TextField(
          controller: _copingStrategiesCtrl,
          decoration: const InputDecoration(hintText: 'Örn: Derin nefes al'),
        ),
        ElevatedButton(
          onPressed: () => _addItem(copingStrategies, _copingStrategiesCtrl),
          child: const Text('Ekle'),
        ),
        ...copingStrategies.map((s) => ListTile(title: Text(s))),

        // Dikkat Dağıtıcılar
        _SectionHeader('3. Dikkat Dağıtıcı Aktiviteler'),
        TextField(
          controller: _distractionsCtrl,
          decoration: const InputDecoration(hintText: 'Örn: Müzik dinle'),
        ),
        ElevatedButton(
          onPressed: () => _addItem(distractions, _distractionsCtrl),
          child: const Text('Ekle'),
        ),
        ...distractions.map((s) => ListTile(title: Text(s))),

        // Destek Kişiler
        _SectionHeader('4. Destek Kişiler'),
        TextField(
          controller: _supportContactNameCtrl,
          decoration: const InputDecoration(hintText: 'İsim'),
        ),
        TextField(
          controller: _supportContactPhoneCtrl,
          decoration: const InputDecoration(hintText: 'Telefon/WhatsApp'),
        ),
        TextField(
          controller: _supportContactNoteCtrl,
          decoration: const InputDecoration(hintText: 'Not (opsiyonel)'),
        ),
        ElevatedButton(
          onPressed: () => _addContact(
            supportContacts,
            _supportContactNameCtrl,
            _supportContactPhoneCtrl,
            _supportContactNoteCtrl,
          ),
          child: const Text('Ekle'),
        ),
        ...supportContacts.map(
          (c) => ListTile(
            title: Text(c.name),
            subtitle: Text(c.phone),
            trailing: c.note != null ? Text(c.note!) : null,
          ),
        ),

        // Profesyonel Yardım
        _SectionHeader('5. Profesyonel Yardım'),
        TextField(
          controller: _professionalContactNameCtrl,
          decoration: const InputDecoration(hintText: 'İsim/Kurum'),
        ),
        TextField(
          controller: _professionalContactPhoneCtrl,
          decoration: const InputDecoration(hintText: 'Telefon'),
        ),
        TextField(
          controller: _professionalContactNoteCtrl,
          decoration: const InputDecoration(hintText: 'Not (opsiyonel)'),
        ),
        ElevatedButton(
          onPressed: () => _addContact(
            professionalContacts,
            _professionalContactNameCtrl,
            _professionalContactPhoneCtrl,
            _professionalContactNoteCtrl,
          ),
          child: const Text('Ekle'),
        ),
        ...professionalContacts.map(
          (c) => ListTile(
            title: Text(c.name),
            subtitle: Text(c.phone),
            trailing: c.note != null ? Text(c.note!) : null,
          ),
        ),

        // Erişim Kısıtlama
        _SectionHeader('6. Erişim Kısıtlama (Güvenli ortam)'),
        TextField(
          controller: _meansSafetyCtrl,
          decoration: const InputDecoration(
            hintText: 'Örn: Kesici aletleri kilitle',
          ),
        ),
        ElevatedButton(
          onPressed: () => _addItem(meansSafety, _meansSafetyCtrl),
          child: const Text('Ekle'),
        ),
        ...meansSafety.map((s) => ListTile(title: Text(s))),

        const SizedBox(height: 16),

        // Kaydet ve Temizle
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => widget.onSave(
                  warningSigns: warningSigns,
                  copingStrategies: copingStrategies,
                  distractions: distractions,
                  supportContacts: supportContacts,
                  professionalContacts: professionalContacts,
                  meansSafety: meansSafety,
                ),
                icon: const Icon(Icons.save),
                label: const Text('Kaydet'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: widget.onClear,
              icon: const Icon(Icons.clear),
              label: const Text('Temizle'),
            ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
}
