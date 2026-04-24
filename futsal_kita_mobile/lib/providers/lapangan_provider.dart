// lib/providers/lapangan_provider.dart

import 'package:flutter/material.dart';
import '../models/lapangan.dart';
import '../services/lapangan_service.dart';

class LapanganProvider extends ChangeNotifier {
  final LapanganService _service = LapanganService();

  // --- Three-State ---
  bool _isLoading = false;
  String? _errorMessage;
  List<Lapangan> _lapangans = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Lapangan> get lapangans => _lapangans;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchLapangans() async {
    _setLoading(true);
    _setError(null);

    try {
      _lapangans = await _service.getLapangan();
      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _isLoading = false;
      final raw = e.toString();
      _errorMessage = raw.startsWith('Exception: ')
          ? raw.replaceFirst('Exception: ', '')
          : raw;
      notifyListeners();
    }
  }
}
