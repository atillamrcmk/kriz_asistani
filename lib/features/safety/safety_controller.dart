import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _spKey = 'safety_plan_v1';

class SafetyPlan {
  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> warningSigns;
  final List<String> copingStrategies;
  final List<String> distractions;
  final List<Contact> supportContacts;
  final List<Contact> professionalContacts;
  final List<String> meansSafety;

  SafetyPlan({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.warningSigns,
    required this.copingStrategies,
    required this.distractions,
    required this.supportContacts,
    required this.professionalContacts,
    required this.meansSafety,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'warningSigns': warningSigns,
    'copingStrategies': copingStrategies,
    'distractions': distractions,
    'supportContacts': supportContacts.map((c) => c.toMap()).toList(),
    'professionalContacts': professionalContacts.map((c) => c.toMap()).toList(),
    'meansSafety': meansSafety,
  };

  factory SafetyPlan.fromMap(Map<String, dynamic> m) => SafetyPlan(
    id: m['id'] as String? ?? const Uuid().v4(),
    createdAt:
        DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt: m['updatedAt'] != null
        ? DateTime.tryParse(m['updatedAt'] as String)
        : null,
    warningSigns: (m['warningSigns'] as List<dynamic>?)?.cast<String>() ?? [],
    copingStrategies:
        (m['copingStrategies'] as List<dynamic>?)?.cast<String>() ?? [],
    distractions: (m['distractions'] as List<dynamic>?)?.cast<String>() ?? [],
    supportContacts:
        (m['supportContacts'] as List<dynamic>?)
            ?.map((c) => Contact.fromMap(c as Map<String, dynamic>))
            .toList() ??
        [],
    professionalContacts:
        (m['professionalContacts'] as List<dynamic>?)
            ?.map((c) => Contact.fromMap(c as Map<String, dynamic>))
            .toList() ??
        [],
    meansSafety: (m['meansSafety'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}

class Contact {
  final String name;
  final String phone;
  final String? note;

  Contact({required this.name, required this.phone, this.note});

  Map<String, dynamic> toMap() => {'name': name, 'phone': phone, 'note': note};

  factory Contact.fromMap(Map<String, dynamic> m) => Contact(
    name: m['name'] as String? ?? '',
    phone: m['phone'] as String? ?? '',
    note: m['note'] as String?,
  );
}

class SafetyPlanController extends ChangeNotifier {
  SafetyPlan? _plan;
  SafetyPlan? get plan => _plan;

  Future<void> load() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final data = sp.getString(_spKey);
      if (data != null) {
        _plan = SafetyPlan.fromMap(jsonDecode(data));
      }
    } catch (e) {
      debugPrint('Load error: $e');
      _plan = null;
    }
    notifyListeners();
  }

  Future<void> save({
    required List<String> warningSigns,
    required List<String> copingStrategies,
    required List<String> distractions,
    required List<Contact> supportContacts,
    required List<Contact> professionalContacts,
    required List<String> meansSafety,
  }) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final now = DateTime.now();
      _plan = SafetyPlan(
        id: _plan?.id ?? const Uuid().v4(),
        createdAt: _plan?.createdAt ?? now,
        updatedAt: now,
        warningSigns: warningSigns.where((s) => s.isNotEmpty).toList(),
        copingStrategies: copingStrategies.where((s) => s.isNotEmpty).toList(),
        distractions: distractions.where((s) => s.isNotEmpty).toList(),
        supportContacts: supportContacts
            .where((c) => c.name.isNotEmpty && c.phone.isNotEmpty)
            .toList(),
        professionalContacts: professionalContacts
            .where((c) => c.name.isNotEmpty && c.phone.isNotEmpty)
            .toList(),
        meansSafety: meansSafety.where((s) => s.isNotEmpty).toList(),
      );
      await sp.setString(_spKey, jsonEncode(_plan!.toMap()));
      notifyListeners();
    } catch (e) {
      debugPrint('Save error: $e');
      throw Exception('Plan kaydedilemedi: $e');
    }
  }

  Future<void> clear() async {
    try {
      final sp = await SharedPreferences.getInstance();
      _plan = null;
      await sp.remove(_spKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Clear error: $e');
      throw Exception('Plan silinemedi: $e');
    }
  }
}
