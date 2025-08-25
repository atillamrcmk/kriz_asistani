import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_application_7/features/hope_box/hope_box_controller.dart';

class HopeBoxView extends StatefulWidget {
  final HopeBoxController c;
  final Function(XFile) onAddPhoto;
  final Function(String) onAddAudio;
  final Function(String) onAddReason;
  final Function(String) onAddMessage;
  final Function(String) onRemove;

  const HopeBoxView({
    super.key,
    required this.c,
    required this.onAddPhoto,
    required this.onAddAudio,
    required this.onAddReason,
    required this.onAddMessage,
    required this.onRemove,
  });

  @override
  State<HopeBoxView> createState() => _HopeBoxViewState();
}

class _HopeBoxViewState extends State<HopeBoxView> {
  final _reasonCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  late final AudioPlayer _player; // Doğru tanımlama

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _messageCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final status = await Permission.photos.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraf izni reddedildi.')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null && mounted) {
      await widget.onAddPhoto(photo);
    }
  }

  Future<void> _recordAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mikrofon izni reddedildi.')),
        );
      }
      return;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/hope_box/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    // await AudioRecorder.start(path: path, audioOutputFormat: AudioOutputFormat.AAC);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ses Kaydediliyor'),
        content: const Text('Kaydı durdurmak için Tamam\'a basın.'),
        actions: [
          TextButton(
            onPressed: () async {
              // await AudioRecorder.stop();
              if (mounted) {
                await widget.onAddAudio(path);
                Navigator.pop(context);
              }
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Umut Kutusu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionButton(
              icon: Icons.photo,
              label: 'Fotoğraf Ekle',
              onTap: _pickPhoto,
            ),
            _ActionButton(
              icon: Icons.mic,
              label: 'Ses Kaydı Ekle',
              onTap: _recordAudio,
            ),
            _ActionButton(
              icon: Icons.favorite,
              label: 'Yaşama Nedeni Ekle',
              onTap: () => _showTextDialog(
                'Yaşama Nedeni',
                _reasonCtrl,
                widget.onAddReason,
              ),
            ),
            _ActionButton(
              icon: Icons.message,
              label: 'Destek Mesajı Ekle',
              onTap: () => _showTextDialog(
                'Destek Mesajı',
                _messageCtrl,
                widget.onAddMessage,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.c.items.map((item) {
          return _ItemCard(
            item: item,
            onRemove: () => widget.onRemove(item.id),
            onPlayAudio: item.type == 'audio'
                ? () async {
                    if (mounted) {
                      try {
                        await _player.setFilePath(item.pathOrText);
                        await _player.play();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ses oynatma hatası: $e')),
                        );
                      }
                    }
                  }
                : null,
          );
        }),
      ],
    );
  }

  void _showTextDialog(
    String title,
    TextEditingController ctrl,
    Function(String) onSubmit,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(hintText: 'Yazınız...'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                onSubmit(ctrl.text.trim());
                ctrl.clear();
              }
              Navigator.pop(context);
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: cs.onPrimary),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final HopeBoxItem item;
  final VoidCallback onRemove;
  final VoidCallback? onPlayAudio;

  const _ItemCard({
    required this.item,
    required this.onRemove,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (item.type) {
      case 'photo':
        content = Image.file(
          File(item.pathOrText),
          height: 100,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        );
        break;
      case 'audio':
        content = Row(
          children: [
            IconButton(
              icon: const Icon(Icons.play_circle),
              onPressed: onPlayAudio,
            ),
            Expanded(child: Text('Ses Kaydı: ${item.createdAt.toString()}')),
          ],
        );
        break;
      case 'reason':
      case 'message':
        content = Text(item.pathOrText);
        break;
      default:
        content = const Text('Bilinmeyen öğe');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(child: content),
            IconButton(icon: const Icon(Icons.delete), onPressed: onRemove),
          ],
        ),
      ),
    );
  }
}
