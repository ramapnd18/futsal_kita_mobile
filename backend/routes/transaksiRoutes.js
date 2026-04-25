const express = require('express');
const router = express.Router();
const { createTransaksi, batalTransaksi, getTransaksi, updateStatus, cekJadwal} = require('../controllers/transaksiController');

// Import middleware JWT
const { verifyToken, isAdmin } = require('../middlewares/authMiddleware');

// Endpoint Protected (Wajib Login)
// Pelanggan bisa booking dan melihat riwayatnya sendiri
router.post('/', verifyToken, createTransaksi);
router.get('/', verifyToken, getTransaksi);

// Pelanggan bisa membatalkan transaksi miliknya sendiri (cek ownership di controller)
router.put('/:id/batal', verifyToken, batalTransaksi);

// Endpoint untuk cek jadwal spesifik
router.get('/jadwal/:id_lapangan/:tanggal', verifyToken, cekJadwal);

// Endpoint Protected Khusus Admin
// Admin memverifikasi pembayaran (ubah ke 'paid') atau batalkan ('cancelled')
router.put('/:id/status', verifyToken, isAdmin, updateStatus);

module.exports = router;