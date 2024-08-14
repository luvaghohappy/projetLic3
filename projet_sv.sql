-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : mar. 13 août 2024 à 14:57
-- Version du serveur : 10.4.28-MariaDB
-- Version de PHP : 8.0.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `projet_sv`
--

-- --------------------------------------------------------

--
-- Structure de la table `admin`
--

CREATE TABLE `admin` (
  `userid` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `passwords` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `admin`
--

INSERT INTO `admin` (`userid`, `email`, `passwords`) VALUES
(1, 'happy@viesauve.com', 'admin1');

-- --------------------------------------------------------

--
-- Structure de la table `ambulance`
--

CREATE TABLE `ambulance` (
  `id` int(11) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `postnom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `sexe` varchar(250) NOT NULL,
  `locations` point NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `ambulance`
--

INSERT INTO `ambulance` (`id`, `nom`, `postnom`, `prenom`, `sexe`, `locations`, `created_at`) VALUES
(1, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:20'),
(2, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:20'),
(4, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000053aeeefc73a3d40ad33be2f2ed5fabf, '2024-08-13 09:51:19'),
(5, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000003b281719d33a3d4097fd5f1a2bd6fabf, '2024-08-13 10:17:43'),
(6, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000e50f6157ee3c3d408af6c2ae37fbfabf, '2024-08-13 10:18:43'),
(7, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000000acc54d2d43a3d403e6d9e341ed6fabf, '2024-08-13 10:19:08'),
(8, 'isamuna', 'kembo', 'josue', 'Masculin', 0x0000000001010000001bbb44f5d63a3d4063586a6226d6fabf, '2024-08-13 10:52:33');

--
-- Déclencheurs `ambulance`
--
DELIMITER $$
CREATE TRIGGER `after_ambulance_insert` AFTER INSERT ON `ambulance` FOR EACH ROW BEGIN
    INSERT INTO rapport (nom, postnom, prenom, sexe, locations, created_at)
    VALUES (NEW.nom, NEW.postnom, NEW.prenom, NEW.sexe, NEW.locations, NEW.created_at);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_ambulance` AFTER INSERT ON `ambulance` FOR EACH ROW BEGIN
    DECLARE table_exists INT;
    
    -- Vérifie si une entrée pour 'ambulance' existe déjà dans la table states
    SELECT COUNT(*) INTO table_exists 
    FROM states 
    WHERE table_names = 'ambulance';
    
    IF table_exists > 0 THEN
        -- Si une entrée existe, incrémente le compteur d'enregistrements
        UPDATE states 
        SET record_count = record_count + 1 
        WHERE table_names = 'ambulance';
    ELSE
        -- Si aucune entrée n'existe, insère une nouvelle ligne avec un compteur de 1
        INSERT INTO states (table_names, record_count) 
        VALUES ('ambulance', 1);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `calls`
--

CREATE TABLE `calls` (
  `id` int(11) NOT NULL,
  `usernom` varchar(100) NOT NULL,
  `userprenom` varchar(100) NOT NULL,
  `opnom` varchar(100) NOT NULL,
  `opprenom` varchar(100) NOT NULL,
  `date_heure` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `historique_appel`
--

CREATE TABLE `historique_appel` (
  `id` int(11) NOT NULL,
  `numero` varchar(50) NOT NULL,
  `adresse` varchar(250) NOT NULL,
  `cordonnee_geo` point NOT NULL,
  `Date_Appel` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `historique_travail`
--

CREATE TABLE `historique_travail` (
  `id` int(11) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Heure_Entree` datetime NOT NULL,
  `Heure_Sortie` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `historique_travail`
--

INSERT INTO `historique_travail` (`id`, `Email`, `Heure_Entree`, `Heure_Sortie`) VALUES
(1, 'happy@gmail.com', '2024-07-28 16:06:49', 0),
(2, 'happy@gmail.com', '2024-07-28 17:51:11', 0),
(3, 'happy@gmail.com', '2024-07-28 17:58:22', 0),
(4, 'happy@gmail.com', '2024-07-29 13:48:06', 0),
(5, 'happy@gmail.com', '2024-07-29 14:14:52', 0),
(6, 'happy@gmail.com', '2024-07-29 14:31:17', 0),
(7, 'happy@gmail.com', '2024-07-29 14:48:09', 0),
(8, 'happy@gmail.com', '2024-07-29 16:17:14', 0),
(9, 'furaha@gmail.com', '2024-08-03 22:36:37', 0),
(10, 'furaha@gmail.com', '2024-08-03 23:12:47', 0),
(11, 'furaha@gmail.com', '2024-08-03 23:16:53', 0),
(12, 'furaha@gmail.com', '2024-08-03 23:43:01', 0),
(13, 'furaha@gmail.com', '2024-08-03 23:49:06', 0),
(14, 'furaha@gmail.com', '2024-08-03 23:50:08', 0),
(15, 'furaha@gmail.com', '2024-08-03 23:52:04', 0),
(16, 'furaha@gmail.com', '2024-08-04 00:00:24', 0),
(17, 'furaha@gmail.com', '2024-08-04 00:11:52', 0),
(18, 'furaha@gmail.com', '2024-08-04 00:25:31', 0),
(19, 'furaha@gmail.com', '2024-08-04 01:33:32', 0),
(20, 'furaha@gmail.com', '2024-08-04 01:55:58', 0),
(21, 'happy@gmail.com', '2024-08-04 02:06:03', 0),
(22, 'happy@gmail.com', '2024-08-04 02:08:14', 0),
(23, 'happy@gmail.com', '2024-08-04 02:10:30', 0),
(24, 'happy@gmail.com', '2024-08-04 02:11:51', 0),
(25, 'happy@gmail.com', '2024-08-04 02:13:15', 0),
(26, 'happy@gmail.com', '2024-08-04 02:46:24', 0),
(27, 'happy@gmail.com', '2024-08-04 05:14:12', 0),
(28, 'happy@gmail.com', '2024-08-04 05:25:41', 0),
(29, 'happy@gmail.com', '2024-08-04 15:19:55', 0),
(30, 'jean@gmail.com', '2024-08-04 15:25:26', 0),
(31, 'happy@gmail.com', '2024-08-04 15:29:44', 0),
(32, 'happy@gmail.com', '2024-08-04 15:33:22', 0),
(33, 'happy@gmail.com', '2024-08-04 15:36:04', 0),
(34, 'happy@gmail.com', '2024-08-04 15:41:44', 0),
(35, 'happy@gmail.com', '2024-08-04 15:50:28', 0),
(36, 'happy@gmail.com', '2024-08-04 15:55:54', 0),
(37, 'happy@gmail.com', '2024-08-04 16:07:21', 0),
(38, 'happy@gmail.com', '2024-08-04 16:11:16', 0),
(39, 'happy@gmail.com', '2024-08-04 16:18:14', 0),
(40, 'happy@gmail.com', '2024-08-04 16:22:35', 0),
(41, 'happy@gmail.com', '2024-08-04 16:50:20', 0),
(42, 'happy@gmail.com', '2024-08-04 16:52:18', 0),
(43, 'happy@gmail.com', '2024-08-04 16:53:31', 0),
(44, 'happy@gmail.com', '2024-08-04 18:14:23', 0),
(45, 'happy@gmail.com', '2024-08-04 18:23:24', 0),
(46, 'happy@gmail.com', '2024-08-04 18:32:32', 0),
(47, 'happy@gmail.com', '2024-08-04 18:51:13', 0),
(48, 'happy@gmail.com', '2024-08-04 19:00:07', 0),
(49, 'happy@gmail.com', '2024-08-04 19:02:43', 0),
(50, 'happy@gmail.com', '2024-08-04 19:04:38', 0),
(51, 'happy@gmail.com', '2024-08-04 19:09:46', 0),
(52, 'happy@gmail.com', '2024-08-04 19:12:58', 0),
(53, 'happy@gmail.com', '2024-08-04 19:18:02', 0),
(54, 'happy@gmail.com', '2024-08-04 19:20:46', 0),
(55, 'happy@gmail.com', '2024-08-05 12:55:28', 0),
(56, 'happy@gmail.com', '2024-08-05 13:15:02', 0),
(57, 'happy@gmail.com', '2024-08-05 13:34:28', 0),
(58, 'happy@gmail.com', '2024-08-05 15:22:40', 0),
(59, 'happy@gmail.com', '2024-08-05 15:55:21', 0),
(60, 'happy@gmail.com', '2024-08-05 23:51:34', 0),
(61, 'happy@gmail.com', '2024-08-06 00:06:39', 0),
(62, 'happy@gmail.com', '2024-08-06 00:10:40', 0),
(63, 'happy@gmail.com', '2024-08-06 00:18:21', 0),
(64, 'happy@gmail.com', '2024-08-06 10:31:14', 0),
(65, 'happy@gmail.com', '2024-08-06 10:58:27', 0),
(66, 'happy@gmail.com', '2024-08-06 11:01:10', 0),
(67, 'happy@gmail.com', '2024-08-06 16:37:10', 0),
(68, 'happy@gmail.com', '2024-08-06 16:42:41', 0),
(69, 'happy@gmail.com', '2024-08-06 17:01:22', 0),
(70, 'happy@gmail.com', '2024-08-06 17:11:40', 0),
(71, 'happy@gmail.com', '2024-08-06 17:18:12', 0),
(72, 'happy@gmail.com', '2024-08-06 17:39:08', 0),
(73, 'happy@gmail.com', '2024-08-06 17:45:35', 0),
(74, 'happy@gmail.com', '2024-08-06 17:53:05', 0),
(75, 'happy@gmail.com', '2024-08-06 18:15:55', 0),
(76, 'happy@gmail.com', '2024-08-06 18:26:25', 0),
(77, 'happy@viesauve.com', '2024-08-06 18:33:13', 0),
(78, 'happy@viesauve.com', '2024-08-06 18:39:24', 0),
(79, 'happy@viesauve.com', '2024-08-06 18:42:11', 0),
(80, 'happy@viesauve.com', '2024-08-06 18:44:59', 0),
(81, 'happy@viesauve.com', '2024-08-06 18:59:41', 0),
(82, 'happy@viesauve.com', '2024-08-06 19:01:00', 0),
(83, 'happy@viesauve.com', '2024-08-06 19:04:23', 0),
(84, 'happy@viesauve.com', '2024-08-06 19:07:23', 0),
(85, 'happy@viesauve.com', '2024-08-06 19:14:55', 0),
(86, 'happy@viesauve.com', '2024-08-06 19:18:11', 0),
(87, 'happy@viesauve.com', '2024-08-06 19:23:03', 0),
(88, 'happy@viesauve.com', '2024-08-06 19:27:15', 0),
(89, 'happy@viesauve.com', '2024-08-06 19:35:04', 0),
(90, 'happy@viesauve.com', '2024-08-07 10:38:16', 0),
(91, 'happy@viesauve.com', '2024-08-07 10:43:05', 0),
(92, 'happy@viesauve.com', '2024-08-07 13:17:07', 0),
(93, 'happy@viesauve.com', '2024-08-07 13:18:48', 0),
(94, 'happy@viesauve.com', '2024-08-07 13:23:31', 0),
(95, 'happy@viesauve.com', '2024-08-07 13:25:13', 0),
(96, 'happy@viesauve.com', '2024-08-07 13:28:02', 0),
(97, 'happy@viesauve.com', '2024-08-07 15:39:17', 0),
(98, 'happy@viesauve.com', '2024-08-07 15:41:19', 0),
(99, 'happy@viesauve.com', '2024-08-07 15:49:38', 0),
(100, 'happy@viesauve.com', '2024-08-07 21:18:49', 0),
(101, 'happy@viesauve.com', '2024-08-07 21:39:03', 0),
(102, 'happy@viesauve.com', '2024-08-07 21:42:40', 0),
(103, 'happy@viesauve.com', '2024-08-07 22:07:41', 0),
(104, 'happy@viesauve.com', '2024-08-07 22:15:12', 0),
(105, 'happy@viesauve.com', '2024-08-07 22:18:33', 0),
(106, 'happy@viesauve.com', '2024-08-07 22:25:08', 0),
(107, 'happy@viesauve.com', '2024-08-07 22:28:05', 0),
(108, 'happy@viesauve.com', '2024-08-07 22:34:00', 0),
(109, 'happy@viesauve.com', '2024-08-07 23:06:38', 0),
(110, 'happy@viesauve.com', '2024-08-08 12:36:08', 0),
(111, 'happy@viesauve.com', '2024-08-08 12:37:07', 0),
(112, 'happy@viesauve.com', '2024-08-08 12:52:41', 0),
(113, 'happy@viesauve.com', '2024-08-08 13:03:12', 0),
(114, 'happy@viesauve.com', '2024-08-08 13:10:03', 0),
(115, 'happy@viesauve.com', '2024-08-08 13:17:13', 0),
(116, 'happy@viesauve.com', '2024-08-08 13:34:29', 0),
(117, 'happy@viesauve.com', '2024-08-08 13:42:33', 0),
(118, 'happy@viesauve.com', '2024-08-08 14:09:37', 0),
(119, 'happy@viesauve.com', '2024-08-08 14:27:15', 0),
(120, 'happy@viesauve.com', '2024-08-08 16:36:15', 0),
(121, 'happy@viesauve.com', '2024-08-08 20:34:13', 0),
(122, 'happy@viesauve.com', '2024-08-08 20:37:20', 0),
(123, 'happy@viesauve.com', '2024-08-08 20:40:54', 0),
(124, 'martin@viesauve.com', '2024-08-08 21:44:06', 0),
(125, 'martin@viesauve.com', '2024-08-08 22:09:38', 0),
(126, 'martin@viesauve.com', '2024-08-08 22:23:31', 0),
(127, 'happy@viesauve.com', '2024-08-08 22:48:34', 0),
(128, 'happy@viesauve.com', '2024-08-08 22:53:09', 0),
(129, 'happy@viesauve.com', '2024-08-08 22:59:20', 0),
(130, 'happy@viesauve.com', '2024-08-09 05:53:13', 0),
(131, 'musa@viesauve.com', '2024-08-09 06:03:32', 0),
(132, 'musa@viesauve.com', '2024-08-09 06:03:35', 0),
(133, 'musa@viesauve.com', '2024-08-09 06:04:00', 0),
(134, 'musa@viesauve.com', '2024-08-09 06:04:11', 0),
(135, 'musa@viesauve.com', '2024-08-09 06:08:05', 0),
(136, 'musa@viesauve.com', '2024-08-09 06:15:18', 0),
(137, 'musa@viesauve.com', '2024-08-09 06:25:08', 0),
(138, 'musa@viesauve.com', '2024-08-09 06:59:58', 0),
(139, 'musa@viesauve.com', '2024-08-09 07:08:58', 0),
(140, 'musa@viesauve.com', '2024-08-09 07:10:36', 0),
(141, 'musa@viesauve.com', '2024-08-09 08:19:02', 0),
(142, 'musa@viesauve.com', '2024-08-10 19:33:23', 0),
(143, 'martin@viesauve.com', '2024-08-10 19:44:06', 0),
(144, 'martin@viesauve.com', '2024-08-10 20:21:32', 0),
(145, 'martin@viesauve.com', '2024-08-10 20:38:08', 0),
(146, 'martin@viesauve.com', '2024-08-10 20:40:45', 0),
(147, 'martin@viesauve.com', '2024-08-10 20:47:48', 0),
(148, 'martin@viesauve.com', '2024-08-10 20:53:02', 0),
(149, 'martin@viesauve.com', '2024-08-10 20:57:13', 0),
(150, 'martin@viesauve.com', '2024-08-10 20:58:13', 0),
(151, 'martin@viesauve.com', '2024-08-10 21:03:30', 0),
(152, 'musa@viesauve.com', '2024-08-10 21:08:39', 0),
(153, 'martin@viesauve.com', '2024-08-10 21:16:05', 0),
(154, 'martin@viesauve.com', '2024-08-11 02:45:15', 0),
(155, 'musa@viesauve.com', '2024-08-11 02:52:23', 0),
(156, 'musa@viesauve.com', '2024-08-11 02:55:05', 0),
(157, 'moses@viesauve.com', '2024-08-11 02:57:03', 0),
(158, 'musa@viesauve.com', '2024-08-11 03:43:38', 0),
(159, 'musa@viesauve.com', '2024-08-11 04:12:40', 0),
(160, 'musa@viesauve.com', '2024-08-11 10:49:50', 0),
(161, 'musa@viesauve.com', '2024-08-11 11:04:01', 0),
(162, 'martin@viesauve.com', '2024-08-11 11:07:01', 0),
(163, 'martin@viesauve.com', '2024-08-11 11:12:32', 0),
(164, 'martin@viesauve.com', '2024-08-11 11:17:20', 0),
(165, 'martin@viesauve.com', '2024-08-11 11:19:44', 0),
(166, 'martin@viesauve.com', '2024-08-11 11:23:40', 0),
(167, 'martin@viesauve.com', '2024-08-11 11:37:48', 0),
(168, 'martin@viesauve.com', '2024-08-11 12:23:19', 0),
(169, 'martin@viesauve.com', '2024-08-11 12:30:34', 0),
(170, 'martin@viesauve.com', '2024-08-11 13:15:00', 0),
(171, 'martin@viesauve.com', '2024-08-11 13:15:52', 0),
(172, 'musa@viesauve.com', '2024-08-11 15:15:26', 0),
(173, 'musa@viesauve.com', '2024-08-12 12:27:56', 0),
(174, 'musa@viesauve.com', '2024-08-12 13:11:04', 0),
(175, 'musa@viesauve.com', '2024-08-12 13:11:52', 0),
(176, 'jean@viesauve.com', '2024-08-12 13:16:04', 0),
(177, 'moses@viesauve.com', '2024-08-12 13:19:02', 0),
(178, 'moses@viesauve.com', '2024-08-12 13:19:32', 0),
(179, 'musa@viesauve.com', '2024-08-12 13:20:07', 0),
(180, 'musa@viesauve.com', '2024-08-12 13:26:05', 0),
(181, 'moses@viesauve.com', '2024-08-12 13:27:39', 0),
(182, 'musa@viesauve.com', '2024-08-12 13:28:17', 0),
(183, 'martin@viesauve.com', '2024-08-12 13:29:11', 0),
(184, 'musa@viesauve.com', '2024-08-12 13:33:16', 0),
(185, 'martin@viesauve.com', '2024-08-12 13:34:22', 0),
(186, 'moses@viesauve.com', '2024-08-12 13:35:34', 0),
(187, 'moses@viesauve.com', '2024-08-12 14:12:00', 0),
(188, 'moses@viesauve.com', '2024-08-12 14:22:50', 0),
(189, 'musa@viesauve.com', '2024-08-12 14:43:59', 0),
(190, 'musa@viesauve.com', '2024-08-12 14:59:37', 0),
(191, 'musa@viesauve.com', '2024-08-12 15:23:24', 0),
(192, 'musa@viesauve.com', '2024-08-12 16:46:39', 0),
(193, 'musa@viesauve.com', '2024-08-12 16:50:26', 0),
(194, 'musa@viesauve.com', '2024-08-12 17:57:24', 0),
(195, 'musa@viesauve.com', '2024-08-12 18:06:43', 0),
(196, 'musa@viesauve.com', '2024-08-12 18:12:30', 0),
(197, 'musa@viesauve.com', '2024-08-13 07:53:34', 0),
(198, 'musa@viesauve.com', '2024-08-13 07:58:32', 0),
(199, 'musa@viesauve.com', '2024-08-13 08:02:40', 0),
(200, 'musa@viesauve.com', '2024-08-13 08:17:30', 0),
(201, 'martins@vieusauve.com', '2024-08-13 08:51:30', 0),
(202, 'musa@viesauve.com', '2024-08-13 09:08:40', 0),
(203, 'martin@viesauve.com', '2024-08-13 09:09:13', 0),
(204, 'martin@viesauve.com', '2024-08-13 09:12:40', 0),
(205, 'martin@viesauve.com', '2024-08-13 09:16:02', 0),
(206, 'martin@viesauve.com', '2024-08-13 09:19:06', 0),
(207, 'musa@viesauve.com', '2024-08-13 09:19:38', 0),
(208, 'jean@viesauve.com', '2024-08-13 09:20:56', 0),
(209, 'musa@viesauve.com', '2024-08-13 09:23:05', 0),
(210, 'musa@viesauve.com', '2024-08-13 09:24:16', 0),
(211, 'jean@viesauve.com', '2024-08-13 09:26:26', 0),
(212, 'jean@viesauve.com', '2024-08-13 09:29:00', 0),
(213, 'jean@viesauve.com', '2024-08-13 09:30:37', 0),
(214, 'musa@viesauve.com', '2024-08-13 09:39:07', 0),
(215, 'musa@viesauve.com', '2024-08-13 09:40:08', 0),
(216, 'jean@viesauve.com', '2024-08-13 09:50:59', 0),
(217, 'martin@viesauve.com', '2024-08-13 09:52:59', 0),
(218, 'jean@viesauve.com', '2024-08-13 10:18:06', 0);

-- --------------------------------------------------------

--
-- Structure de la table `numero_urgence`
--

CREATE TABLE `numero_urgence` (
  `id` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `postnom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `numero1` int(20) NOT NULL,
  `numero2` int(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `operateurs`
--

CREATE TABLE `operateurs` (
  `userId` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `postnom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `passwords` varchar(100) NOT NULL,
  `roles` varchar(100) NOT NULL,
  `services` varchar(100) NOT NULL,
  `profil` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `operateurs`
--

INSERT INTO `operateurs` (`userId`, `nom`, `postnom`, `prenom`, `email`, `passwords`, `roles`, `services`, `profil`) VALUES
(1, 'Shabani', 'Martin', 'Shawama', 'martin@viesauve.com', '$2y$10$xEXgk7opUbMSQiYdHfw6F.0vsGhbJaC0Z36Jtuz6JsuDIeTSpfHpC', 'operateur', 'police', 'uploads/image.jpg'),
(2, 'musa', 'moise', 'moses', 'musa@viesauve.com', '$2y$10$IAP9anophkjFxdCrkyiK1uvNCZgdZQokgT4cV96OunuvxV/sCZFEa', 'operateur', 'pompier', 'uploads/image.jpg'),
(3, 'omokoko', 'gestionnaire', 'jean', 'jean@viesauve.com', '$2y$10$YOedLRB.HJiRa6p8.9Ehi.fxU0sSR8LM67NYfGHeixmqRaZfoIIvG', 'operateur', 'ambulance', 'uploads/image.jpg');

--
-- Déclencheurs `operateurs`
--
DELIMITER $$
CREATE TRIGGER `after_insert_user` AFTER INSERT ON `operateurs` FOR EACH ROW BEGIN
    DECLARE table_exists INT;
    
    -- Vérifie si une entrée pour 'operateurs' existe déjà dans la table states
    SELECT COUNT(*) INTO table_exists 
    FROM states 
    WHERE table_names = 'operateurs';
    
    IF table_exists > 0 THEN
        -- Si une entrée existe, incrémente le compteur d'enregistrements
        UPDATE states 
        SET record_count = record_count + 1 
        WHERE table_names = 'operateurs';
    ELSE
        -- Si aucune entrée n'existe, insère une nouvelle ligne avec un compteur de 1
        INSERT INTO states (table_names, record_count) 
        VALUES ('operateurs', 1);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `police`
--

CREATE TABLE `police` (
  `id` int(11) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `postnom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `sexe` varchar(250) NOT NULL,
  `locations` point NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `police`
--

INSERT INTO `police` (`id`, `nom`, `postnom`, `prenom`, `sexe`, `locations`, `created_at`) VALUES
(1, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:23'),
(2, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:23'),
(3, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x00000000010100000021c033ebd63a3d40a680b4ff01d6fabf, '2024-08-13 09:10:04'),
(4, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x00000000010100000021c033ebd63a3d40a680b4ff01d6fabf, '2024-08-13 09:16:25'),
(5, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000b8883952c73a3d40b7706ab125d5fabf, '2024-08-13 09:53:05'),
(6, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007094bc3ac73a3d40d6613bce23d5fabf, '2024-08-13 09:53:15'),
(7, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000006a1c4531d43a3d40c5e8143f21d6fabf, '2024-08-13 10:18:56');

--
-- Déclencheurs `police`
--
DELIMITER $$
CREATE TRIGGER `after_insert_police` AFTER INSERT ON `police` FOR EACH ROW BEGIN
    DECLARE table_exists INT;
    
    -- Vérifie si une entrée pour 'ambulance' existe déjà dans la table states
    SELECT COUNT(*) INTO table_exists 
    FROM states 
    WHERE table_names = 'police';
    
    IF table_exists > 0 THEN
        -- Si une entrée existe, incrémente le compteur d'enregistrements
        UPDATE states 
        SET record_count = record_count + 1 
        WHERE table_names = 'police';
    ELSE
        -- Si aucune entrée n'existe, insère une nouvelle ligne avec un compteur de 1
        INSERT INTO states (table_names, record_count) 
        VALUES ('police', 1);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_police_insert` AFTER INSERT ON `police` FOR EACH ROW BEGIN
    INSERT INTO rapport (nom, postnom, prenom, sexe, locations, created_at)
    VALUES (NEW.nom, NEW.postnom, NEW.prenom, NEW.sexe, NEW.locations, NEW.created_at);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `pompier`
--

CREATE TABLE `pompier` (
  `id` int(11) NOT NULL,
  `nom` varchar(255) NOT NULL,
  `postnom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `sexe` varchar(250) NOT NULL,
  `locations` point NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `pompier`
--

INSERT INTO `pompier` (`id`, `nom`, `postnom`, `prenom`, `sexe`, `locations`, `created_at`) VALUES
(1, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:24'),
(2, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:24'),
(3, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:24'),
(4, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000745078bfc03a3d40c94b48b599d4fabf, '2024-08-13 09:02:28'),
(5, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000f2cb05d3d53a3d4066248cb0f2d5fabf, '2024-08-13 09:16:40'),
(6, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000002fb99bf1c73a3d4083c87d062fd5fabf, '2024-08-13 09:39:18'),
(7, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000c94f4fc4c73a3d40f90c4d7e30d5fabf, '2024-08-13 09:40:13'),
(8, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000b8e45d9ac73a3d40f90c4d7e30d5fabf, '2024-08-13 09:40:28');

--
-- Déclencheurs `pompier`
--
DELIMITER $$
CREATE TRIGGER `after_insert_pompier` AFTER INSERT ON `pompier` FOR EACH ROW BEGIN
    DECLARE table_exists INT;
    
    -- Vérifie si une entrée pour 'pompier' existe déjà dans la table states
    SELECT COUNT(*) INTO table_exists 
    FROM states 
    WHERE table_names = 'pompier';
    
    IF table_exists > 0 THEN
        -- Si une entrée existe, incrémente le compteur d'enregistrements
        UPDATE states 
        SET record_count = record_count + 1 
        WHERE table_names = 'pompier';
    ELSE
        -- Si aucune entrée n'existe, insère une nouvelle ligne avec un compteur de 1
        INSERT INTO states (table_names, record_count) 
        VALUES ('pompier', 1);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_pompier_insert` AFTER INSERT ON `pompier` FOR EACH ROW BEGIN
    INSERT INTO rapport (nom, postnom, prenom, sexe, locations, created_at)
    VALUES (NEW.nom, NEW.postnom, NEW.prenom, NEW.sexe, NEW.locations, NEW.created_at);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `postes`
--

CREATE TABLE `postes` (
  `id` int(11) NOT NULL,
  `nom_post` varchar(100) NOT NULL,
  `adresse` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `postes`
--

INSERT INTO `postes` (`id`, `nom_post`, `adresse`) VALUES
(1, 'poste1', 'RDC,Goma,BDGEL'),
(2, 'Commissariat', 'Kyeshero,Ulpgl,Goma,RDC'),
(3, 'Karisimbi', '123TMK,GOMA,RDC');

-- --------------------------------------------------------

--
-- Structure de la table `rapport`
--

CREATE TABLE `rapport` (
  `id` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `postnom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `sexe` varchar(50) NOT NULL,
  `locations` point NOT NULL,
  `created_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `rapport`
--

INSERT INTO `rapport` (`id`, `nom`, `postnom`, `prenom`, `sexe`, `locations`, `created_at`) VALUES
(1, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:20'),
(2, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:20'),
(3, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:20'),
(4, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:23'),
(5, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:23'),
(6, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:24'),
(7, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:24'),
(8, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007d5468c5dc3a3d40f0dfbc38f1d5fabf, '2024-08-13 09:02:24'),
(9, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000745078bfc03a3d40c94b48b599d4fabf, '2024-08-13 09:02:28'),
(10, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x00000000010100000021c033ebd63a3d40a680b4ff01d6fabf, '2024-08-13 09:10:04'),
(11, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x00000000010100000021c033ebd63a3d40a680b4ff01d6fabf, '2024-08-13 09:16:25'),
(12, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000f2cb05d3d53a3d4066248cb0f2d5fabf, '2024-08-13 09:16:40'),
(13, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000002fb99bf1c73a3d4083c87d062fd5fabf, '2024-08-13 09:39:18'),
(14, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000c94f4fc4c73a3d40f90c4d7e30d5fabf, '2024-08-13 09:40:13'),
(15, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000b8e45d9ac73a3d40f90c4d7e30d5fabf, '2024-08-13 09:40:28'),
(16, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000053aeeefc73a3d40ad33be2f2ed5fabf, '2024-08-13 09:51:19'),
(17, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000b8883952c73a3d40b7706ab125d5fabf, '2024-08-13 09:53:05'),
(18, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000007094bc3ac73a3d40d6613bce23d5fabf, '2024-08-13 09:53:15'),
(19, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000003b281719d33a3d4097fd5f1a2bd6fabf, '2024-08-13 10:17:43'),
(20, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x000000000101000000e50f6157ee3c3d408af6c2ae37fbfabf, '2024-08-13 10:18:43'),
(21, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000006a1c4531d43a3d40c5e8143f21d6fabf, '2024-08-13 10:18:56'),
(22, 'happy ', 'luvagho ', 'furaha ', 'Féminin', 0x0000000001010000000acc54d2d43a3d403e6d9e341ed6fabf, '2024-08-13 10:19:08'),
(23, 'isamuna', 'kembo', 'josue', 'Masculin', 0x0000000001010000001bbb44f5d63a3d4063586a6226d6fabf, '2024-08-13 10:52:33');

-- --------------------------------------------------------

--
-- Structure de la table `states`
--

CREATE TABLE `states` (
  `id` int(11) NOT NULL,
  `table_names` varchar(100) NOT NULL,
  `record_count` float NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `states`
--

INSERT INTO `states` (`id`, `table_names`, `record_count`, `created_at`) VALUES
(1, 'ambulance', 7, '2024-08-13 09:02:20'),
(2, 'ambulance', 7, '2024-08-13 09:02:20'),
(3, 'police', 7, '2024-08-13 09:02:23'),
(4, 'pompier', 8, '2024-08-13 09:02:24'),
(5, 'operateurs', 2, '2024-08-13 09:05:24'),
(6, 'utilisateurs', 1, '2024-08-13 10:51:41');

-- --------------------------------------------------------

--
-- Structure de la table `utilisateurs`
--

CREATE TABLE `utilisateurs` (
  `Userid` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `postnom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `sexe` varchar(10) NOT NULL,
  `Date_naissance` date NOT NULL,
  `Adresse` varchar(255) NOT NULL,
  `Etat_civil` varchar(20) NOT NULL,
  `nombre_enfant` int(11) DEFAULT NULL,
  `Etat_sanitaire` varchar(255) NOT NULL,
  `allergie` varchar(255) NOT NULL,
  `Taille` float NOT NULL,
  `Poids` float NOT NULL,
  `Numero` varchar(15) NOT NULL,
  `email` varchar(255) NOT NULL,
  `mot_de_passe` varchar(255) NOT NULL,
  `image_path` varchar(1000) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `utilisateurs`
--

INSERT INTO `utilisateurs` (`Userid`, `nom`, `postnom`, `prenom`, `sexe`, `Date_naissance`, `Adresse`, `Etat_civil`, `nombre_enfant`, `Etat_sanitaire`, `allergie`, `Taille`, `Poids`, `Numero`, `email`, `mot_de_passe`, `image_path`) VALUES
(1, 'isamuna', 'kembo', 'josue', 'Masculin', '1973-08-13', 'Quatrier de volca', 'Marié(e)', 3, 'Bonne', 'Au derrangement ', 1.5, 64, '0829841200', 'josueisamuna@gmail.com', '$2y$10$Dw02XXdMeNpYpz2kidF1eu7J6o39IwoG7HxzFuMVuy65iDzyZ.YYK', 'uploads/20240810_181440.jpg');

--
-- Déclencheurs `utilisateurs`
--
DELIMITER $$
CREATE TRIGGER `after_insert_utilisateur` AFTER INSERT ON `utilisateurs` FOR EACH ROW BEGIN
    DECLARE table_exists INT;
    
    -- Vérifie si une entrée pour 'ambulance' existe déjà dans la table states
    SELECT COUNT(*) INTO table_exists 
    FROM states 
    WHERE table_names = 'utilisateurs';
    
    IF table_exists > 0 THEN
        -- Si une entrée existe, incrémente le compteur d'enregistrements
        UPDATE states 
        SET record_count = record_count + 1 
        WHERE table_names = 'utilisateurs';
    ELSE
        -- Si aucune entrée n'existe, insère une nouvelle ligne avec un compteur de 1
        INSERT INTO states (table_names, record_count) 
        VALUES ('utilisateurs', 1);
    END IF;
END
$$
DELIMITER ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`userid`);

--
-- Index pour la table `ambulance`
--
ALTER TABLE `ambulance`
  ADD PRIMARY KEY (`id`),
  ADD SPATIAL KEY `locations` (`locations`);

--
-- Index pour la table `calls`
--
ALTER TABLE `calls`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `historique_appel`
--
ALTER TABLE `historique_appel`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `historique_travail`
--
ALTER TABLE `historique_travail`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `numero_urgence`
--
ALTER TABLE `numero_urgence`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `operateurs`
--
ALTER TABLE `operateurs`
  ADD PRIMARY KEY (`userId`);

--
-- Index pour la table `police`
--
ALTER TABLE `police`
  ADD PRIMARY KEY (`id`),
  ADD SPATIAL KEY `locations` (`locations`);

--
-- Index pour la table `pompier`
--
ALTER TABLE `pompier`
  ADD PRIMARY KEY (`id`),
  ADD SPATIAL KEY `locations` (`locations`);

--
-- Index pour la table `postes`
--
ALTER TABLE `postes`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `rapport`
--
ALTER TABLE `rapport`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `states`
--
ALTER TABLE `states`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  ADD PRIMARY KEY (`Userid`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `admin`
--
ALTER TABLE `admin`
  MODIFY `userid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT pour la table `ambulance`
--
ALTER TABLE `ambulance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `calls`
--
ALTER TABLE `calls`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `historique_appel`
--
ALTER TABLE `historique_appel`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `historique_travail`
--
ALTER TABLE `historique_travail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=219;

--
-- AUTO_INCREMENT pour la table `numero_urgence`
--
ALTER TABLE `numero_urgence`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `operateurs`
--
ALTER TABLE `operateurs`
  MODIFY `userId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `police`
--
ALTER TABLE `police`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT pour la table `pompier`
--
ALTER TABLE `pompier`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `postes`
--
ALTER TABLE `postes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT pour la table `rapport`
--
ALTER TABLE `rapport`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT pour la table `states`
--
ALTER TABLE `states`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `utilisateurs`
--
ALTER TABLE `utilisateurs`
  MODIFY `Userid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

DELIMITER $$
--
-- Évènements
--
CREATE DEFINER=`root`@`localhost` EVENT `clear_pompier_data` ON SCHEDULE EVERY 1 DAY STARTS '2024-08-06 16:59:56' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    -- Transfert des données de la table pompier vers la table rapport
    INSERT INTO rapport (nom, postnom, prenom, sexe, locations, created_at, source_table)
    SELECT nom, postnom, prenom, sexe, locations, created_at, 'pompier' AS source_table
    FROM pompier;

    -- Vider la table pompier
    DELETE FROM pompier WHERE created_at < NOW() - INTERVAL 1 DAY;
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
