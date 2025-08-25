import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; // Yeni: path_provider içe aktarımı
import 'package:permission_handler/permission_handler.dart'; // Yeni: İzin yönetimi
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _spKey = 'hope_box_v1';

class HopeBoxItem {
  final String id;
  final String type; // 'photo', 'audio', 'reason', 'message'
  final String pathOrText; // Dosya yolu veya metin
  final DateTime createdAt;

  HopeBoxItem({
    required this.id,
    required this.type,
    required this.pathOrText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'pathOrText': pathOrText,
    'createdAt': createdAt.toIso8601String(),
  };

  factory HopeBoxItem.fromMap(Map<String, dynamic> m) => HopeBoxItem(
    id: m['id'] as String? ?? const Uuid().v4(),
    type: m['type'] as String? ?? '',
    pathOrText: m['pathOrText'] as String? ?? '',
    createdAt:
        DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class HopeBoxController extends ChangeNotifier {
  List<HopeBoxItem> _items = [];
  List<HopeBoxItem> get items => _items;

  Future<void> load() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final data = sp.getString(_spKey);
      if (data != null) {
        final List<dynamic> json = jsonDecode(data);
        _items = json.map((m) => HopeBoxItem.fromMap(m)).toList();
      }
    } catch (e) {
      debugPrint('HopeBox load error: $e');
      _items = [];
    }
    notifyListeners();
  }

  Future<void> addPhoto(XFile? photo) async {
    if (photo == null) {
      debugPrint('Photo is null');
      throw Exception('Fotoğraf seçilmedi.');
    }

    try {
      // Depolama izni kontrolü
      final status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        debugPrint('Storage permission denied');
        throw Exception('Depolama izni reddedildi.');
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.jpg';
      final path = '${dir.path}/hope_box/$fileName';
      await Directory('${dir.path}/hope_box').create(recursive: true);
      await photo.saveTo(path);

      _items.add(
        HopeBoxItem(
          id: const Uuid().v4(),
          type: 'photo',
          pathOrText: path,
          createdAt: DateTime.now(),
        ),
      );
      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Add photo error: $e');
      throw Exception('Fotoğraf eklenemedi: $e');
    }
  }

  Future<void> addAudio(String path) async {
    try {
      // Depolama izni kontrolü
      final status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        debugPrint('Storage permission denied');
        throw Exception('Depolama izni reddedildi.');
      }

      _items.add(
        HopeBoxItem(
          id: const Uuid().v4(),
          type: 'audio',
          pathOrText: path,
          createdAt: DateTime.now(),
        ),
      );
      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Add audio error: $e');
      throw Exception('Ses kaydı eklenemedi: $e');
    }
  }

  Future<void> addReason(String text) async {
    try {
      _items.add(
        HopeBoxItem(
          id: const Uuid().v4(),
          type: 'reason',
          pathOrText: text,
          createdAt: DateTime.now(),
        ),
      );
      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Add reason error: $e');
      throw Exception('Yaşama nedeni eklenemedi: $e');
    }
  }

  Future<void> addMessage(String text) async {
    try {
      _items.add(
        HopeBoxItem(
          id: const Uuid().v4(),
          type: 'message',
          pathOrText: text,
          createdAt: DateTime.now(),
        ),
      );
      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Add message error: $e');
      throw Exception('Destek mesajı eklenemedi: $e');
    }
  }

  Future<void> remove(String id) async {
    try {
      final item = _items.firstWhere((i) => i.id == id);
      if (item.type == 'photo' || item.type == 'audio') {
        final file = File(item.pathOrText);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _items.removeWhere((i) => i.id == id);
      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Remove item error: $e');
      throw Exception('Öğe silinemedi: $e');
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(
        _spKey,
        jsonEncode(_items.map((i) => i.toMap()).toList()),
      );
    } catch (e) {
      debugPrint('Save to prefs error: $e');
      throw Exception('Veriler kaydedilemedi: $e');
    }
  }
}
