// lib/providers/lapangan_provider.dart

import 'package:flutter/material.dart';
import '../models/lapangan.dart';
import '../services/lapangan_service.dart';

class LapanganProvider extends ChangeNotifier {
  final LapanganService _service = LapanganService();

  // --- Three-State (fetch) ---
  bool _isLoading = false;
  String? _errorMessage;
  List<Lapangan> _lapangans = [];

  // --- State mutasi (create/update/delete) ---
  bool _isMutating = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Lapangan> get lapangans => _lapangans;
  bool get isMutating => _isMutating;

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }
  void _setError(String? m) { _errorMessage = m; notifyListeners(); }
  void _setMutating(bool v) { _isMutating = v; notifyListeners(); }

  String _cleanError(Exception e) {
    final raw = e.toString();
    return raw.startsWith('Exception: ') ? raw.replaceFirst('Exception: ', '') : raw;
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
      _errorMessage = _cleanError(e);
      notifyListeners();
    }
  }

  /// Tambah lapangan baru. Melempar Exception jika gagal.
  Future<bool> tambahLapangan({
    required String namaLapangan,
    required int hargaPerJam,
  }) async {
    _setMutating(true);
    try {
      final ok = await _service.createLapangan(
        namaLapangan: namaLapangan,
        hargaPerJam: hargaPerJam,
      );
      if (ok) fetchLapangans(); // refresh background
      return ok;
    } on Exception {
      rethrow;
    } finally {
      _setMutating(false);
    }
  }

  /// Edit lapangan. Melempar Exception jika gagal.
  Future<bool> editLapangan({
    required int id,
    required String namaLapangan,
    required int hargaPerJam,
  }) async {
    _setMutating(true);
    try {
      final ok = await _service.updateLapangan(
        id: id,
        namaLapangan: namaLapangan,
        hargaPerJam: hargaPerJam,
      );
      if (ok) fetchLapangans();
      return ok;
    } on Exception {
      rethrow;
    } finally {
      _setMutating(false);
    }
  }

  /// Hapus lapangan. Melempar Exception jika gagal.
  Future<bool> hapusLapangan(int id) async {
    _setMutating(true);
    try {
      final ok = await _service.deleteLapangan(id);
      if (ok) fetchLapangans();
      return ok;
    } on Exception {
      rethrow;
    } finally {
      _setMutating(false);
    }
  }
}
