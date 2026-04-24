const pool = require("../config/db");

// 1. CREATE TRANSAKSI (Booking Lapangan) - Protected (Login Required)
exports.createTransaksi = async (req, res) => {
  try {
    const id_user = req.user.id; // Didapat dari token JWT via middleware
    const { id_lapangan, tanggal_main, jam_mulai, durasi } = req.body;

    if (!id_lapangan || !tanggal_main || jam_mulai === undefined || !durasi) {
      return res
        .status(400)
        .json({ message: "Semua data booking wajib diisi!" });
    }

    // A. Cek Ketersediaan Lapangan (Logika Bentrok Jadwal)
    const jam_selesai = parseInt(jam_mulai) + parseInt(durasi);

    const [existingBooking] = await pool.query(
      `
            SELECT * FROM transaksi 
            WHERE id_lapangan = ? AND tanggal_main = ? AND status != 'cancelled'
        `,
      [id_lapangan, tanggal_main],
    );

    let isConflict = false;
    for (let booking of existingBooking) {
      const bookingSelesai = booking.jam_mulai + booking.durasi;
      // Cek apakah rentang waktu saling tumpang tindih
      if (jam_mulai < bookingSelesai && jam_selesai > booking.jam_mulai) {
        isConflict = true;
        break;
      }
    }

    if (isConflict) {
      return res
        .status(409)
        .json({ message: "Maaf, lapangan pada jam tersebut sudah dibooking." });
    }

    // B. Ambil harga per jam dari tabel lapangan
    const [lapangan] = await pool.query(
      "SELECT harga_per_jam FROM lapangan WHERE id_lapangan = ?",
      [id_lapangan],
    );
    if (lapangan.length === 0)
      return res.status(404).json({ message: "Lapangan tidak ditemukan!" });

    const total_harga = lapangan[0].harga_per_jam * durasi;

    // C. Simpan Transaksi
    const [result] = await pool.query(
      "INSERT INTO transaksi (id_user, id_lapangan, tanggal_main, jam_mulai, durasi, total_harga, status) VALUES (?, ?, ?, ?, ?, ?, ?)",
      [
        id_user,
        id_lapangan,
        tanggal_main,
        jam_mulai,
        durasi,
        total_harga,
        "pending",
      ],
    );

    res
      .status(201)
      .json({
        message: "Booking berhasil dibuat!",
        id_transaksi: result.insertId,
      });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Terjadi kesalahan server", error: error.message });
  }
};

// 2. READ TRANSAKSI - Protected (Admin lihat semua, Pelanggan lihat miliknya saja)
exports.getTransaksi = async (req, res) => {
  try {
    const role = req.user.role;
    const id_user = req.user.id;

    let query = `
            SELECT t.*, l.nama_lapangan, u.nama_lengkap 
            FROM transaksi t
            JOIN lapangan l ON t.id_lapangan = l.id_lapangan
            JOIN users u ON t.id_user = u.id_user
        `;
    let params = [];

    // Filter berdasarkan role
    if (role === "pelanggan") {
      query += " WHERE t.id_user = ?";
      params.push(id_user);
    }

    query += " ORDER BY t.tanggal_main DESC, t.jam_mulai ASC";

    const [transaksi] = await pool.query(query, params);
    res.json({ message: "Berhasil mengambil data transaksi", data: transaksi });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Terjadi kesalahan server", error: error.message });
  }
};

// 3. UPDATE STATUS TRANSAKSI - Protected (Hanya Admin)
exports.updateStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body; // Harus berisi: 'pending', 'paid', atau 'cancelled'

    const [result] = await pool.query(
      "UPDATE transaksi SET status = ? WHERE id_transaksi = ?",
      [status, id],
    );

    if (result.affectedRows === 0)
      return res.status(404).json({ message: "Transaksi tidak ditemukan" });

    res.json({ message: `Status transaksi berhasil diubah menjadi ${status}` });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Terjadi kesalahan server", error: error.message });
  }
};

// 4. CEK JADWAL KOSONG (Untuk UI Kalender)
exports.cekJadwal = async (req, res) => {
  try {
    const { id_lapangan, tanggal } = req.params;

    // Ambil transaksi yang sudah ada pada lapangan dan tanggal tersebut
    const [booking] = await pool.query(
      `SELECT jam_mulai, durasi FROM transaksi 
             WHERE id_lapangan = ? AND tanggal_main = ? AND status != 'cancelled'`,
      [id_lapangan, tanggal],
    );

    // Kumpulkan semua jam yang sudah terisi ke dalam sebuah array
    let jamTerisi = [];
    booking.forEach((b) => {
      for (let i = 0; i < b.durasi; i++) {
        jamTerisi.push(b.jam_mulai + i);
      }
    });

    res.json({ message: "Berhasil cek jadwal", data: jamTerisi });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Terjadi kesalahan server", error: error.message });
  }
};
