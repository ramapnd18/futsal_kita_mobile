// lib/providers/transaksi_provider.dart

import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/transaksi_service.dart';

class TransaksiProvider extends ChangeNotifier {
  final TransaksiService _service = TransaksiService();

  // --- Three-State ---
  bool _isLoading = false;
  String? _errorMessage;
  List<Transaksi> _transaksis = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Transaksi> get transaksis => _transaksis;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchRiwayat() async {
    _setLoading(true);
    _setError(null);

    try {
      _transaksis = await _service.getRiwayat();
      _isLoading = false;
      notifyListeners();
    } on Exception catch (e) {
      _isLoading = false;
      final raw = e.toString();
      _errorMessage =
          raw.startsWith('Exception: ') ? raw.replaceFirst('Exception: ', '') : raw;
      notifyListeners();
    }
  }
}
