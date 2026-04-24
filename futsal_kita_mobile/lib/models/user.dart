// lib/models/user.dart

class User {
  final int idUser;
  final String username;
  final String namaLengkap;
  final String? noTelepon;
  final String role; // 'admin' | 'pelanggan'

  const User({
    required this.idUser,
    required this.username,
    required this.namaLengkap,
    this.noTelepon,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Defensive parsing: MySQL/JSON driver kadang mengembalikan id sebagai String
    final rawId = json['id_user'];
    final int parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    return User(
      idUser: parsedId,
      username: json['username'] as String,
      namaLengkap: (json['nama_lengkap'] as String?) ?? '',
      noTelepon: json['no_telepon'] as String?,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'username': username,
      'nama_lengkap': namaLengkap,
      'no_telepon': noTelepon,
      'role': role,
    };
  }

  bool get isAdmin => role == 'admin';
}
