const jwt = require('jsonwebtoken');
require('dotenv').config();

// 1. Middleware untuk mengecek apakah user memiliki token yang valid
exports.verifyToken = (req, res, next) => {
    // Mengambil token dari header 'Authorization'
    const authHeader = req.headers['authorization'];
    
    // Format token biasanya: "Bearer <token>"
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ message: 'Akses ditolak. Token tidak ditemukan!' });
    }

    try {
        // Verifikasi token menggunakan secret key
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        
        // Simpan data user (id dan role) dari payload token ke dalam object request (req)
        // Ini agar data user bisa dipakai di controller selanjutnya
        req.user = decoded;
        
        // Lanjut ke proses berikutnya (controller)
        next();
    } catch (error) {
        return res.status(403).json({ message: 'Token tidak valid atau sudah kadaluarsa!' });
    }
};

// 2. Middleware khusus untuk mengecek apakah user adalah Admin
exports.isAdmin = (req, res, next) => {
    // Pastikan verifyToken sudah dijalankan sebelumnya sehingga req.user tersedia
    if (!req.user || req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Akses ditolak. Hanya Admin yang dapat melakukan aksi ini!' });
    }
    
    // Lanjut ke proses berikutnya (controller)
    next();
};