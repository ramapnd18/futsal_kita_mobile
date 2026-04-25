const pool = require('../config/db');

// 1. CREATE TRANSAKSI (Booking Lapangan) - Protected (Login Required)
exports.createTransaksi = async (req, res) => {
  try {
    const id_user = req.user.id;
    const { id_lapangan, tanggal_main, jam_mulai, durasi } = req.body;

    console.log('[createTransaksi] Body diterima:', { id_user, id_lapangan, tanggal_main, jam_mulai, durasi });

    if (!id_lapangan || !tanggal_main || jam_mulai === undefined || jam_mulai === null || !durasi) {
      return res.status(400).json({ message: 'Semua data booking wajib diisi!' });
    }

    const jamMulaiInt = parseInt(jam_mulai);   // misal: 8
    const durasiInt   = parseInt(durasi);       // misal: 2
    const jamSelesai  = jamMulaiInt + durasiInt; // misal: 10

    console.log('[createTransaksi] Jam mulai:', jamMulaiInt, '| Jam selesai:', jamSelesai);

    // A. Cek Ketersediaan Lapangan
    const [existingBooking] = await pool.query(
      `SELECT * FROM transaksi 
       WHERE id_lapangan = ? AND tanggal_main = ? AND status != 'cancelled'`,
      [id_lapangan, tanggal_main],
    );

    let isConflict = false;
    for (let booking of existingBooking) {
      const bMulai   = parseInt(booking.jam_mulai);        // int dari DB
      const bSelesai = bMulai + parseInt(booking.durasi);  // jam selesai
      if (jamMulaiInt < bSelesai && jamSelesai > bMulai) {
        isConflict = true;
        console.log('[createTransaksi] Konflik dengan booking id:', booking.id_transaksi);
        break;
      }
    }

    if (isConflict) {
      return res.status(409).json({ message: 'Maaf, lapangan pada jam tersebut sudah dibooking.' });
    }

    // B. Ambil harga per jam
    const [lapangan] = await pool.query(
      'SELECT harga_per_jam FROM lapangan WHERE id_lapangan = ?',
      [id_lapangan],
    );
    if (lapangan.length === 0)
      return res.status(404).json({ message: 'Lapangan tidak ditemukan!' });

    const total_harga = lapangan[0].harga_per_jam * durasiInt;

    // C. Simpan Transaksi
    const [result] = await pool.query(
      'INSERT INTO transaksi (id_user, id_lapangan, tanggal_main, jam_mulai, durasi, total_harga, status) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id_user, id_lapangan, tanggal_main, jamMulaiInt, durasiInt, total_harga, 'pending'],

    );

    console.log('[createTransaksi] Berhasil insert, id_transaksi:', result.insertId);

    res.status(201).json({
      message: 'Booking berhasil dibuat!',
      id_transaksi: result.insertId,
    });
  } catch (error) {
    console.error('[createTransaksi] ERROR:', error);
    res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
  }
};

// 2. BATAL TRANSAKSI - Protected (Pelanggan: hanya bisa batalkan miliknya sendiri yg masih pending)
exports.batalTransaksi = async (req, res) => {
  try {
    const { id } = req.params;
    const id_user = req.user.id;

    console.log(`[batalTransaksi] id_transaksi=${id}, id_user=${id_user}`);

    // Cek transaksi ada dan milik user ini
    const [rows] = await pool.query(
      'SELECT * FROM transaksi WHERE id_transaksi = ?',
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Transaksi tidak ditemukan.' });
    }

    const transaksi = rows[0];

    // Pastikan pemilik
    if (transaksi.id_user !== id_user) {
      return res.status(403).json({ message: 'Akses ditolak. Ini bukan transaksi Anda.' });
    }

    // Pastikan masih pending
    if (transaksi.status !== 'pending') {
      return res.status(409).json({
        message: `Tidak bisa dibatalkan. Status saat ini: ${transaksi.status}.`,
      });
    }

    const [result] = await pool.query(
      "UPDATE transaksi SET status = 'cancelled' WHERE id_transaksi = ?",
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Transaksi tidak ditemukan.' });
    }

    console.log(`[batalTransaksi] Berhasil dibatalkan. id_transaksi=${id}`);
    res.json({ message: 'Booking berhasil dibatalkan.' });
  } catch (error) {
    console.error('[batalTransaksi] ERROR:', error);
    res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
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
