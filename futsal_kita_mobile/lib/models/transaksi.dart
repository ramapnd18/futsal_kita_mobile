// lib/models/transaksi.dart

class Transaksi {
  final int idTransaksi;
  final int idUser;
  final int idLapangan;
  final String namaLapangan; // dari JOIN lapangan
  final String tanggalMain;  // date → String 'YYYY-MM-DD'
  final int jamMulai;        // int jam (misal: 8 = 08:00)
  final int durasi;          // int (jam)
  final int totalHarga;
  final String status;       // 'pending' | 'paid' | 'cancelled'

  const Transaksi({
    required this.idTransaksi,
    required this.idUser,
    required this.idLapangan,
    required this.namaLapangan,
    required this.tanggalMain,
    required this.jamMulai,
    required this.durasi,
    required this.totalHarga,
    required this.status,
  });

  /// Jam selesai dihitung dari jam_mulai + durasi
  int get jamSelesai => jamMulai + durasi;

  /// Format jam ke string HH:00
  String get jamMulaiLabel => '${jamMulai.toString().padLeft(2, '0')}:00';
  String get jamSelesaiLabel => '${jamSelesai.toString().padLeft(2, '0')}:00';

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    _parseInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    // tanggal_main bisa berupa DateTime string dari MySQL
    final rawTanggal = json['tanggal_main']?.toString() ?? '';
    final tanggal = rawTanggal.length >= 10 ? rawTanggal.substring(0, 10) : rawTanggal;

    return Transaksi(
      idTransaksi: _parseInt(json['id_transaksi']),
      idUser: _parseInt(json['id_user']),
      idLapangan: _parseInt(json['id_lapangan']),
      namaLapangan: (json['nama_lapangan'] as String?) ?? 'Lapangan',
      tanggalMain: tanggal,
      jamMulai: _parseInt(json['jam_mulai']),
      durasi: _parseInt(json['durasi']),
      totalHarga: _parseInt(json['total_harga']),
      status: (json['status'] as String?) ?? 'pending',
    );
  }
}
