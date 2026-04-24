const express = require('express');
const router = express.Router();
const { 
    getAllLapangan, 
    getLapanganById, 
    createLapangan, 
    updateLapangan, 
    deleteLapangan 
} = require('../controllers/lapanganController');

// Import middleware JWT
const { verifyToken, isAdmin } = require('../middlewares/authMiddleware');

// Endpoint Public (Siapa saja bisa melihat lapangan)
router.get('/', getAllLapangan);
router.get('/:id', getLapanganById);

// Endpoint Protected (Hanya Admin yang bisa Tambah, Edit, Hapus)
// Perhatikan urutannya: verifyToken dulu (cek login), baru isAdmin (cek role)
router.post('/', verifyToken, isAdmin, createLapangan);
router.put('/:id', verifyToken, isAdmin, updateLapangan);
router.delete('/:id', verifyToken, isAdmin, deleteLapangan);

module.exports = router;