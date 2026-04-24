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
}
