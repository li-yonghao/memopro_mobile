import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/memo.dart';

class MemoService extends ChangeNotifier {
  MemoService._();
  static final MemoService instance = MemoService._();

  static const String _memosKey = 'memopro_memos';
  static const String _darkModeKey = 'memopro_dark_mode';
  static const String _fontSizeKey = 'memopro_font_size';

  List<Memo> _memos = [];
  bool _isDarkMode = false;
  double _fontSize = 16.0;
  bool _initialized = false;

  List<Memo> get memos => List.unmodifiable(_memos);
  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;

  List<Memo> get pinnedMemos =>
      _memos.where((m) => m.isPinned).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<Memo> get unpinnedMemos =>
      _memos.where((m) => !m.isPinned).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<Memo> search(String query) {
    if (query.isEmpty) return _memos;
    final q = query.toLowerCase();
    return _memos
        .where((m) =>
            m.title.toLowerCase().contains(q) ||
            m.content.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<Memo> get pendingReminders => _memos
      .where((m) =>
          m.hasReminder && m.reminderTime != null && !m.reminded &&
          m.reminderTime!.isBefore(DateTime.now()))
      .toList();

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _fontSize = prefs.getDouble(_fontSizeKey) ?? 16.0;

    final memosJson = prefs.getString(_memosKey);
    if (memosJson != null) {
      try {
        final List<dynamic> list = jsonDecode(memosJson);
        _memos = list.map((e) => Memo.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _memos = [];
      }
    }
    _initialized = true;
  }

  Future<void> _saveMemos() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_memos.map((m) => m.toJson()).toList());
    await prefs.setString(_memosKey, json);
  }

  Future<bool> getIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setIsDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  double getFontSize() => _fontSize;

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(12.0, 28.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, _fontSize);
    notifyListeners();
  }

  void addMemo(Memo memo) {
    _memos.insert(0, memo);
    _saveMemos();
    notifyListeners();
  }

  void updateMemo(String id, {String? title, String? content, bool? isPinned,
      bool? hasReminder, DateTime? reminderTime, bool? reminded}) {
    final index = _memos.indexWhere((m) => m.id == id);
    if (index == -1) return;
    _memos[index] = _memos[index].copyWith(
      title: title,
      content: content,
      isPinned: isPinned,
      hasReminder: hasReminder,
      reminderTime: reminderTime,
      reminded: reminded,
    );
    _saveMemos();
    notifyListeners();
  }

  void deleteMemo(String id) {
    _memos.removeWhere((m) => m.id == id);
    _saveMemos();
    notifyListeners();
  }

  void togglePin(String id) {
    final index = _memos.indexWhere((m) => m.id == id);
    if (index == -1) return;
    _memos[index] = _memos[index].copyWith(isPinned: !_memos[index].isPinned);
    _saveMemos();
    notifyListeners();
  }

  Memo? getMemo(String id) {
    try {
      return _memos.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
