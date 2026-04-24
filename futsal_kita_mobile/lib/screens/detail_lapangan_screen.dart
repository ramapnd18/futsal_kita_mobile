// lib/screens/detail_lapangan_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lapangan.dart';

class DetailLapanganScreen extends StatelessWidget {
  final Lapangan lapangan;

  const DetailLapanganScreen({super.key, required this.lapangan});

  static const Color _emerald = Color(0xFF10B981);
  static const Color _emeraldDark = Color(0xFF065F46);

  // Warna aksen dinamis berdasarkan ID (sama dengan LapanganCard)
  Color get _accentColor {
    const colors = [
      Color(0xFF10B981),
      Color(0xFF3B82F6),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFFEF4444),
      Color(0xFF06B6D4),
    ];
    return colors[lapangan.idLapangan % colors.length];
  }

  IconData get _lapanganIcon {
    final lower = lapangan.namaLapangan.toLowerCase();
    if (lower.contains('vinyl')) return Icons.sports_soccer;
    if (lower.contains('sintetis') || lower.contains('sintesis')) {
      return Icons.grass;
    }
    return Icons.stadium;
  }

  String get _formattedHarga {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(lapangan.hargaPerJam);
  }

  // Deskripsi dummy berdasarkan tipe lapangan
  String get _deskripsi {
    final lower = lapangan.namaLapangan.toLowerCase();
    if (lower.contains('vinyl')) {
      return 'Lapangan dengan permukaan vinyl premium yang memberikan traksi optimal dan kenyamanan bermain maksimal. Ideal untuk pertandingan kompetitif maupun latihan rutin. Lantai anti-slip dan tahan lama, dirancang untuk performa terbaik.';
    }
    if (lower.contains('sintetis') || lower.contains('sintesis')) {
      return 'Lapangan rumput sintetis generasi terbaru dengan tekstur yang menyerupai rumput asli. Memberikan pengalaman bermain yang natural dengan perawatan minimal. Cocok untuk semua level pemain.';
    }
    return 'Lapangan futsal standar internasional dengan fasilitas lengkap. Pencahayaan optimal, ventilasi baik, dan permukaan yang terawat untuk kenyamanan bermain Anda.';
  }

  static const List<_FasilitasItem> _fasilitas = [
    _FasilitasItem(icon: Icons.lightbulb_rounded, label: 'Pencahayaan LED'),
    _FasilitasItem(icon: Icons.water_drop_rounded, label: 'Air Minum'),
    _FasilitasItem(icon: Icons.wc_rounded, label: 'Toilet Bersih'),
    _FasilitasItem(icon: Icons.directions_car_rounded, label: 'Parkir Luas'),
    _FasilitasItem(icon: Icons.wifi_rounded, label: 'Free WiFi'),
    _FasilitasItem(icon: Icons.chair_rounded, label: 'Ruang Ganti'),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, accent),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(accent),
                _buildDeskripsiCard(),
                _buildFasilitasCard(),
                _buildJamOperasionalCard(),
                const SizedBox(height: 120), // ruang untuk bottom button
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomCTA(context),
    );
  }

  // ── Sliver AppBar dengan ilustrasi ──────────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context, Color accent) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: accent,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent,
                    accent.withOpacity(0.75),
                    const Color(0xFF064E3B),
                  ],
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            // Center icon
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: Icon(_lapanganIcon,
                        color: Colors.white, size: 52),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      'ID: #${lapangan.idLapangan}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info utama: nama + harga ────────────────────────────────────────────────
  Widget _buildInfoCard(Color accent) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
          Text(
            lapangan.namaLapangan,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Harga per Jam',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formattedHarga,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: accent,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating dummy
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: Color(0xFFF59E0B), size: 18),
                    SizedBox(width: 4),
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Deskripsi ───────────────────────────────────────────────────────────────
  Widget _buildDeskripsiCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
          const _SectionTitle(title: 'Tentang Lapangan'),
          const SizedBox(height: 12),
          Text(
            _deskripsi,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // ── Fasilitas ───────────────────────────────────────────────────────────────
  Widget _buildFasilitasCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
          const _SectionTitle(title: 'Fasilitas'),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: _fasilitas
                .map((f) => _FasilitasChip(item: f))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Jam Operasional ─────────────────────────────────────────────────────────
  Widget _buildJamOperasionalCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
          const _SectionTitle(title: 'Jam Operasional'),
          const SizedBox(height: 16),
          _JamRow(hari: 'Senin – Jumat', jam: '07:00 – 23:00'),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _JamRow(hari: 'Sabtu – Minggu', jam: '06:00 – 24:00'),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),
          _JamRow(
              hari: 'Hari Libur Nasional',
              jam: '07:00 – 22:00',
              note: 'Hubungi kami'),
        ],
      ),
    );
  }

  // ── Bottom CTA ──────────────────────────────────────────────────────────────
  Widget _buildBottomCTA(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Harga ringkas
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mulai dari',
                    style:
                        TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                Text(
                  _formattedHarga,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          // Tombol CTA (disabled — fitur booking belum tersedia)
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Text('Fitur pemilihan jadwal segera hadir!'),
                      ],
                    ),
                    backgroundColor: _emerald,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _emerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                'Pilih Jadwal',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private helper widgets ───────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }
}

class _FasilitasItem {
  final IconData icon;
  final String label;
  const _FasilitasItem({required this.icon, required this.label});
}

class _FasilitasChip extends StatelessWidget {
  final _FasilitasItem item;
  const _FasilitasChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: const Color(0xFF10B981), size: 22),
          const SizedBox(height: 6),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _JamRow extends StatelessWidget {
  final String hari;
  final String jam;
  final String? note;
  const _JamRow({required this.hari, required this.jam, this.note});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(hari,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF475569))),
        ),
        Text(
          jam,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        if (note != null) ...[
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(note!,
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ],
    );
  }
}
