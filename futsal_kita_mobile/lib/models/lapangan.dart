// lib/models/lapangan.dart

class Lapangan {
  final int idLapangan;
  final String namaLapangan;
  final int hargaPerJam;

  const Lapangan({
    required this.idLapangan,
    required this.namaLapangan,
    required this.hargaPerJam,
  });

  factory Lapangan.fromJson(Map<String, dynamic> json) {
    // Defensive parsing: MySQL bisa kembalikan int, double, atau String
    final rawId = json['id_lapangan'];
    final rawHarga = json['harga_per_jam'];

    return Lapangan(
      idLapangan: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '') ?? 0,
      namaLapangan: (json['nama_lapangan'] as String?) ?? '',
      hargaPerJam: rawHarga is int
          ? rawHarga
          : rawHarga is double
              ? rawHarga.toInt()
              : int.tryParse(rawHarga?.toString() ?? '') ?? 0,
    );
  }
}
