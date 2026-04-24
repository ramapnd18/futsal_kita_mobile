const express = require('express');
const router = express.Router();
// Tambahkan googleAuth dan googleCallback ke import
const { register, login, refresh, logout, googleAuth, googleCallback } = require('../controllers/authController');

// Endpoint yang sudah ada
router.post('/register', register);
router.post('/login', login);
router.post('/refresh', refresh);
router.post('/logout', logout);

// Endpoint BARU untuk Google OAuth
router.get('/google', googleAuth);
router.get('/google/callback', googleCallback);

module.exports = router;