import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doc_gia.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final _api = ApiService.instance;
  String? token;
  DocGia? user;
  ThemeMode themeMode = ThemeMode.light;
  bool ready = false;

  bool get isLoggedIn => token != null && user != null;

  Future<void> init() async {
    _api.onUnauthorized = () => logout();
    try {
      final p = await SharedPreferences.getInstance();
      final t = p.getString('token');
      final u = p.getString('user');
      final tm = p.getString('themeMode');
      if (tm == 'dark') themeMode = ThemeMode.dark;
      if (t != null && u != null) {
        token = t;
        _api.token = t;
        user = DocGia.fromJson(jsonDecode(u));
        // Xác thực lại token ở nền
        try {
          user = await _api.me();
          await _persist();
        } on ApiException catch (e) {
          if (e.statusCode == 401) await logout();
        }
      }
    } catch (_) {}
    ready = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    if (token != null && user != null) {
      await p.setString('token', token!);
      await p.setString('user', jsonEncode(user!.toJson()));
    } else {
      await p.remove('token');
      await p.remove('user');
    }
  }

  Future<void> login(String email, String matkhau) async {
    final r = await _api.login(email, matkhau);
    token = r.token;
    user = r.user;
    _api.token = token;
    await _persist();
    notifyListeners();
  }

  Future<void> logout() async {
    if (token == null && user == null) return;
    token = null;
    user = null;
    _api.token = null;
    await _persist();
    notifyListeners();
  }

  Future<void> refreshMe() async {
    user = await _api.me();
    await _persist();
    notifyListeners();
  }

  Future<void> setDark(bool dark) async {
    themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('themeMode', dark ? 'dark' : 'light');
    } catch (_) {}
  }
}

/// Instance dung chung toan ung dung.
final AuthService auth = AuthService();
