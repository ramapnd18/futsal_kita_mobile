const pool = require('../config/db');

// 1. READ ALL (Public: Bisa diakses siapa saja untuk melihat daftar lapangan)
exports.getAllLapangan = async (req, res) => {
    console.log(`[GET /lapangan] Request masuk dari IP: ${req.ip}`);
    try {
        const [lapangan] = await pool.query('SELECT * FROM lapangan');
        console.log(`[GET /lapangan] Berhasil. Jumlah data: ${lapangan.length}`);
        res.json({ message: 'Berhasil mengambil data lapangan', data: lapangan });
    } catch (error) {
        console.error('[GET /lapangan] ERROR:', error.message);
        res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
    }
};

// 2. READ ONE (Public: Melihat detail satu lapangan)
exports.getLapanganById = async (req, res) => {
    const { id } = req.params;
    console.log(`[GET /lapangan/${id}] Request masuk.`);
    try {
        const [lapangan] = await pool.query('SELECT * FROM lapangan WHERE id_lapangan = ?', [id]);

        if (lapangan.length === 0) {
            console.warn(`[GET /lapangan/${id}] Lapangan tidak ditemukan.`);
            return res.status(404).json({ message: 'Lapangan tidak ditemukan' });
        }

        console.log(`[GET /lapangan/${id}] Berhasil.`);
        res.json({ message: 'Berhasil mengambil detail lapangan', data: lapangan[0] });
    } catch (error) {
        console.error(`[GET /lapangan/${id}] ERROR:`, error.message);
        res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
    }
};

// 3. CREATE (Protected: Hanya Admin)
exports.createLapangan = async (req, res) => {
    console.log('[POST /lapangan] Request masuk. Body:', req.body);
    try {
        const { nama_lapangan, harga_per_jam } = req.body;

        if (!nama_lapangan || !harga_per_jam) {
            console.warn('[POST /lapangan] Validasi gagal: nama_lapangan atau harga_per_jam kosong.');
            return res.status(400).json({ message: 'Nama lapangan dan harga per jam wajib diisi!' });
        }

        const [result] = await pool.query(
            'INSERT INTO lapangan (nama_lapangan, harga_per_jam) VALUES (?, ?)',
            [nama_lapangan, harga_per_jam]
        );

        console.log(`[POST /lapangan] Berhasil. ID baru: ${result.insertId}`);
        res.status(201).json({ message: 'Lapangan berhasil ditambahkan', id_lapangan: result.insertId });
    } catch (error) {
        console.error('[POST /lapangan] ERROR:', error.message);
        res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
    }
};

// 4. UPDATE (Protected: Hanya Admin)
exports.updateLapangan = async (req, res) => {
    const { id } = req.params;
    console.log(`[PUT /lapangan/${id}] Request masuk. Body:`, req.body);
    try {
        const { nama_lapangan, harga_per_jam } = req.body;

        const [result] = await pool.query(
            'UPDATE lapangan SET nama_lapangan = ?, harga_per_jam = ? WHERE id_lapangan = ?',
            [nama_lapangan, harga_per_jam, id]
        );

        if (result.affectedRows === 0) {
            console.warn(`[PUT /lapangan/${id}] Lapangan tidak ditemukan.`);
            return res.status(404).json({ message: 'Lapangan tidak ditemukan' });
        }

        console.log(`[PUT /lapangan/${id}] Berhasil diperbarui.`);
        res.json({ message: 'Data lapangan berhasil diperbarui' });
    } catch (error) {
        console.error(`[PUT /lapangan/${id}] ERROR:`, error.message);
        res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
    }
};

// 5. DELETE (Protected: Hanya Admin)
exports.deleteLapangan = async (req, res) => {
    const { id } = req.params;
    console.log(`[DELETE /lapangan/${id}] Request masuk.`);
    try {
        const [result] = await pool.query('DELETE FROM lapangan WHERE id_lapangan = ?', [id]);

        if (result.affectedRows === 0) {
            console.warn(`[DELETE /lapangan/${id}] Lapangan tidak ditemukan.`);
            return res.status(404).json({ message: 'Lapangan tidak ditemukan' });
        }

        console.log(`[DELETE /lapangan/${id}] Berhasil dihapus.`);
        res.json({ message: 'Lapangan berhasil dihapus' });
    } catch (error) {
        console.error(`[DELETE /lapangan/${id}] ERROR:`, error.message);
        res.status(500).json({ message: 'Terjadi kesalahan server', error: error.message });
    }
};