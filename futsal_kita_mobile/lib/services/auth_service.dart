// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:5050/api/auth';

  static const String _keyToken = 'accessToken';
  static const String _keyUser = 'userData';

  /// Login dengan username & password.
  /// Mengembalikan [true] jika sukses, melempar [Exception] jika gagal.
  Future<bool> login(String username, String password) async {
    final uri = Uri.parse('$_baseUrl/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final String token = body['accessToken'] as String;
      final User user = User.fromJson(body['user'] as Map<String, dynamic>);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyUser, jsonEncode(user.toJson()));

      return true;
    } else {
      final String message =
          body['message'] as String? ?? 'Terjadi kesalahan, coba lagi.';
      throw Exception(message);
    }
  }

  /// Logout: hapus token dan data user dari SharedPreferences.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  /// Ambil token yang tersimpan, atau null jika belum login.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Ambil data user yang tersimpan, atau null jika belum login.
  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Cek apakah sesi login masih aktif (token tersimpan).
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
