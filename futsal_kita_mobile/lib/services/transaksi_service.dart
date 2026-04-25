// lib/services/transaksi_service.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaksi.dart';

class TransaksiService {
  static const String _baseUrl = 'http://10.0.2.2:5050/api';

  Future<List<Transaksi>> getRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    developer.log('[TransaksiService] GET $_baseUrl/transaksi', name: 'TransaksiService');

    final response = await http.get(
      Uri.parse('$_baseUrl/transaksi'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    developer.log('[TransaksiService] Status: ${response.statusCode}', name: 'TransaksiService');
    developer.log('[TransaksiService] Body: ${response.body}', name: 'TransaksiService');

    if (response.statusCode == 200) {
      // Backend return: { message: '...', data: [...] }
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> data = body['data'] as List<dynamic>;
      return data
          .map((e) => Transaksi.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesi habis. Silakan login kembali.');
    } else {
      final body = jsonDecode(response.body);
      final msg = (body['message'] as String?) ?? 'Gagal memuat riwayat.';
      throw Exception(msg);
    }
  }

  Future<bool> createTransaksi({
    required int idLapangan,
    required String tanggalMain,
    required int jamMulai,
    required int durasi,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    developer.log(
      '[TransaksiService] POST $_baseUrl/transaksi | idLapangan=$idLapangan tanggal=$tanggalMain jam=$jamMulai durasi=$durasi',
      name: 'TransaksiService',
    );

    final response = await http.post(
      Uri.parse('$_baseUrl/transaksi'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id_lapangan': idLapangan,
        'tanggal_main': tanggalMain,
        'jam_mulai': jamMulai,   // int: 8, 9, 10, ...
        'durasi': durasi,
      }),
    );

    developer.log(
      '[TransaksiService] createTransaksi Status: ${response.statusCode}',
      name: 'TransaksiService',
    );
    developer.log(
      '[TransaksiService] createTransaksi Body: ${response.body}',
      name: 'TransaksiService',
    );

    if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Sesi habis. Silakan logout lalu login kembali.');
    } else {
      developer.log(
        '[TransaksiService] createTransaksi Error body: ${response.body}',
        name: 'TransaksiService',
      );
      final body = jsonDecode(response.body);
      final msg = (body['message'] as String?) ?? 'Gagal membuat booking. (${response.statusCode})';
      throw Exception(msg);
    }
  }

  /// Konfirmasi pembayaran oleh Admin: PUT /api/transaksi/:id/status
  Future<bool> konfirmasiPembayaran(int idTransaksi) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    developer.log(
      '[TransaksiService] PUT $_baseUrl/transaksi/$idTransaksi/status → paid',
      name: 'TransaksiService',
    );

    final response = await http.put(
      Uri.parse('$_baseUrl/transaksi/$idTransaksi/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': 'paid'}),
    );

    developer.log(
      '[TransaksiService] konfirmasiPembayaran ${response.statusCode}: ${response.body}',
      name: 'TransaksiService',
    );

    if (response.statusCode == 200) return true;
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Akses ditolak. Pastikan Anda login sebagai Admin.');
    }
    final body = jsonDecode(response.body);
    final msg = (body['message'] as String?) ?? 'Gagal konfirmasi pembayaran.';
    throw Exception(msg);
  }

  /// Batalkan booking oleh Pelanggan: PUT /api/transaksi/:id/batal
  Future<bool> batalkanTransaksi(int idTransaksi) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    developer.log(
      '[TransaksiService] PUT $_baseUrl/transaksi/$idTransaksi/batal',
      name: 'TransaksiService',
    );

    final response = await http.put(
      Uri.parse('$_baseUrl/transaksi/$idTransaksi/batal'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    developer.log(
      '[TransaksiService] batalkanTransaksi ${response.statusCode}: ${response.body}',
      name: 'TransaksiService',
    );

    if (response.statusCode == 200) return true;
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Sesi habis. Silakan login kembali.');
    }
    final body = jsonDecode(response.body);
    final msg = (body['message'] as String?) ?? 'Gagal membatalkan booking.';
    throw Exception(msg);
  }
}
