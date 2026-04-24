// lib/widgets/transaksi_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaksi.dart';
import '../screens/detail_transaksi_screen.dart';

class TransaksiCard extends StatelessWidget {
  final Transaksi transaksi;

  const TransaksiCard({super.key, required this.transaksi});

  // ── Status helpers ──────────────────────────────────────────────────────────
  static const _statusMap = {
    'paid': _StatusStyle(
      label: 'Lunas',
      bg: Color(0xFFD1FAE5),
      fg: Color(0xFF065F46),
      icon: Icons.check_circle_rounded,
    ),
    'pending': _StatusStyle(
      label: 'Pending',
      bg: Color(0xFFFEF3C7),
      fg: Color(0xFF92400E),
      icon: Icons.schedule_rounded,
    ),
    'cancelled': _StatusStyle(
      label: 'Dibatalkan',
      bg: Color(0xFFFEE2E2),
      fg: Color(0xFF991B1B),
      icon: Icons.cancel_rounded,
    ),
  };

  _StatusStyle get _style =>
      _statusMap[transaksi.status] ?? _statusMap['pending']!;

  // ── Format helpers ──────────────────────────────────────────────────────────
  String get _formattedDate {
    try {
      final dt = DateTime.parse(transaksi.tanggalMain);
      return DateFormat('EEE, d MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return transaksi.tanggalMain;
    }
  }

  String get _formattedHarga {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(transaksi.totalHarga);
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailTransaksiScreen(transaksi: transaksi),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: nama lapangan + status badge ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stadium_rounded,
                        size: 18, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        transaksi.namaLapangan,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status Badge
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: style.bg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(style.icon, size: 12, color: style.fg),
                          const SizedBox(width: 4),
                          Text(
                            style.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: style.fg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body: tanggal, jam, durasi, harga ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Info kiri
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            icon: Icons.calendar_today_rounded,
                            text: _formattedDate,
                          ),
                          const SizedBox(height: 6),
                          _InfoRow(
                            icon: Icons.access_time_rounded,
                            text:
                                '${transaksi.jamMulaiLabel} – ${transaksi.jamSelesaiLabel} (${transaksi.durasi} jam)',
                          ),
                        ],
                      ),
                    ),
                    // Harga kanan
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formattedHarga,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ── Private helpers ──────────────────────────────────────────────────────────

class _StatusStyle {
  final String label;
  final Color bg;
  final Color fg;
  final IconData icon;
  const _StatusStyle({
    required this.label,
    required this.bg,
    required this.fg,
    required this.icon,
  });
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
