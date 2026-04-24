// lib/services/lapangan_service.dart

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lapangan.dart';

class LapanganService {
  static const String _baseUrl = 'http://10.0.2.2:5050/api';

  Future<List<Lapangan>> getLapangan() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    developer.log('[LapanganService] GET $_baseUrl/lapangan', name: 'LapanganService');

    final response = await http.get(
      Uri.parse('$_baseUrl/lapangan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    developer.log('[LapanganService] Status: ${response.statusCode}', name: 'LapanganService');
    developer.log('[LapanganService] Body: ${response.body}', name: 'LapanganService');

    if (response.statusCode == 200) {
      // Backend mengembalikan { message: '...', data: [...] }
      final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> data = body['data'] as List<dynamic>;
      return data
          .map((json) => Lapangan.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesi habis. Silakan login kembali.');
    } else {
      throw Exception('Gagal memuat data lapangan (${response.statusCode}).');
    }
  }
}
