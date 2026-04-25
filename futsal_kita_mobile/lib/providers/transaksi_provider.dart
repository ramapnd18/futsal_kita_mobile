// lib/providers/transaksi_provider.dart

import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/transaksi_service.dart';

class TransaksiProvider extends ChangeNotifier {
  final TransaksiService _service = TransaksiService();

  // --- Three-State (fetch list) ---
  bool _isLoading = false;
  String? _errorMessage;
  List<Transaksi> _transaksis = [];

  // --- State khusus submit booking ---
  bool _isSubmitting = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Transaksi> get transaksis => _transaksis;
  bool get isSubmitting => _isSubmitting;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
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

  /// Membuat transaksi baru. Melempar [Exception] jika gagal.
  Future<void> tambahTransaksi({
    required int idLapangan,
    required String tanggalMain,
    required int jamMulai,
    required int durasi,
  }) async {
    _setSubmitting(true);

    try {
      await _service.createTransaksi(
        idLapangan: idLapangan,
        tanggalMain: tanggalMain,
        jamMulai: jamMulai,
        durasi: durasi,
      );
      // Refresh riwayat di background agar tab Riwayat langsung update
      fetchRiwayat();
    } on Exception {
      rethrow;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Konfirmasi pembayaran oleh Admin (ubah status → 'paid').
  /// Melempar [Exception] jika gagal.
  Future<void> updateStatusTransaksi(int idTransaksi) async {
    _setSubmitting(true);
    try {
      await _service.konfirmasiPembayaran(idTransaksi);
      fetchRiwayat(); // refresh list background
    } on Exception {
      rethrow;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Pembatalan booking oleh Pelanggan (ubah status → 'cancelled').
  /// Melempar [Exception] jika gagal.
  Future<void> batalkanTransaksi(int idTransaksi) async {
    _setSubmitting(true);
    try {
      await _service.batalkanTransaksi(idTransaksi);
      fetchRiwayat(); // refresh list background
    } on Exception {
      rethrow;
    } finally {
      _setSubmitting(false);
    }
  }
}

