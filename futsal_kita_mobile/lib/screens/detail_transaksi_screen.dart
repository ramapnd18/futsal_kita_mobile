// lib/screens/detail_transaksi_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaksi.dart';

class DetailTransaksiScreen extends StatelessWidget {
  final Transaksi transaksi;

  const DetailTransaksiScreen({super.key, required this.transaksi});

  // ── Status helpers ──────────────────────────────────────────────────────────
  static const _statusConfig = {
    'paid': _StatusCfg(
      label: 'LUNAS',
      icon: Icons.check_circle_rounded,
      bg: Color(0xFFD1FAE5),
      fg: Color(0xFF065F46),
      headerBg: Color(0xFF10B981),
    ),
    'pending': _StatusCfg(
      label: 'MENUNGGU',
      icon: Icons.schedule_rounded,
      bg: Color(0xFFFEF3C7),
      fg: Color(0xFF92400E),
      headerBg: Color(0xFFF59E0B),
    ),
    'cancelled': _StatusCfg(
      label: 'DIBATALKAN',
      icon: Icons.cancel_rounded,
      bg: Color(0xFFFEE2E2),
      fg: Color(0xFF991B1B),
      headerBg: Color(0xFFEF4444),
    ),
  };

  _StatusCfg get _cfg =>
      _statusConfig[transaksi.status] ?? _statusConfig['pending']!;

  // ── Format helpers ──────────────────────────────────────────────────────────
  String get _formattedDate {
    try {
      final dt = DateTime.parse(transaksi.tanggalMain);
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return transaksi.tanggalMain;
    }
  }

  String get _formattedHarga {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(transaksi.totalHarga);
  }

  String get _hargaPerJam {
    final perJam = transaksi.durasi > 0
        ? (transaksi.totalHarga / transaksi.durasi).round()
        : transaksi.totalHarga;
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(perJam);
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, cfg),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatusHeader(cfg),
            const SizedBox(height: 20),
            _buildInvoiceCard(context, cfg),
            const SizedBox(height: 20),
            _buildRincianBiaya(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, _StatusCfg cfg) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
      foregroundColor: const Color(0xFF1E293B),
      title: const Text(
        'Detail Transaksi',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
      ),
      actions: [
        // Salin ID Transaksi
        IconButton(
          tooltip: 'Salin ID Transaksi',
          icon: const Icon(Icons.copy_rounded, size: 20),
          onPressed: () {
            Clipboard.setData(
                ClipboardData(text: '#${transaksi.idTransaksi}'));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('ID Transaksi disalin!'),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Status Hero Banner ──────────────────────────────────────────────────────
  Widget _buildStatusHeader(_StatusCfg cfg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cfg.headerBg,
            cfg.headerBg.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: cfg.headerBg.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(cfg.icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 14),
          Text(
            cfg.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formattedHarga,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'INV-${transaksi.idTransaksi.toString().padLeft(5, '0')}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Invoice Card ─────────────────────────────────────────────────────────────
  Widget _buildInvoiceCard(BuildContext context, _StatusCfg cfg) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Header kartu
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded,
                    color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Informasi Booking',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                // Badge status inline
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cfg.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cfg.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: cfg.fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Baris info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _InvoiceRow(
                  label: 'ID Transaksi',
                  value: '#${transaksi.idTransaksi}',
                  valueStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                    fontFamily: 'monospace',
                  ),
                ),
                _Divider(),
                _InvoiceRow(
                  label: 'Lapangan',
                  value: transaksi.namaLapangan,
                  valueStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                _Divider(),
                _InvoiceRow(
                  label: 'Tanggal Main',
                  value: _formattedDate,
                  valueStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                _Divider(),
                _InvoiceRow(
                  label: 'Jam Mulai',
                  value: transaksi.jamMulaiLabel,
                ),
                _Divider(),
                _InvoiceRow(
                  label: 'Jam Selesai',
                  value: transaksi.jamSelesaiLabel,
                ),
                _Divider(),
                _InvoiceRow(
                  label: 'Durasi',
                  value: '${transaksi.durasi} Jam',
                  valueStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          // Garis putus-putus divider
          _DashedDivider(),

          // Total
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL PEMBAYARAN',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  _formattedHarga,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10B981),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Rincian Biaya ────────────────────────────────────────────────────────────
  Widget _buildRincianBiaya() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Biaya',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _InvoiceRow(
            label: 'Harga per Jam',
            value: _hargaPerJam,
          ),
          const SizedBox(height: 10),
          _InvoiceRow(
            label: 'Durasi',
            value: '× ${transaksi.durasi} jam',
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 12),
          _InvoiceRow(
            label: 'Subtotal',
            value: _formattedHarga,
            valueStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private helper widgets ───────────────────────────────────────────────────

class _StatusCfg {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color headerBg;
  const _StatusCfg({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.headerBg,
  });
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InvoiceRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: valueStyle ??
                const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
    );
  }
}

/// Garis putus-putus sebagai pembatas invoice
class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 6.0;
          const dashSpace = 4.0;
          final count =
              (constraints.maxWidth / (dashWidth + dashSpace)).floor();
          return Row(
            children: List.generate(count, (_) {
              return Row(children: [
                Container(
                  width: dashWidth,
                  height: 1.5,
                  color: const Color(0xFFE2E8F0),
                ),
                const SizedBox(width: dashSpace),
              ]);
            }),
          );
        },
      ),
    );
  }
}
