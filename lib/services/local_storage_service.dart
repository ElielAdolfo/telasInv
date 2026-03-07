import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inv_telas/models/models.dart';

class LocalStorageService {
  static const String _keyDrafts = 'draft_rollos';

  Future<List<Rollo>> getDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keyDrafts);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => Rollo.fromJson(e)).toList();
  }

  Future<void> saveDrafts(List<Rollo> rollos) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(rollos.map((e) => e.toJson()).toList());
    await prefs.setString(_keyDrafts, data);
  }

  Future<void> addDraft(Rollo rollo) async {
    final drafts = await getDrafts();
    drafts.add(rollo);
    await saveDrafts(drafts);
  }

  Future<void> removeDraft(String id) async {
    final drafts = await getDrafts();
    drafts.removeWhere((r) => r.id == id);
    await saveDrafts(drafts);
  }

  Future<void> clearDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDrafts);
  }
}
