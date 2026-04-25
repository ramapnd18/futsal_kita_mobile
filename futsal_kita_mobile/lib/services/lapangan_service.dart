// lib/services/lapangan_service.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lapangan.dart';

class LapanganService {
  static const String _baseUrl = 'http://10.0.2.2:5050/api';

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Lapangan>> getLapangan() async {
    final headers = await _authHeaders();
    developer.log('[LapanganService] GET $_baseUrl/lapangan', name: 'LapanganService');

    final response = await http.get(Uri.parse('$_baseUrl/lapangan'), headers: headers);
    developer.log('[LapanganService] Status: ${response.statusCode}', name: 'LapanganService');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>;
      return data.map((json) => Lapangan.fromJson(json as Map<String, dynamic>)).toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Sesi habis. Silakan login kembali.');
    } else {
      throw Exception('Gagal memuat data lapangan (${response.statusCode}).');
    }
  }

  Future<bool> createLapangan({
    required String namaLapangan,
    required int hargaPerJam,
  }) async {
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/lapangan'),
      headers: headers,
      body: jsonEncode({'nama_lapangan': namaLapangan, 'harga_per_jam': hargaPerJam}),
    );
    developer.log('[LapanganService] createLapangan ${response.statusCode}: ${response.body}', name: 'LapanganService');
    if (response.statusCode == 201) return true;
    if (response.statusCode == 401 || response.statusCode == 403) throw Exception('Sesi habis.');
    final msg = (jsonDecode(response.body)['message'] as String?) ?? 'Gagal menambah lapangan.';
    throw Exception(msg);
  }

  Future<bool> updateLapangan({
    required int id,
    required String namaLapangan,
    required int hargaPerJam,
  }) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$_baseUrl/lapangan/$id'),
      headers: headers,
      body: jsonEncode({'nama_lapangan': namaLapangan, 'harga_per_jam': hargaPerJam}),
    );
    developer.log('[LapanganService] updateLapangan ${response.statusCode}: ${response.body}', name: 'LapanganService');
    if (response.statusCode == 200) return true;
    if (response.statusCode == 401 || response.statusCode == 403) throw Exception('Sesi habis.');
    final msg = (jsonDecode(response.body)['message'] as String?) ?? 'Gagal mengupdate lapangan.';
    throw Exception(msg);
  }

  Future<bool> deleteLapangan(int id) async {
    final headers = await _authHeaders();
    final response = await http.delete(Uri.parse('$_baseUrl/lapangan/$id'), headers: headers);
    developer.log('[LapanganService] deleteLapangan ${response.statusCode}: ${response.body}', name: 'LapanganService');
    if (response.statusCode == 200) return true;
    if (response.statusCode == 401 || response.statusCode == 403) throw Exception('Sesi habis.');
    final msg = (jsonDecode(response.body)['message'] as String?) ?? 'Gagal menghapus lapangan.';
    throw Exception(msg);
  }
}
