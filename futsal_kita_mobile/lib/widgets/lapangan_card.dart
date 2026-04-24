// lib/widgets/lapangan_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lapangan.dart';
import '../screens/detail_lapangan_screen.dart';

class LapanganCard extends StatelessWidget {
  final Lapangan lapangan;

  const LapanganCard({super.key, required this.lapangan});

  static const Color _emerald = Color(0xFF10B981);

  // Pilih ikon berdasarkan kata kunci nama lapangan
  IconData _iconForLapangan(String nama) {
    final lower = nama.toLowerCase();
    if (lower.contains('vinyl')) return Icons.sports_soccer;
    if (lower.contains('sintetis') || lower.contains('sintesis')) {
      return Icons.grass;
    }
    return Icons.stadium;
  }

  Color _colorForIndex(int id) {
    const colors = [
      Color(0xFF10B981), // emerald
      Color(0xFF3B82F6), // blue
      Color(0xFFF59E0B), // amber
      Color(0xFF8B5CF6), // violet
      Color(0xFFEF4444), // red
      Color(0xFF06B6D4), // cyan
    ];
    return colors[id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final accentColor = _colorForIndex(lapangan.idLapangan);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailLapanganScreen(lapangan: lapangan),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // --- Icon Container ---
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconForLapangan(lapangan.namaLapangan),
                  color: accentColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // --- Info ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lapangan.namaLapangan,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 13, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        const Text(
                          'Per Jam',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- Price Badge ---
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _emerald.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  formatter.format(lapangan.hargaPerJam),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _emerald,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
