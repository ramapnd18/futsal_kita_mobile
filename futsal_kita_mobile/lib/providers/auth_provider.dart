// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // --- Three-State ---
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  bool get isLoggedIn => _user != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Login: panggil AuthService, update state sesuai hasil.
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authService.login(username, password);
      _user = await _authService.getSavedUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } on Exception catch (e) {
      _isLoading = false;
      // Buang prefix "Exception: " agar pesan lebih ramah
      final raw = e.toString();
      _errorMessage = raw.startsWith('Exception: ')
          ? raw.replaceFirst('Exception: ', '')
          : raw;
      notifyListeners();
      return false;
    }
  }

  /// Logout: bersihkan sesi dan state.
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Cek sesi tersimpan (untuk splash screen).
  Future<void> tryAutoLogin() async {
    _setLoading(true);
    final isActive = await _authService.isLoggedIn();
    if (isActive) {
      _user = await _authService.getSavedUser();
    }
    _setLoading(false);
  }
}
