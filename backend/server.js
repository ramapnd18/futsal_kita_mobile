const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

// PENTING: middleware cors() dan express.json() WAJIB dipanggil SEBELUM routes
// Konfigurasi CORS super longgar untuk masa development
app.use(cors({
    origin: '*', // Mengizinkan request dari mana saja (termasuk origin 'null' / file://)
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], // Izinkan semua method API
    allowedHeaders: ['Content-Type', 'Authorization'] // Izinkan header ini
}));

app.use(express.json());

// Import routes
const authRoutes = require('./routes/authRoutes');
const lapanganRoutes = require('./routes/lapanganRoutes');
const transaksiRoutes = require('./routes/transaksiRoutes');

// Daftarkan routes
app.use('/api/auth', authRoutes);
app.use('/api/lapangan', lapanganRoutes);
app.use('/api/transaksi', transaksiRoutes);

// Cek status server
app.get('/', (req, res) => {
    res.json({ message: "Server Booking Futsal API berjalan lancar!" });
});

// Port server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});