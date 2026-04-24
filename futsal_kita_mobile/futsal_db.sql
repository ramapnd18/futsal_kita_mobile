-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.30 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for futsal_db
CREATE DATABASE IF NOT EXISTS `futsal_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `futsal_db`;

-- Dumping structure for table futsal_db.lapangan
CREATE TABLE IF NOT EXISTS `lapangan` (
  `id_lapangan` int NOT NULL AUTO_INCREMENT,
  `nama_lapangan` varchar(100) NOT NULL,
  `harga_per_jam` int NOT NULL,
  PRIMARY KEY (`id_lapangan`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table futsal_db.lapangan: ~6 rows (approximately)
INSERT INTO `lapangan` (`id_lapangan`, `nama_lapangan`, `harga_per_jam`) VALUES
	(1, 'Lapangan Vinyl A', 100000),
	(4, 'Lapangan Sintetis B', 120000),
	(5, 'Lapangan Sintesis C', 110000),
	(6, 'Sintetis A', 120000),
	(7, 'Sintetis A', 120000),
	(8, 'Lapangan Sintetis D', 150000);

-- Dumping structure for table futsal_db.transaksi
CREATE TABLE IF NOT EXISTS `transaksi` (
  `id_transaksi` int NOT NULL AUTO_INCREMENT,
  `id_user` int NOT NULL,
  `id_lapangan` int NOT NULL,
  `tanggal_main` date NOT NULL,
  `jam_mulai` int NOT NULL,
  `durasi` int NOT NULL,
  `total_harga` int NOT NULL,
  `status` enum('pending','paid','cancelled') DEFAULT 'pending',
  PRIMARY KEY (`id_transaksi`),
  KEY `id_user` (`id_user`),
  KEY `id_lapangan` (`id_lapangan`),
  CONSTRAINT `transaksi_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE CASCADE,
  CONSTRAINT `transaksi_ibfk_2` FOREIGN KEY (`id_lapangan`) REFERENCES `lapangan` (`id_lapangan`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table futsal_db.transaksi: ~6 rows (approximately)
INSERT INTO `transaksi` (`id_transaksi`, `id_user`, `id_lapangan`, `tanggal_main`, `jam_mulai`, `durasi`, `total_harga`, `status`) VALUES
	(1, 4, 1, '2026-03-14', 8, 3, 300000, 'cancelled'),
	(3, 4, 1, '2026-03-14', 9, 2, 200000, 'paid'),
	(4, 4, 1, '2026-03-14', 8, 1, 100000, 'paid'),
	(5, 6, 1, '2026-03-14', 11, 1, 100000, 'pending'),
	(6, 6, 1, '2026-03-13', 15, 2, 200000, 'pending'),
	(7, 8, 1, '2026-03-13', 10, 2, 200000, 'pending');

-- Dumping structure for table futsal_db.users
CREATE TABLE IF NOT EXISTS `users` (
  `id_user` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `no_telepon` varchar(20) DEFAULT NULL,
  `role` enum('admin','pelanggan') DEFAULT 'pelanggan',
  PRIMARY KEY (`id_user`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table futsal_db.users: ~5 rows (approximately)
INSERT INTO `users` (`id_user`, `username`, `password`, `nama_lengkap`, `no_telepon`, `role`) VALUES
	(1, 'admin', '$2a$10$YourHashedPasswordHere...', 'Administrator', '08123456789', 'admin'),
	(4, 'amoon', '$2b$10$cqO9qU9GNNbGs01My41Fz.4AtkwAmhmd7CI7nOMgQr82fVN6C/PGO', 'pelanggan1', '085715143251', 'pelanggan'),
	(5, 'rama', '$2b$10$2oyNFJgy./V9kBLMvydLiuMjvEc6jPrIM89n5GUi6XZ1k0c4xUwvC', 'Rama Tri', '085715143251', 'admin'),
	(6, 'noora', '$2b$10$Rb8XLiXa4jI6g83fab5MT.Gb7T8IzxOEbWsWikL5QfAKN1L6NPzEm', 'noora', '085715143251', 'pelanggan'),
	(7, 'pelanggan1', '$2b$10$tyFqASrC0CaezhICzrtMXePY9B2MmdRzHlCsXjVr0MQzjjV3F9Gam', 'Budi', '08123', 'pelanggan'),
	(8, 'reza', '$2b$10$geXF2xAcJRTi47dXlsvFROvSGiB9ZYstkA37WGKVxJLyZNXEN1NTu', 'Reza arab', '099999999', 'pelanggan');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
