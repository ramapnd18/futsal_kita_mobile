// lib/screens/detail_transaksi_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaksi.dart';
import '../providers/auth_provider.dart';
import '../providers/transaksi_provider.dart';

class DetailTransaksiScreen extends StatefulWidget {
  final Transaksi transaksi;

  const DetailTransaksiScreen({super.key, required this.transaksi});

  @override
  State<DetailTransaksiScreen> createState() => _DetailTransaksiScreenState();
}

class _DetailTransaksiScreenState extends State<DetailTransaksiScreen> {
  // Track status lokal agar UI update setelah konfirmasi tanpa perlu pop+reload
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.transaksi.status;
  }

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

  _StatusCfg get _cfg => _statusConfig[_currentStatus] ?? _statusConfig['pending']!;

  // ── Format helpers ──────────────────────────────────────────────────────────
  String get _formattedDate {
    try {
      final dt = DateTime.parse(widget.transaksi.tanggalMain);
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return widget.transaksi.tanggalMain;
    }
  }

  String get _formattedHarga => NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
      .format(widget.transaksi.totalHarga);

  String get _hargaPerJam {
    final perJam = widget.transaksi.durasi > 0
        ? (widget.transaksi.totalHarga / widget.transaksi.durasi).round()
        : widget.transaksi.totalHarga;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(perJam);
  }

  Future<void> _handleBatal() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Batalkan Booking?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaksi #${widget.transaksi.idTransaksi} — ${widget.transaksi.namaLapangan}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Booking yang sudah dibatalkan tidak dapat dikembalikan.',
              style: TextStyle(color: Color(0xFF475569), height: 1.5, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await context.read<TransaksiProvider>().batalkanTransaksi(widget.transaksi.idTransaksi);
      if (!mounted) return;

      setState(() => _currentStatus = 'cancelled');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.cancel_rounded, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text('Booking berhasil dibatalkan.', style: TextStyle(fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ));

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  // ── Konfirmasi Pembayaran ───────────────────────────────────────────────────
  Future<void> _handleKonfirmasi() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Konfirmasi Pembayaran?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaksi #${widget.transaksi.idTransaksi} — ${widget.transaksi.namaLapangan}',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Status akan diubah menjadi LUNAS dan tidak bisa dikembalikan.',
              style: TextStyle(color: Color(0xFF475569), height: 1.5, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: const Text('Ya, Konfirmasi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final provider = context.read<TransaksiProvider>();
    try {
      await provider.updateStatusTransaksi(widget.transaksi.idTransaksi);
      if (!mounted) return;

      // Update status lokal agar header langsung berubah tanpa perlu pop
      setState(() => _currentStatus = 'paid');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text('Pembayaran berhasil dikonfirmasi!',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ));

      // Pop layar setelah delay singkat agar SnackBar sempat terlihat
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg;
    final user = context.read<AuthProvider>().user;
    final isAdmin = user?.role == 'admin';
    final isPelanggan = user?.role == 'pelanggan';
    final canConfirm = isAdmin && _currentStatus == 'pending';
    final canCancel  = isPelanggan && _currentStatus == 'pending';
    final hasBottomBar = canConfirm || canCancel;

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
            SizedBox(height: hasBottomBar ? 100 : 28),
          ],
        ),
      ),
      bottomNavigationBar: canConfirm
          ? _buildKonfirmasiBar()
          : canCancel
              ? _buildBatalBar()
              : null,
    );
  }

  // ── Tombol Batal Booking (Pelanggan Only) ───────────────────────────────────
  Widget _buildBatalBar() {
    return Consumer<TransaksiProvider>(
      builder: (_, provider, __) {
        final isBusy = provider.isSubmitting;
        return Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label info
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF991B1B)),
                    SizedBox(width: 6),
                    Text('Pembatalan tidak dapat dikembalikan',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF991B1B))),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isBusy ? null : _handleBatal,
                  icon: isBusy
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(color: Color(0xFFEF4444), strokeWidth: 2.5))
                      : const Icon(Icons.cancel_outlined, size: 20),
                  label: Text(
                    isBusy ? 'Memproses...' : 'Batalkan Booking',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    disabledForegroundColor: const Color(0xFFFCA5A5),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
      ),
      actions: [
        IconButton(
          tooltip: 'Salin ID Transaksi',
          icon: const Icon(Icons.copy_rounded, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: '#${widget.transaksi.idTransaksi}'));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('ID Transaksi disalin!'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ));
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Tombol Konfirmasi (Admin Only) ──────────────────────────────────────────
  Widget _buildKonfirmasiBar() {
    return Consumer<TransaksiProvider>(
      builder: (_, provider, __) {
        final isBusy = provider.isSubmitting;
        return Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label admin badge
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.admin_panel_settings_rounded, size: 14, color: Color(0xFF065F46)),
                    SizedBox(width: 6),
                    Text('Panel Admin — Menunggu Konfirmasi',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF065F46))),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isBusy ? null : _handleKonfirmasi,
                  icon: isBusy
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Icon(Icons.check_circle_rounded, size: 20),
                  label: Text(
                    isBusy ? 'Memproses...' : 'Konfirmasi Pembayaran (Lunas)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    disabledBackgroundColor: const Color(0xFFA7F3D0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          colors: [cfg.headerBg, cfg.headerBg.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: cfg.headerBg.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(cfg.icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 14),
          Text(cfg.label,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text(_formattedHarga,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.9), fontSize: 32,
                  fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'INV-${widget.transaksi.idTransaksi.toString().padLeft(5, '0')}',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.9), fontSize: 13,
                  fontWeight: FontWeight.w600, letterSpacing: 1),
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
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981), size: 20),
                const SizedBox(width: 10),
                const Text('Informasi Booking',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: cfg.bg, borderRadius: BorderRadius.circular(20)),
                  child: Text(cfg.label,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cfg.fg)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _InvoiceRow(
                  label: 'ID Transaksi',
                  value: '#${widget.transaksi.idTransaksi}',
                  valueStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                      color: Color(0xFF1E293B), fontFamily: 'monospace'),
                ),
                _Divider(),
                _InvoiceRow(label: 'Lapangan', value: widget.transaksi.namaLapangan,
                    valueStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B))),
                _Divider(),
                _InvoiceRow(label: 'Tanggal Main', value: _formattedDate,
                    valueStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B))),
                _Divider(),
                _InvoiceRow(label: 'Jam Mulai', value: widget.transaksi.jamMulaiLabel),
                _Divider(),
                _InvoiceRow(label: 'Jam Selesai', value: widget.transaksi.jamSelesaiLabel),
                _Divider(),
                _InvoiceRow(label: 'Durasi', value: '${widget.transaksi.durasi} Jam',
                    valueStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B))),
              ],
            ),
          ),
          _DashedDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL PEMBAYARAN',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B), letterSpacing: 0.5)),
                Text(_formattedHarga,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                        color: Color(0xFF10B981), letterSpacing: -0.5)),
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
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 20, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rincian Biaya',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
          const SizedBox(height: 16),
          _InvoiceRow(label: 'Harga per Jam', value: _hargaPerJam),
          const SizedBox(height: 10),
          _InvoiceRow(label: 'Durasi', value: '× ${widget.transaksi.durasi} jam'),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          _InvoiceRow(
            label: 'Subtotal',
            value: _formattedHarga,
            valueStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF10B981)),
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

  const _InvoiceRow({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: valueStyle ??
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF475569))),
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

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 6.0;
          const dashSpace = 4.0;
          final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
          return Row(
            children: List.generate(count, (_) => Row(children: [
              Container(width: dashWidth, height: 1.5, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: dashSpace),
            ])),
          );
        },
      ),
    );
  }
}
