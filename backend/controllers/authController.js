const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');
require('dotenv').config();

// 1. REGISTER
exports.register = async (req, res) => {
    try {
        const { username, password, nama_lengkap, no_telepon } = req.body;
        
        // Cek apakah username sudah dipakai
        const [users] = await pool.query('SELECT * FROM users WHERE username = ?', [username]);
        if (users.length > 0) return res.status(400).json({ message: 'Username sudah terdaftar!' });

        // Hash password menggunakan bcrypt
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Masukkan ke database (role otomatis jadi 'pelanggan')
        await pool.query(
            'INSERT INTO users (username, password, nama_lengkap, no_telepon) VALUES (?, ?, ?, ?)',
            [username, hashedPassword, nama_lengkap, no_telepon]
        );

        res.status(201).json({ message: 'Registrasi berhasil! Silakan login.' });
    } catch (error) {
        res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
    }
};

// 2. LOGIN
exports.login = async (req, res) => {
    try {
        const { username, password } = req.body;

        // Cari user di database
        const [users] = await pool.query('SELECT * FROM users WHERE username = ?', [username]);
        if (users.length === 0) return res.status(404).json({ message: 'Username tidak ditemukan!' });

        const user = users[0];

        // Cocokkan password
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(401).json({ message: 'Password salah!' });

        // Buat Access Token (Umur pendek: 15 menit)
        const accessToken = jwt.sign(
            { id: user.id_user, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '15m' }
        );

        // Buat Refresh Token (Umur panjang: 7 hari)
        const refreshToken = jwt.sign(
            { id: user.id_user, role: user.role },
            process.env.JWT_REFRESH_SECRET,
            { expiresIn: '7d' }
        );

        res.json({
            message: 'Login berhasil!',
            accessToken,
            refreshToken,
            user: {
                id_user: user.id_user,
                username: user.username,
                nama_lengkap: user.nama_lengkap,
                no_telepon: user.no_telepon ?? null,
                role: user.role
            }
        });
    } catch (error) {
        res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
    }
};

// 3. REFRESH TOKEN
exports.refresh = (req, res) => {
    const { token } = req.body;
    if (!token) return res.status(401).json({ message: 'Refresh token diperlukan!' });

    jwt.verify(token, process.env.JWT_REFRESH_SECRET, (err, decoded) => {
        if (err) return res.status(403).json({ message: 'Refresh token tidak valid atau kadaluarsa!' });

        // Buat Access Token baru
        const newAccessToken = jwt.sign(
            { id: decoded.id, role: decoded.role },
            process.env.JWT_SECRET,
            { expiresIn: '15m' }
        );

        res.json({ accessToken: newAccessToken });
    });
};

// 4. LOGOUT
exports.logout = (req, res) => {
    // Pada implementasi JWT sederhana, logout dilakukan di frontend dengan menghapus token dari localStorage/cookies.
    // Kita buat endpoint ini agar sesuai dengan instruksi UTS.
    res.json({ message: 'Logout berhasil! Silakan hapus token di sisi client (Frontend).' });
};

// 5. GOOGLE OAUTH LOGIN & CALLBACK
exports.googleAuth = (req, res) => {
    // Arahkan user ke halaman Login Google
    const url = `https://accounts.google.com/o/oauth2/v2/auth?client_id=${process.env.GOOGLE_CLIENT_ID}&redirect_uri=http://localhost:5050/api/auth/google/callback&response_type=code&scope=openid email profile`;
    res.redirect(url);
};

exports.googleCallback = async (req, res) => {
    const code = req.query.code;
    if (!code) return res.status(400).json({ message: "Code tidak ada" });

    try {
        // 1. Tukar code dengan Access Token dari Google (Menggunakan native fetch Node.js)
        const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                code,
                client_id: process.env.GOOGLE_CLIENT_ID,
                client_secret: process.env.GOOGLE_CLIENT_SECRET,
                redirect_uri: "http://localhost:5050/api/auth/google/callback",
                grant_type: "authorization_code"
            })
        });
        const tokenData = await tokenRes.json();
        if (!tokenData.access_token) return res.status(400).json({ message: "Gagal ambil access token dari Google" });

        // 2. Ambil data profil user dari Google
        const userRes = await fetch("https://www.googleapis.com/oauth2/v2/userinfo", {
            headers: { Authorization: `Bearer ${tokenData.access_token}` }
        });
        const googleUser = await userRes.json();
        const email = googleUser.email; // Kita jadikan email sebagai username
        const name = googleUser.name;

        // 3. Cek apakah user sudah ada di database
        const [rows] = await pool.query('SELECT * FROM users WHERE username = ?', [email]);
        let user = rows[0];

        if (!user) {
            // PERBAIKAN: Hapus kolom email dari query, cukup gunakan username
            const [result] = await pool.query(
                'INSERT INTO users (username, password, nama_lengkap, role) VALUES (?, ?, ?, ?)',
                [email, "", name, "pelanggan"]
            );
            user = { id_user: result.insertId, username: email, role: "pelanggan", nama_lengkap: name };
        }

        // 4. Generate JWT Token untuk aplikasi Futsal KITA
        const accessToken = jwt.sign(
            { id: user.id_user, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '15m' }
        );

        // 5. Redirect kembali ke Frontend dengan membawa Token di URL
        // PENTING: Ganti port 5500 di bawah ini sesuai dengan port Live Server VS Code kamu!
        const frontendUrl = `http://127.0.0.1:5500/index.html?token=${accessToken}&id=${user.id_user}&username=${user.username}&role=${user.role}`;
        res.redirect(frontendUrl);

    } catch (error) {
        res.status(500).json({ message: "Terjadi kesalahan saat otentikasi Google", error: error.message });
    }
};