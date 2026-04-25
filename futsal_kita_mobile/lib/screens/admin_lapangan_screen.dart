// lib/screens/admin_lapangan_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/lapangan.dart';
import '../providers/lapangan_provider.dart';

class AdminLapanganScreen extends StatefulWidget {
  const AdminLapanganScreen({super.key});

  @override
  State<AdminLapanganScreen> createState() => _AdminLapanganScreenState();
}

class _AdminLapanganScreenState extends State<AdminLapanganScreen> {
  static const Color _emerald = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LapanganProvider>().fetchLapangans();
    });
  }

  void _showFormSheet({Lapangan? lapangan}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LapanganFormSheet(lapangan: lapangan),
    );
  }

  Future<void> _konfirmasiHapus(Lapangan lapangan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Lapangan?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: Text(
          'Lapangan "${lapangan.namaLapangan}" akan dihapus permanen beserta seluruh data transaksinya.',
          style: const TextStyle(color: Color(0xFF475569), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await context.read<LapanganProvider>().hapusLapangan(lapangan.idLapangan);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(_snackBar(
        '${lapangan.namaLapangan} berhasil dihapus.',
        Colors.red.shade600,
        Icons.delete_rounded,
      ));
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(_snackBar(msg, Colors.red.shade700, Icons.error_rounded));
    }
  }

  SnackBar _snackBar(String msg, Color color, IconData icon) {
    return SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: _emerald,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'Manajemen Lapangan',
              style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w700, fontSize: 17),
            ),
          ],
        ),
      ),
      body: Consumer<LapanganProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: _emerald));
          }
          if (provider.errorMessage != null) {
            return _buildError(provider);
          }
          if (provider.lapangans.isEmpty) {
            return _buildEmpty();
          }
          return _buildList(provider);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormSheet(),
        backgroundColor: _emerald,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Lapangan', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 4,
      ),
    );
  }

  Widget _buildList(LapanganProvider provider) {
    return RefreshIndicator(
      color: _emerald,
      onRefresh: provider.fetchLapangans,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemCount: provider.lapangans.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _AdminLapanganCard(
          lapangan: provider.lapangans[i],
          onEdit: () => _showFormSheet(lapangan: provider.lapangans[i]),
          onDelete: () => _konfirmasiHapus(provider.lapangans[i]),
        ),
      ),
    );
  }

  Widget _buildError(LapanganProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 16),
            Text(provider.errorMessage!, textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: provider.fetchLapangans,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _emerald, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Color(0xFFECFDF5), shape: BoxShape.circle),
            child: const Icon(Icons.stadium_rounded, size: 52, color: _emerald),
          ),
          const SizedBox(height: 16),
          const Text('Belum ada lapangan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Tekan tombol + untuk menambahkan lapangan baru.',
              style: TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

// ── Card Lapangan Admin ───────────────────────────────────────────────────────

class _AdminLapanganCard extends StatelessWidget {
  final Lapangan lapangan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminLapanganCard({
    required this.lapangan,
    required this.onEdit,
    required this.onDelete,
  });

  static const List<Color> _accentColors = [
    Color(0xFF10B981), Color(0xFF3B82F6), Color(0xFFF59E0B),
    Color(0xFF8B5CF6), Color(0xFFEF4444), Color(0xFF06B6D4),
  ];

  Color get _accent => _accentColors[lapangan.idLapangan % _accentColors.length];

  String get _harga => NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
      .format(lapangan.hargaPerJam);

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Accent bar
          Container(
            width: 5,
            height: 80,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          // Icon
          Container(
            margin: const EdgeInsets.all(14),
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.stadium_rounded, color: accent, size: 26),
          ),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lapangan.namaLapangan,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(_harga, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: accent)),
                const SizedBox(height: 2),
                Text('ID #${lapangan.idLapangan}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            ),
          ),
          // Action buttons
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_rounded, color: Color(0xFF3B82F6), size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444), size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ── Form BottomSheet (Tambah / Edit) ─────────────────────────────────────────

class _LapanganFormSheet extends StatefulWidget {
  final Lapangan? lapangan; // null = mode Tambah, non-null = mode Edit
  const _LapanganFormSheet({this.lapangan});

  @override
  State<_LapanganFormSheet> createState() => _LapanganFormSheetState();
}

class _LapanganFormSheetState extends State<_LapanganFormSheet> {
  static const Color _emerald = Color(0xFF10B981);

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaCtrl;
  late final TextEditingController _hargaCtrl;

  bool get _isEdit => widget.lapangan != null;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.lapangan?.namaLapangan ?? '');
    _hargaCtrl = TextEditingController(
      text: widget.lapangan != null ? widget.lapangan!.hargaPerJam.toString() : '',
    );
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final nama = _namaCtrl.text.trim();
    final harga = int.parse(_hargaCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final provider = context.read<LapanganProvider>();

    try {
      bool ok;
      if (_isEdit) {
        ok = await provider.editLapangan(
          id: widget.lapangan!.idLapangan,
          namaLapangan: nama,
          hargaPerJam: harga,
        );
      } else {
        ok = await provider.tambahLapangan(namaLapangan: nama, hargaPerJam: harga);
      }

      if (!ok || !mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(_isEdit ? 'Lapangan berhasil diperbarui!' : 'Lapangan berhasil ditambahkan!',
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: _emerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 14, bottom: 20),
                width: 44, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_isEdit ? Icons.edit_rounded : Icons.add_circle_rounded, color: _emerald, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  _isEdit ? 'Edit Lapangan' : 'Tambah Lapangan',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Field Nama
            _buildLabel('Nama Lapangan'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _namaCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration('Contoh: Lapangan Vinyl A', Icons.stadium_rounded),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama lapangan wajib diisi.' : null,
            ),
            const SizedBox(height: 16),

            // Field Harga
            _buildLabel('Harga per Jam (Rp)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _hargaCtrl,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Contoh: 100000', Icons.attach_money_rounded),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Harga wajib diisi.';
                final parsed = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
                if (parsed == null || parsed <= 0) return 'Masukkan harga yang valid.';
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Tombol Submit
            Consumer<LapanganProvider>(
              builder: (_, provider, __) {
                final isBusy = provider.isMutating;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isBusy ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _emerald,
                      disabledBackgroundColor: const Color(0xFFA7F3D0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: isBusy
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(
                            _isEdit ? 'Simpan Perubahan' : 'Tambah Lapangan',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)));
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
    );
  }
}
