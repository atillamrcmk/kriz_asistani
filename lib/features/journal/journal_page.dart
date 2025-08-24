import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});
  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final _ctrl = TextEditingController();
  List<String> _list = [];

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    setState(() => _list = sp.getStringList('journal') ?? []);
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    final sp = await SharedPreferences.getInstance();
    _list.insert(0, '${DateTime.now().toIso8601String()}|${_ctrl.text.trim()}');
    await sp.setStringList('journal', _list);
    _ctrl.clear();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Günlük')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ctrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Bugün ne oldu?',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton(onPressed: _save, child: const Text('Kaydet')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _load, child: const Text('Yenile')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _list.isEmpty
                  ? const Center(child: Text('Kayıt yok.'))
                  : ListView.separated(
                      itemCount: _list.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) {
                        final p = _list[i].split('|');
                        final dt = DateTime.tryParse(p.first) ?? DateTime.now();
                        final text = p.length > 1 ? p[1] : '';
                        return ListTile(
                          title: Text(text),
                          subtitle: Text(dt.toLocal().toString()),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
